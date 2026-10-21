# Contributing And Reviewing

Start with the [user documentation](docs/README.md) for behavior and examples,
and [architecture](docs/development/architecture.md) for runtime contracts.
Repository instructions shared by coding agents are in [AGENTS.md](AGENTS.md).

## Requirements

- Python 3.11+ and `python3 -m pip install -r requirements-dev.txt`.
- Typst 0.15.0 or 0.15.1; verify with `typst --version`.
- Poppler (`pdftotext`, `pdftoppm`) for painted text, bounds and visual inspection.
- DejaVu Serif, DejaVu Sans and DejaVu Sans Mono for the manual (for example, Debian/Ubuntu
  package `fonts-dejavu-core`).
- Node.js for the local highlight.js integration test (otherwise skipped).
- Typst package dependencies from the local cache or registry. With an empty
  cache, run `mkdir -p target && typst compile --root . scripts/fetch-packages.typ target/fetch.pdf`
  once first: download progress on stderr would otherwise fail the
  warning-free checks. CI records exact compiler versions in its matrix.

CI runs the full matrix when a `v*` tag is pushed, or on demand from the
Actions tab; ordinary pushes do not trigger it, so run the checks below locally.

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
The runner installs its own copied package under `target/tests/package-data`; a
global install is unnecessary. Serialize all runner invocations in one checkout
and save each compiler run's log and results separately. Reject every Typst
warning, especially non-convergence; inspect real PDF/SVG output for layout and
navigation changes.

Within one invocation, sources are checked concurrently (`--jobs N`, default
half the CPUs); the full suite takes a few minutes. While iterating, filter to
the area you changed, for example `--filter 'tests/integration/*margin*.typ'`,
and run the full suite on both compilers before committing.

For ordinary CLI/editor development, use
`python3 scripts/install.py --namespace preview --link --reinstall`.
This exposes `@preview/deixis:0.2.0` without replacing the old 0.1.1 cache. Omit
`--link` for a copied install; omit `--namespace` to use `local`. For an isolated
copy, pass `--data-dir target/my-document/data` and compile with
`--package-path target/my-document/data/typst/packages`. Rerun after manifest
version changes; restart the editor language server if it retains an old import
error.

## Independent Routing Audits

Run with each supported compiler on `PATH`:

```sh
python3 tests/scene_avoidance.py
python3 tests/scene_ports.py
python3 tests/scene_sliding.py
python3 tests/route_group.py
python3 tests/route_group_ports.py
python3 tests/route_group_sockets.py
python3 tests/relay_repair.py
python3 tests/route_group_invariants.py
python3 tests/route_group_margin.py
python3 tests/route_group_index.py
```

These compare search and planning against independent references. Preserve each
compiler's logs/results separately and include the compiler version in reports.

## Documentation And Packaging

```sh
python3 scripts/render-manual-examples.py
python3 scripts/render-manual-examples.py --check
python3 scripts/render-guide-examples.py
python3 scripts/render-guide-examples.py --check
python3 scripts/render-guide-examples.py --verify --typst target/tools/typst-0.15.0/typst --work-dir target/guide-examples-0150
python3 scripts/render-manual.py
python3 scripts/render-manual.py --update-pdf
```

Preview refreshes are needed after runtime or worked-example changes.
Guide previews use an immediate JSON directive before a plain Typst fence:

````md
<!-- deixis-example: {"id":"short-note","height":"160pt"} -->
```typst
Text#deixis-footnote[An explanation.]
```
````

IDs are stable and unique within each guide. Optional `width`, `height` and
`margin` are Typst page values; `prelude` and `postlude` are supporting Typst
source strings, and `setup: false` disables the default setup show rule. The
renderer imports the isolated installed package, uses DejaVu Serif at 10pt on a
360pt-wide page with 18pt margins, and rejects all compiler diagnostics. Choose a
fixed height and adequate margins for overlays; inspect actual SVGs for clipping.
The site pairs each fence with SVG pages on white paper and offers the complete
source including setup. Mark configuration/signatures/partial excerpts with
`typst fragment`; these stay code-only with a visible Fragment label. Every
Typst guide fence must choose a directive or the fragment info string.

The renderer publishes `docs/assets/guides/` only after every snippet succeeds.
Its digest index covers complete generated source, runtime, renderer and assets;
`--check` checks freshness without compiling. `--verify` compiles into target
without replacing committed SVGs; use separate `--work-dir` paths for compiler
logs and minimum-version results. The website build and `tests/docs.py` run the
freshness check, including both CI workflows. Guide changes do not affect the
PDF manual.

The manual builder validates the PDF before replacing the checked-in copy; inspect
its rendered pages too. User guides and examples describe supported behavior.
Update source docstrings, guides and minimal examples when a public contract
changes. Use Camel Case With
Spaces for example headings; keep useful source/output pairs.

Use `develop/` for disposable probes, `tests/` for maintained checks, `docs/` for
documentation, and `target/` for generated output. Include a minimal reproducer,
compiler version, expected/actual behavior and relevant output in bug reports.
Review findings should name a concrete trigger, consequence, source location
and reproduction; distinguish defects from documented native limitations.

Tagging, publication and release uploads are separate actions. Follow the
[release checklist](docs/development/release.md) when preparing a release.

## Local Website And Agent Skill

```sh
mdbook --version  # Tested with mdBook 0.5.4
python3 scripts/build-docs.py
python3 -m http.server 8765 --bind 127.0.0.1 --directory target/site
python3 scripts/export-api.py --skill
python3 tests/skill.py
```

The website build runs a local link/search-coverage check and writes
`target/site/`; it does not deploy. The Docs workflow publishes the same build to
GitHub Pages (https://inspiros.github.io/typst-deixis/) when a `v*` tag is pushed,
or on demand from the Actions tab; it sets the project URL prefix that the
published 404 page needs. Open `http://127.0.0.1:8765/` after starting
the server and stop it when finished. Use the build script so generated navigation
and API pages are present. `book.toml` configures the site; theme/search assets
are bundled locally. Review desktop and phone layouts after presentation changes.
The [agent skill](skills/deixis/SKILL.md) targets the unreleased package; its check compiles every Typst snippet against an isolated
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
updating `assets/readme/`. The illustrations are actual Deixis output;
the hero/comparison sources in `scripts/artwork/` use bundled SVGs for
immediate IDE preview. The eight hero fragments are independently compiled from `hero-fragments.typ` with
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
Poppler/pypdf. `--trace` adds separate unmeasured compiler traces. Compare results
with the same compiler and workload; do not cache executable note bodies.
