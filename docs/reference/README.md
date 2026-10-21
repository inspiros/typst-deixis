# Public API Reference

Import the package facade with `#import "@preview/deixis:0.2.0": *`. The reference
covers its public functions, including renderer and layout extension hooks.
Internal modules, state and underscore helpers are private.

Start with [getting started](../guides/getting-started.md) for a complete document,
or use the [guide index](../README.md) to choose an API by task. The searchable
website includes full signatures, defaults, parameter descriptions and guide
links. The [PDF manual](../manual.pdf) provides a compact reference alongside
23 worked examples.

The opt-in `short` module exposes direct aliases with the same parameters and
behavior. `configure` corresponds to `deixis-set` / `deixis-configure` and
`note-block` to `deixis-block`. See [short names](../guides/getting-started.md#optional-short-names)
for import syntax and native-name collisions. Grouped aliases and presets share
an entry; differences in their defaults are explained there.

Badges describe setup requirements. A separate Typst `context` can still be
needed for relative typography or document lookup.

| Badge | Meaning |
| --- | --- |
| Setup Required | Install `deixis-setup-notes` before using the document API. |
| No Setup | Works with supplied content or resolved numeric geometry alone. |
| Conditional | Supplied data can be independent; document lookup and live annotations need setup. |
| Installs Setup | Initializes the document annotation machinery. |
| Extension Hook | A low-level callback or integration API. |

Use the [custom-renderer guide](../guides/custom-renderers.md) before replacing
body layout, and the [numeric-routing guide](../guides/numeric-routing.md) for
independent drawings. [Compatibility and migration](../guides/compatibility.md)
lists remaining layout limits and replacements for removed APIs.
