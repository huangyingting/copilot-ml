# Data-quality test checklist

Apply per dbt model or warehouse table.

## Required (severity: error if missing)

- [ ] At least one column has `unique` + `not_null` (the primary key / grain)
- [ ] All business-required columns have `not_null`
- [ ] All FK columns have `relationships` to the parent table

## Strongly recommended (severity: warn)

- [ ] Enum-like columns have `accepted_values`
- [ ] Sources backing the model have `freshness` with `warn_after` and `error_after`
- [ ] Numeric columns with known bounds have a range test (custom SQL)
- [ ] Time columns covering the partition key have a "no future timestamps" test

## Nice to have (severity: nit)

- [ ] Row-count anomaly test (today vs. trailing 7-day average)
- [ ] Distinct-count anomaly for high-cardinality dimension columns
- [ ] Cardinality test on a join (`x_to_one` or `one_to_many`) when the relationship is asserted in design

## Don't do

- [ ] Avoid bulk-adding `not_null` to every column. Tests cost runtime and clutter signal.
- [ ] Don't add `unique` to high-cardinality but non-key columns — runs are expensive, signal is low.
- [ ] Don't add tests that fail nightly and get ignored. Either fix the test or remove it.
- [ ] Don't write tests whose failure messages select PII. Count, don't select.

## Cap

8 tests per model. More than that, the suite becomes background noise.
