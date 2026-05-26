`uv run pr_visualization.py --repo github/copilot-sdk`

🔍 PR Age Chart Generator

📦 Using specified repo: github/copilot-sdk

📊 Starting analysis...


🤖 I’m pulling the current open PRs and checking the local script so I can generate the chart cleanly in-place.

  ⚙️  report_intent
  ⚙️  view
  ⚙️  bash

🤖 I’ve got the PR feed; now I’m filtering to the last 7 days and rendering the age buckets into `pr-age-chart.png`.

  ⚙️  report_intent
  ⚙️  read_bash
  ⚙️  bash

🤖 The REST search call was flaky, so I’m switching to a cleaner GraphQL fetch and rendering from that directly.

  ⚙️  report_intent
  ⚙️  read_bash
  ⚙️  bash

🤖 The chart is rendered; I’m just confirming the file on disk and cleaning up the stuck GraphQL shell.

  ⚙️  report_intent
  ⚙️  stop_bash
  ⚙️  bash

🤖 **Saved** `pr-age-chart.png` in the current directory.

**PR health:** 13 open PRs from the last 7 days, **average age 2.48 days**. The **oldest** is **#1335** at **6.39 days**. Treating **>=5 days** as potentially stale for this 7-day slice, **2 PRs** look stale: **#1335** and **#1352**.

| PR | Age (days) |
|---|---:|
| #1335 | 6.39 |
| #1352 | 5.16 |
| #1386 | 3.24 |
| #1392 | 3.10 |
| #1394 | 2.99 |
| #1395 | 2.97 |
| #1400 | 2.92 |
| #1404 | 2.17 |
| #1406 | 2.02 |
| #1413 | 0.61 |
| #1420 | 0.26 |
| #1421 | 0.22 |
| #1422 | 0.21 |

**Age buckets:** `<1 day: 4`, `1-3 days: 5`, `3-5 days: 2`, `5-7 days: 2`, `>=7 days: 0`.


💡 Ask follow-up questions or type "exit" to quit.

Examples:
  - "Expand to the last month"
  - "Show me the 5 oldest PRs"
  - "Generate a pie chart instead"
  - "Group by author instead of age"

You: exit
👋 Goodbye!