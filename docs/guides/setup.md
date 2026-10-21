# Setup And Page Layers

Examples use the [standard import and setup](getting-started.md#1-start-with-native-footnotes).
Excerpts with existing IDs or callback variables extend the surrounding example.

Use `#show: deixis-setup-notes` before document annotations. Setup installs live
registration, reference conversion, hiding/visibility rules, final validation and
(default) background/foreground composition. It does not reset note identities,
counters, scopes or `deixis-set` configuration when applied again.

## What Needs Setup

| API family | Setup requirement |
| --- | --- |
| Marks and note bodies, including native flow notes and collected endnotes | Required for registration, ownership, numbering and live body metadata |
| Pins and `deixis-attach` | Required for accepted pin metadata and visibility |
| Blocks/minipages, counter reads/updates, note queries/outlines | Required for the document registry and scope model |
| `deixis-connect` | Required for declarations, endpoint resolution, validation and page painting |
| Note references and `@note-id` | Notes need setup; setup also installs the native-reference bridge |
| `deixis-route`, numeric `deixis-routing-scene`, `deixis-prepare-connector`, head/shaft painting | No setup for resolved numeric geometry; style/font lengths can still need a Typst `context` |
| Scene selectors such as `(mark: ...)`, `(body: ...)`, `(pin: ...)` | Need setup and a layout context to read accepted document geometry |
| `deixis-set` | Can precede setup; configuration alone does not initialize document features |

`deixis-page-overlay` is a painting hook, not an initializer. Host-owned page
layers still need setup for the annotation machinery. Conversely, setup is useful
even for flow-only notes that never use the page compositor. Direct low-level
layout/render helpers operate on their supplied records; they do not manufacture
registration or replace setup for document annotations.

## Changing A Native Page Layer

A later `set page(foreground: ...)` replaces the foreground property, including
its Deixis hook. Registration, counters, references, native flow bodies and the
other page layer remain active. A background replacement removes its hook too.
The background hook additionally publishes accepted physical page size/margin
snapshots, so keep it installed for document geometry even when all visible
annotations use foreground.

For ordinary document-level changes, reapply setup **after** setting the new
page layer:

```typst
#set page(foreground: [Draft])
#show: deixis-setup-notes

First section.
#pagebreak()
#set page(foreground: [Reviewed])
#show: deixis-setup-notes

The next section keeps the same note registry and numbering.
```

The unchanged layer is recognized as the existing compositor and retains its
native decoration. Foreground-only, background-only, both-layer and cleared
(`none`) replacements work. Reapplying setup without changing either layer is
safe too; decorations and note bodies are not duplicated.

Each setup call uses its own option values. Capture nondefault options once if
they should apply on each reapplication:

```typst
#let annotations = deixis-setup-notes.with(override-page-footnotes: true)
#show: annotations
// ... page break and new native foreground/background ...
#show: annotations
```

In particular, omitted `foreground`/`background` setup arguments default to
`none`, and omitted `override-page-footnotes` defaults to `false`. Reuse a bound
function to retain them. These setup arguments are extra Deixis-managed decoration;
the native page properties above are captured independently.

Changing width, height, margins, header, footer or page numbering alone preserves
the foreground/background properties and needs no setup call. Apply page-style
changes at deliberate page boundaries: native Typst page changes can create pages
when used halfway through existing content. See
[Changing Page Layers](../../examples/changing-page-layers.typ) for a small
editable example.

## Host-Owned Or Scoped Page Styles

For a theme or frequent/scoped layer changes, initialize once with
`page-overlays: false` and compose both hooks in the host's page settings:

```typst
#show: deixis-setup-notes.with(page-overlays: false)
#set page(
  background: [#deixis-page-overlay(layer: "background")],
  foreground: [Draft #deixis-page-overlay()],
)

First section.
#pagebreak()
#set page(foreground: [Reviewed #deixis-page-overlay()])

Second section.
```

Keep the matching hook in every replacement; setup need not be recalled. Native
page-style scopes can then restore their earlier decorations normally. For
scoped themes, put the theme decoration directly beside these hooks. Automatic
setup captures decoration in Deixis state, which does not follow the lexical
restoration of native page properties when a nested setup ends. Use the host-owned
pattern for that case rather than relying on nested setup to restore captured
state.

For Touying, install these hooks through the theme's `config-page` and use
`deixis-setup-notes(page-overlays: false, body)` in the slide setting. That avoids
changing native page styles halfway through a slide. The
[presentation guide](rendering.md#presentation-frameworks) includes the recipe.
