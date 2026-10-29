## pytest

For Python code tested with pytest; ignore this rule anywhere else. The
`testing` rule applies first; this is how it is done in pytest.

- Group tests in classes: tests sharing setup share a class, with the setup in an autouse fixture on it.
- When several classes need the same setup, extract a base class (like `CommonTest`) and inherit from it.
- Store shared setup as `self.<name>` (`self.session`, `self.client`) from the base class's autouse fixture. Request a fixture in the signature only when some tests need it.
- New cases go in `parametrize`, with literal values. Avoid `pytest.param` (marks, ids) when setup or assertions differ significantly; write a separate test then.
- Exact outcomes: `pytest.raises(..., match=<the full message as a regex>)`, and `caplog.messages == []` for no unexpected logs.
- A known bug: `pytest.mark.xfail(strict=True)` with one shared constant as the reason (e.g. `NOT_YET_FIXED`); `strict=True` makes the test fail once the bug is fixed, which prompts removing the mark. Check it fails for the right reason with `--runxfail`.
