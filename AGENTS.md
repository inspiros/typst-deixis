# Working On Deixis

Read [the reviewer brief](docs/maintainers/review.md), then
[architecture](docs/maintainers/architecture.md) and the guide for the affected API.
Current source, tests and task guides take precedence over archived proposals.

- The checkout is unreleased 0.2.0; the minimum Typst version is 0.15.0.
  `src/lib.typ` is the public facade. Internal state/underscore helpers are private.
- Prefer bugs and compact, consistent APIs before new features or optimizations.
  Preserve simple wrapper calls alongside advanced configuration.
- Put disposable probes in `develop/`, maintained regressions in `tests/`,
  documentation in `docs/`, and generated output in `target/`.
- Use Camel Case With Spaces for example headings. Keep prose concise and retain
  useful source/output examples. Update source docstrings with API changes.
- Read the existing dirty state before editing. Preserve unrelated work; do not
  reset it. A read-only review should report findings before proposing edits.
- Run meaningful checks for the affected contract; reject Typst warnings,
  especially non-convergence. A successful exit code alone is insufficient.
- Run `tests/run.py` invocations serially in one checkout: they replace the same
  copied package and results. Save each compiler run's log/results separately.
- Use actual PDF/SVG output to check layout/navigation; metadata alone cannot
  prove that text is visible, unclipped or linked correctly.
- After runtime or specimen changes, refresh manual previews with
  `python3 scripts/render-manual-examples.py`. Regular manual builds go to
  `target/manual.pdf`; `--update-pdf` validates and replaces `docs/manual.pdf`.
- Do not publish a package/release, create a tag, or replace gallery artwork
  unless requested. See [release preparation](docs/maintainers/release.md).

Portable commands and dependencies are in [CONTRIBUTING.md](CONTRIBUTING.md).
Do not rely on another agent's local compiler binaries, ignored probes or logs.
