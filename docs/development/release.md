# Release Preparation

The current version is 0.2.0, requiring Typst 0.15.0+. Local builds do not
create tags, upload release assets or publish packages. Perform those actions
only when explicitly requested.

## Verify The Candidate

- Resolve release-blocking defects and choose the final version. Keep
  `typst.toml`, imports, migration notes, skill and manual status consistent;
  update pre-release status wording when preparing the actual release.
- Review [CHANGELOG](../../CHANGELOG.md) for user-facing changes and
  [compatibility](../guides/compatibility.md) for supported limits.
- Run the Python/documentation checks, full compiler runner with installed
  consumers, and independent routing audits on Typst 0.15.0 and 0.15.1.
  Commands and dependencies are in [CONTRIBUTING](../../CONTRIBUTING.md).
  Serialize runner invocations and retain each compiler's logs/results separately.
  Reject warnings, especially non-convergence, and inspect real PDF/SVG output.
- Refresh guide previews with `python3 scripts/render-guide-examples.py` and
  check freshness with `python3 scripts/render-guide-examples.py --check`.
  Compile them on the minimum compiler with
  `python3 scripts/render-guide-examples.py --verify --typst target/tools/typst-0.15.0/typst --work-dir target/guide-examples-0150`.
  Inspect the source/output pairs on desktop and phone widths in light and dark
  themes; fixed overlay canvases must contain their complete visible output.
- Build the website with `python3 scripts/build-docs.py`; regenerate the skill
  reference with `python3 scripts/export-api.py --skill` and verify it with
  `python3 tests/skill.py`. Check README artwork with
  `python3 scripts/render-readme.py --check` after any authorized asset refresh.
- Inspect copied package contents. The runtime package excludes documentation,
  examples, tests, scripts, agent instructions and local caches. The source tag
  should contain all intended source, assets, tests and public documentation.

## Update Release Wording

In the release commit, replace pre-release status statements with the released
version. Find them with this case-insensitive status search:

```sh
git grep -n -i 'un[r]eleased' -- ':!CHANGELOG.md'
```

Check the README notice and Install section (use the Universe import),
the docs index, site home badge, installation,
getting-started and compatibility guides, migration headings, the manual
introduction, AGENTS.md, CONTRIBUTING.md, the skill and the API-sheet generator
(`scripts/export-api.py`). Name the changelog section with the version and date,
then rebuild the manual, skill reference and website.

## Build The Downloadable Manual

```sh
python3 scripts/render-manual-examples.py
python3 scripts/render-manual-examples.py --check
python3 scripts/render-manual.py --update-pdf
python3 tests/docs.py --check-manual
```

Regular manual builds stay in `target/manual.pdf`. The builder rejects warnings
and checks public entries/defaults, specimen freshness, PDF destinations, empty
pages and text bounds before replacing `docs/manual.pdf`. The build record in
`docs/manual-build.json` records compiler/version and source/output hashes.
Inspect rasterized pages too; automated checks do not establish visual quality.
Keep the verified PDF in `docs/` for offline reading.

## Prepare The Runtime Package

Universe renders the package README, while the manifest excludes `docs/`,
`examples/` and logo assets. Before submission, make README images and document
links resolve outside the checkout against the actual source tag.

Prepare a local candidate without changing the repository README:

```sh
python3 scripts/prepare-universe.py --ref v0.2.0
```

Choose the actual tag spelling. The command rewrites Markdown/HTML links and
images to absolute GitHub URLs, checks checkout targets, copies the runtime
package and writes files/hashes to `target/universe-candidate/inspection.json`.
It does not verify remote URLs or create the tag. Once the tag exists, check
those remote links, including linked images and fragments. Python unit tests
cover missing/outside targets and README link rewriting.

README links stay relative in the repository. The candidate rewrites only
targets that are not shipped with the package to the tag; in-page anchors and
bundled files such as `LICENSE` stay relative. Copy the candidate's package
directory to `packages/preview/deixis/<version>/` on a new branch of a
typst/packages fork, compile the examples against it with
`--package-path <fork>/packages`, and open the pull request once the tag exists.

Inspect a separate package copy with:

```sh
python3 scripts/install.py --data-dir target/release-package
```

Confirm that all README references resolve independently of checkout-relative
files. The PDF belongs to the source repository and release download, and is
excluded from the installed runtime package.

## Publish When Requested

Create the chosen source tag/release only after the checks above. Attach the
same verified `docs/manual.pdf` as `manual.pdf`; optionally attach its build
record. The versioned asset URL is
`https://github.com/inspiros/typst-deixis/releases/download/<tag>/manual.pdf`.
Add it to release notes/download links after the asset exists. Submit the
inspected runtime candidate to Typst Universe separately. Local preparation
requires no publishing credentials.
