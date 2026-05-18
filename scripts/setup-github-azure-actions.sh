#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
APPLY=false
YES=false
RUN_WORKFLOW=false
REPO=""
BRANCH="main"
SUBSCRIPTION_ID=""
RESOURCE_GROUP=""
LOCATION="eastus"
APP_NAME="aca-copilot-ml"
ENVIRONMENT_NAME="aca-copilot-ml-env"
APP_REGISTRATION_NAME="copilot-ml-github-actions"
ROLE="Contributor"

usage() {
  cat <<'USAGE'
Prepare GitHub Actions settings for deploying copilot-ml to Azure Container Apps.

This script configures GitHub OIDC for Azure, plus the GitHub repository
secrets and variables required by .github/workflows/deploy-aca.yml.

Dry-run is the default. Use --apply to perform live Azure/GitHub writes.

Required:
  --resource-group NAME          Azure resource group for the demo app

Optional:
  --branch NAME                  Branch authorized for OIDC (default: main)
  --location REGION              Azure region (default: eastus)
  --app-name NAME                Container App name (default: aca-copilot-ml)
  --environment-name NAME        Container Apps environment name
                                 (default: aca-copilot-ml-env)
  --app-registration-name NAME   Entra app registration display name
                                 (default: copilot-ml-github-actions)
  --role NAME                    Resource-group role (default: Contributor)
  --run-workflow                 Trigger deploy-aca.yml after setup
  --apply                        Perform live writes instead of dry-run
  --yes                          Skip interactive confirmation with --apply
  -h, --help                     Show this help

Examples:
  ./scripts/setup-github-azure-actions.sh \
    --resource-group rg-copilot-ml-demo

  ./scripts/setup-github-azure-actions.sh \
    --resource-group rg-copilot-ml-demo \
    --location eastus \
    --apply

Prerequisites:
  - az CLI installed and logged in
  - gh CLI installed and logged in with admin access to the repository
  - Run from a GitHub-backed git checkout with an origin remote
  - Permission to create Entra app registrations/service principals
  - Permission to assign roles on the target resource group
USAGE
}

log() {
  printf '[%s] %s\n' "$SCRIPT_NAME" "$*"
}

fail() {
  printf '[%s] ERROR: %s\n' "$SCRIPT_NAME" "$*" >&2
  exit 1
}

run_cmd() {
  if [[ "$APPLY" == true ]]; then
    log "RUN: $*"
    "$@"
  else
    printf '[%s] DRY-RUN:' "$SCRIPT_NAME"
    printf ' %q' "$@"
    printf '\n'
  fi
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Required command not found: $1"
}

normalize_github_repo() {
  local remote_url="$1"
  remote_url="${remote_url#git@github.com:}"
  remote_url="${remote_url#ssh://git@github.com/}"
  remote_url="${remote_url#https://github.com/}"
  remote_url="${remote_url#http://github.com/}"
  remote_url="${remote_url%.git}"
  printf '%s' "$remote_url"
}

infer_github_repo() {
  local remote_url=""
  local repo=""

  remote_url="$(git remote get-url origin 2>/dev/null || true)"
  if [[ -n "$remote_url" ]]; then
    repo="$(normalize_github_repo "$remote_url")"
  fi

  if [[ -z "$repo" || "$repo" != */* || "$repo" == github.com/* ]]; then
    repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null || true)"
  fi

  [[ -n "$repo" ]] || fail "Could not infer GitHub repository. Run from a GitHub-backed checkout with an origin remote."
  [[ "$repo" == */* ]] || fail "Inferred GitHub repository is not OWNER/REPO: $repo"
  [[ "$repo" != github.com/* ]] || fail "Inferred GitHub repository is not OWNER/REPO: $repo"

  printf '%s' "$repo"
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --branch)
        BRANCH="${2:-}"; shift 2 ;;
      --resource-group)
        RESOURCE_GROUP="${2:-}"; shift 2 ;;
      --location)
        LOCATION="${2:-}"; shift 2 ;;
      --app-name)
        APP_NAME="${2:-}"; shift 2 ;;
      --environment-name)
        ENVIRONMENT_NAME="${2:-}"; shift 2 ;;
      --app-registration-name)
        APP_REGISTRATION_NAME="${2:-}"; shift 2 ;;
      --role)
        ROLE="${2:-}"; shift 2 ;;
      --run-workflow)
        RUN_WORKFLOW=true; shift ;;
      --apply)
        APPLY=true; shift ;;
      --yes)
        YES=true; shift ;;
      -h|--help)
        usage; exit 0 ;;
      *)
        fail "Unknown argument: $1" ;;
    esac
  done
}

validate_inputs() {
  [[ -n "$RESOURCE_GROUP" ]] || fail "--resource-group is required"
  [[ -n "$LOCATION" ]] || fail "--location cannot be empty"
  [[ -n "$APP_NAME" ]] || fail "--app-name cannot be empty"
  [[ -n "$ENVIRONMENT_NAME" ]] || fail "--environment-name cannot be empty"
  [[ -n "$BRANCH" ]] || fail "--branch cannot be empty"
}

confirm_apply() {
  if [[ "$APPLY" != true ]]; then
    log "Dry-run mode. No Azure or GitHub settings will be changed."
    return
  fi

  cat <<CONFIRM

This will perform live writes:
  Azure subscription:   $SUBSCRIPTION_ID
  Resource group:       $RESOURCE_GROUP
  Location:             $LOCATION
  GitHub repository:    $REPO
  OIDC branch:          $BRANCH
  Container App name:   $APP_NAME
  Container Apps env:   $ENVIRONMENT_NAME
  Entra app name:       $APP_REGISTRATION_NAME
  Role assignment:      $ROLE on the resource group

CONFIRM

  if [[ "$YES" == true ]]; then
    log "--yes supplied; continuing with live writes."
    return
  fi

  read -r -p "Type APPLY to continue: " answer
  [[ "$answer" == "APPLY" ]] || fail "Confirmation not received; exiting."
}

main() {
  parse_args "$@"
  validate_inputs

  require_cmd az
  require_cmd gh
  require_cmd git

  log "Checking Azure and GitHub CLI authentication."
  az account show --query id --output tsv >/dev/null
  gh auth status --hostname github.com >/dev/null

  REPO="$(infer_github_repo)"
  log "Using inferred GitHub repository: $REPO"

  SUBSCRIPTION_ID="$(az account show --query id --output tsv)"
  [[ -n "$SUBSCRIPTION_ID" ]] || fail "Could not resolve the current Azure subscription. Run 'az account set --subscription <id>' first."
  log "Using current Azure CLI subscription: $SUBSCRIPTION_ID"

  confirm_apply

  tenant_id="$(az account show --subscription "$SUBSCRIPTION_ID" --query tenantId --output tsv)"
  [[ -n "$tenant_id" ]] || fail "Could not resolve tenant ID for subscription $SUBSCRIPTION_ID"

  subject="repo:${REPO}:ref:refs/heads/${BRANCH}"
  credential_name="github-${BRANCH}"

  log "Preparing resource group."
  run_cmd az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --tags workload=copilot-ml deleteAfter=workshop

  log "Finding or creating Entra app registration."
  client_id="$(az ad app list --display-name "$APP_REGISTRATION_NAME" --query '[0].appId' --output tsv 2>/dev/null || true)"
  if [[ -z "$client_id" ]]; then
    if [[ "$APPLY" == true ]]; then
      client_id="$(az ad app create --display-name "$APP_REGISTRATION_NAME" --query appId --output tsv)"
    else
      run_cmd az ad app create --display-name "$APP_REGISTRATION_NAME"
      client_id="00000000-0000-0000-0000-DRYRUNCLIENTID"
    fi
  else
    log "Using existing Entra app registration: $APP_REGISTRATION_NAME"
  fi

  log "Finding or creating service principal."
  sp_object_id="$(az ad sp show --id "$client_id" --query id --output tsv 2>/dev/null || true)"
  if [[ -z "$sp_object_id" ]]; then
    if [[ "$APPLY" == true ]]; then
      sp_object_id="$(az ad sp create --id "$client_id" --query id --output tsv)"
    else
      run_cmd az ad sp create --id "$client_id"
      sp_object_id="00000000-0000-0000-0000-DRYRUNSPOBJECT"
    fi
  else
    log "Using existing service principal."
  fi

  log "Creating or updating federated credential for GitHub Actions OIDC."
  cred_file="$(mktemp)"
  cat >"$cred_file" <<JSON
{
  "name": "$credential_name",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "$subject",
  "description": "GitHub Actions OIDC for $REPO on branch $BRANCH",
  "audiences": ["api://AzureADTokenExchange"]
}
JSON

  existing_credential="$(az ad app federated-credential list --id "$client_id" --query "[?name=='$credential_name'].name | [0]" --output tsv 2>/dev/null || true)"
  if [[ -n "$existing_credential" ]]; then
    log "Federated credential $credential_name already exists; updating it."
    run_cmd az ad app federated-credential update \
      --id "$client_id" \
      --federated-credential-id "$credential_name" \
      --parameters "$cred_file"
  else
    run_cmd az ad app federated-credential create \
      --id "$client_id" \
      --parameters "$cred_file"
  fi
  rm -f "$cred_file"

  scope="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}"
  log "Assigning $ROLE on $scope."
  existing_assignment="$(az role assignment list --assignee "$client_id" --role "$ROLE" --scope "$scope" --query '[0].id' --output tsv 2>/dev/null || true)"
  if [[ -n "$existing_assignment" ]]; then
    log "Role assignment already exists."
  else
    run_cmd az role assignment create \
      --assignee-object-id "$sp_object_id" \
      --assignee-principal-type ServicePrincipal \
      --role "$ROLE" \
      --scope "$scope"
  fi

  log "Writing GitHub Actions secrets and variables."
  run_cmd gh secret set AZURE_CLIENT_ID --repo "$REPO" --body "$client_id"
  run_cmd gh secret set AZURE_TENANT_ID --repo "$REPO" --body "$tenant_id"
  run_cmd gh secret set AZURE_SUBSCRIPTION_ID --repo "$REPO" --body "$SUBSCRIPTION_ID"

  run_cmd gh variable set AZURE_RESOURCE_GROUP --repo "$REPO" --body "$RESOURCE_GROUP"
  run_cmd gh variable set AZURE_LOCATION --repo "$REPO" --body "$LOCATION"
  run_cmd gh variable set CONTAINER_APP_NAME --repo "$REPO" --body "$APP_NAME"
  run_cmd gh variable set CONTAINER_ENV_NAME --repo "$REPO" --body "$ENVIRONMENT_NAME"

  if [[ "$RUN_WORKFLOW" == true ]]; then
    log "Triggering GitHub Actions deployment workflow."
    run_cmd gh workflow run deploy-aca.yml --repo "$REPO" --ref "$BRANCH"
  else
    log "Workflow trigger skipped. Use --run-workflow with --apply when ready."
  fi

  cat <<SUMMARY

Setup summary:
  GitHub repo:          $REPO
  Authorized branch:   $BRANCH
  Azure subscription:  $SUBSCRIPTION_ID
  Azure tenant:        $tenant_id
  Resource group:      $RESOURCE_GROUP
  Container App:       $APP_NAME
  Environment:         $ENVIRONMENT_NAME
  Entra app client ID: $client_id

Next step:
  In GitHub, run the "Deploy copilot-ml to Azure Container Apps" workflow,
  or re-run this script with --apply --run-workflow after reviewing settings.
SUMMARY
}

main "$@"
