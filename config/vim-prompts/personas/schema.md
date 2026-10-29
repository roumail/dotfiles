---
context: [file, "rule:database", "rule:migrations"]
mode: ask
---
{rules}

Audit these SQLAlchemy models against the production data: which columns the data doesn't need and could be dropped, and which rules the data already follows that the database could enforce. This is a report: don't edit any files, and never write to a database.

{context}

{selection}

**The database.** How to reach it is the `database` rule; without one, stop and ask. Before connecting, tell me which database you will connect to and wait for my go-ahead. Then:

- Read only: open every session with `SET default_transaction_read_only = on` and `SET statement_timeout = '30s'`, or the equivalent the `database` rule gives.
- Aggregates only: counts, null counts, distinct counts, minimum and maximum of numbers and dates, and the distinct values of columns that hold codes, flags or enum values. Never select rows, free text, or anything about a person.
- Start from the statistics, which scan nothing: `pg_stats` (`null_frac`, `n_distinct`, `most_common_vals`) and `pg_stat_user_tables` (`n_live_tup`, `last_analyze`, `last_autoanalyze`). Run exact counts only for the candidates they leave, and on a table over a million rows show me the query first.
- Show every query with its result.

**The code.** For each column of the models in scope, find every read and write: the package, templates, serialisers and forms, API exposure (an API that publishes model fields, unless the model excludes the column), migrations, and the dependents and configuration repositories the repository's description names. A column an API publishes may be read by someone outside: its kind is `ask`, not `drop`, and say who might read it.

**Candidates:**

- `drop`: always null, or one value everywhere, and no code reads it except code that would go with it.
- `not-null`: no nulls, and every write sets it.
- `check`: a few values, matching a set the code relies on; or two columns with an order the data always follows (start before end), with zero violations.
- `unique`: as many distinct values as non-null rows, and the code looks it up as one.
- `foreign-key`: an id column with no foreign key, every value present in the table it refers to (zero rows from the anti-join).

The `migrations` rule says what such a change also has to touch (history tables, defaults); say it for each finding.

Answer in this shape, numbering the points once:

## Summary
The tables in scope, their row counts, and when their statistics were last analysed.

## Findings
`N. Model.column [drop|not-null|check|unique|foreign-key|ask]` then: the queries and results that show it, the code that reads or writes it, and what the migration would need (a backfill, a server default, the history table).

## Not checked
What you couldn't query or trace, and why.

## Verdict
The numbers worth a migration, in the order to do them. A finding holds for the data today: say where the code could still write what a constraint would forbid.

{query}
