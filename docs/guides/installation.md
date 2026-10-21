# Installation And Editor Setup

The examples in this guide use the **unreleased Deixis 0.2.0 checkout** and
require **Typst 0.15.0+**. Typst Universe currently provides 0.1.1, which has a
different API. Install the checkout locally before trying these examples.

## Install The Checkout

```sh
git clone --branch overhaul-0.2.0 https://github.com/inspiros/typst-deixis
cd typst-deixis
python3 scripts/install.py --namespace preview --link --reinstall
```

This creates a local override for `@preview/deixis:0.2.0` in Typst's normal
package directory. It works with the Typst CLI and VS Code/Tinymist, and keeps
the old 0.1.1 package separate.

`--link` makes source changes visible immediately. Omit it for an independent
copied installation; rerun with `--reinstall` when you want to refresh that copy.
Rerun the installer after a manifest version change.

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

## Editors And Other Namespaces

If an editor retains an old import error after installation, restart its Typst
language server or reload the editor window. Check that its compiler supports
Typst 0.15.0 or newer and that the imported version is `0.2.0`.

The installer's default namespace is `local` when `--namespace` is omitted.
For that installation, use `@local/deixis:0.2.0` in imports. The examples use
`preview` so they work with the editor's usual package lookup.

The current API and remaining native-layout boundaries are described in
[compatibility and migration](compatibility.md).
