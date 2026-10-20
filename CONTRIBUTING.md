# Contributing And Reviewing

Start with the [reviewer brief](docs/maintainers/review.md) for scope and risk
areas, or the [user documentation](docs/README.md) for behavior and examples.
Repository instructions shared by coding agents are in [AGENTS.md](AGENTS.md).

## Requirements

- Python 3.11+ and `python3 -m pip install -r requirements-dev.txt`.
- Typst 0.15.0 or 0.15.1; verify with `typst --version`.
- Poppler (`pdftotext`, `pdftoppm`) for painted text, bounds and visual inspection.
- DejaVu Sans and DejaVu Sans Mono for the manual (for example, Debian/Ubuntu
  package `fonts-dejavu-core`).
- The first compile also needs Typst package dependencies from the local cache
  or registry. CI records exact compiler versions in its matrix.

## Common Checks

```sh
python3 -m unittest discover -s tests -p 'test_*.py'
python3 tests/docs.py
python3 tests/run.py --filter 'tests/integration/*footnote*.typ'
python3 tests/page_numbering.py
python3 tests/run.py --manual
```

The full runner covers fixtures, expected diagnostics, examples and installed
consumers. A filtered run keeps that source's behavioral variants; an empty
selection fails. Run the two compiler versions **serially**, selecting each with
`--typst /path/to/typst`, and preserve `target/tests/results.json` between runs.
The runner installs its own copied package; a global install is unnecessary.

Within one invocation, sources are checked concurrently (`--jobs N`, default
half the CPUs); the full suite takes a few minutes. While iterating, filter to
the area you changed, for example `--filter 'tests/integration/*margin*.typ'`,
and run the full suite on both compilers before committing.

For ordinary CLI/editor development, use
`python3 scripts/install.py --namespace preview --link --reinstall`.
This exposes `@preview/deixis:0.2.0` without replacing the old 0.1.1 cache.

## Documentation And Packaging

```sh
python3 scripts/render-manual-examples.py
python3 scripts/render-manual-examples.py --check
python3 scripts/render-manual.py
python3 scripts/render-manual.py --update-pdf
```

Preview refreshes are needed after runtime or worked-example changes. The
manual builder validates the PDF before replacing the checked-in copy; inspect
its rendered pages too. User guides and examples describe supported behavior;
[archived engineering notes](docs/maintainers/archive/README.md) retain earlier
proposals. [Development](docs/maintainers/development.md) lists the independent
routing audits and details scope/layout constraints.

Use `develop/` for disposable probes, `tests/` for maintained checks, `docs/` for
documentation, and `target/` for generated output. Include a minimal reproducer,
compiler version, expected/actual behavior and relevant output in bug reports.
Review findings should name a concrete trigger, consequence, source location
and reproduction; distinguish defects from documented native limitations.

Tagging, publication and release uploads are separate actions. Follow the
[release checklist](docs/maintainers/release.md) when preparing a release.

## Local Website And Agent Skill

```sh
mdbook --version  # Tested with mdBook 0.5.4
python3 scripts/build-docs.py
python3 scripts/export-api.py --skill
python3 tests/skill.py
```

The website build runs a local link/search-coverage check and writes
`target/site/`; it does not deploy. See [website maintenance](docs/maintainers/website.md)
for serving it locally. The [agent skill](skills/deixis/SKILL.md) targets the
unreleased package; its check compiles every Typst snippet against an isolated
package copy and rejects warnings. Both commands accept `--typst` for the
minimum-version check. Regenerate the API cheat sheet after public API changes.

## README Artwork

```sh
python3 scripts/render-readme.py
python3 scripts/render-readme.py --update-assets
python3 scripts/render-readme.py --check
python3 tests/readme.py
```

The first command writes previews to `target/readme/`. Inspect the hero,
equation, individual transparent fragments and draft/final PNGs there before
updating `assets/readme/`. The fourteen illustrations are actual Deixis output;
the hero/comparison sources in `docs/maintainers/artwork/` use bundled SVGs for
immediate IDE preview. The
eight hero fragments are independently compiled from `hero-fragments.typ` with
`--input kind=text|equation|shared|diagram|editorial|footnote|outline|local`. The
generator uses standard-library Python, Typst and the DejaVu Sans/Libertinus Serif
fonts. It accepts `--typst` and rejects compiler warnings or extra specimen pages.
The complete batch must succeed before bundled artwork is replaced. Preview
refreshes and manual/website regeneration remain separate commands. Logo variants
live only in `assets/logos/`; artwork is excluded from the runtime package.

## Local Performance Measurements

```sh
python3 scripts/benchmark.py --output target/benchmarks/before
# After changing the runtime:
python3 scripts/benchmark.py --output target/benchmarks/after \
  --baseline target/benchmarks/before/results.json --compare-rendering
```

The fixed fixture covers 100/200/400 footnotes, margin notes and named references.
Each sample runs in a fresh process, serially with one compiler thread by default;
stop other test sweeps while measuring. Output includes copied input sources,
raw timings, compiler/runtime/workload identities and median speedup ratios.
`--compare-rendering` checks every page's pixels and internal PDF links using
Poppler/pypdf. `--trace` adds separate unmeasured compiler traces. See
[performance phase 2](docs/maintainers/performance-phase2.md) for results and limits.
