# Installation And Editor Setup

Deixis **0.2.0** is available on Typst Universe and requires **Typst 0.15.0+**.

## Install

Import the package in your Typst document:

```typst fragment
#import "@preview/deixis:0.2.0": *
```

Typst downloads it automatically. If you are upgrading from 0.1.1, read the
[compatibility and migration guide](compatibility.md#migrate-from-011).

## Try A Document

<!-- deixis-example: {"id": "example-1"} -->
```typst
#import "@preview/deixis:0.2.0": *
#show: deixis-setup-notes

A useful result#deixis-footnote[A short explanation.] continues here.
```

Save it as `paper.typ` and compile it with `typst compile paper.typ`. The
[getting-started guide](getting-started.md) continues with margin notes,
shared explanations, and styling.

## Editors

If an editor retains an old import error after installation, restart its Typst
language server or reload the editor window. Check that its compiler supports
Typst 0.15.0 or newer and that the imported version is `0.2.0`.

## Development Checkout

For contributor work, install a local checkout instead of the published package:

```sh
git clone https://github.com/inspiros/typst-deixis
cd typst-deixis
python3 scripts/install.py --namespace preview --link --reinstall
```

This overrides `@preview/deixis:0.2.0` in Typst's normal package directory for
Typst CLI and VS Code/Tinymist. `--link` makes source changes visible immediately.
Omit it for an independent copied installation; rerun with `--reinstall` to
refresh that copy. Rerun the installer after a manifest version change.

The installer's default namespace is `local` when `--namespace` is omitted.
For that installation, use `@local/deixis:0.2.0` in imports. See
[CONTRIBUTING](../../CONTRIBUTING.md) for isolated installs and development checks.

The current API and remaining native-layout boundaries are described in
[compatibility and migration](compatibility.md).
