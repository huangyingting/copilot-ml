# Runbook — checkout API error-rate alert

## Alert

`azmon-checkout-error-rate-sev3`

## Scope

This is a synthetic training alert for copilot-ml. It models an Azure Monitor alert where the checkout API 5xx rate exceeds the rolling baseline.

## First response

1. Confirm whether the alert is from the demo environment.
2. Check the recent deployment timeline.
3. Compare failed request count against total request volume.
4. Review dependency latency/failure rate for the payment provider.
5. Record facts separately from hypotheses.

## Example KQL

```kusto
requests
| where cloud_RoleName == "checkout-api"
| summarize failures=countif(success == false), total=count() by bin(timestamp, 5m)
| extend errorRate = todouble(failures) / todouble(total)
```

## Read-only checks

- Error rate by 5-minute bin.
- Failed request count by endpoint.
- Dependency duration and failure count by provider.
- Recent deployment or configuration changes.
- Whether low traffic volume makes the percentage threshold noisy.

## Human decisions

- Whether to tune the alert threshold.
- Whether to roll back a recent configuration change.
- Whether to escalate to the owning service team.

## Do not automate

- Do not restart the service automatically.
- Do not change alert thresholds automatically.
- Do not deploy or roll back without human approval.
