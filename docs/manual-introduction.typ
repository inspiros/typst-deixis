// Guided front matter. Examples are source-only; the illustration is compiled
// from examples/first-notes.typ, so the manual never replays its annotations.
#show raw: set text(size: 9pt)

= Annotating With Deixis

Deixis brings notes, spatial highlights, and visual connections to Typst.
It began with presentation annotations and now also serves technical documents,
editorial notes, and drawings made from ordinary document content.

Start with one marked passage and one explanation. Give the annotation a name
when other passages should share it. Add a drawn connection when the relationship
needs to be visible on the page.

#image("assets/first-notes.svg", width: 100%)

#text(size: 9pt, fill: luma(100))[
  First Notes: two colored margin annotations, one reused passage, and a native
  footnote. The editable source is `examples/first-notes.typ`.
]

The package runtime needs no external drawing library. It includes native routes
and arrowheads, while containers, body renderers, and connector painters remain
customizable. Public document APIs share one identity and scope model.

This manual describes the *unreleased 0.2.0 checkout*, requiring *Typst 0.15.0+*.
The downloadable `docs/manual.pdf` is built and checked from this source.
For rebuild and release commands, see `docs/development/release.md`.
A compact reference to all public APIs follows this tour;
the task-oriented guides in `docs/guides` cover advanced integration and limits.

#pagebreak()

= First Steps

== Install The Checkout

From the repository, install the development package locally:

```sh
python3 scripts/install.py --namespace preview --link --reinstall
```

This makes `@preview/deixis:0.2.0` available to Typst CLI and VS Code/Tinymist.
That version has not been published to Typst Universe. The local override keeps
the old 0.1.1 cache separate; see `CONTRIBUTING.md` for alternatives.

== Write A Note

```source
#import "@preview/deixis:0.2.0": *
#show: deixis-setup-notes

A useful result#deixis-footnote[A short explanation.]
is easier to read when its details have a place.
```

The wrapper creates a numbered mark and its body; no public ID is needed here.
Footnotes use the native page footer: long bodies paginate and look like
`std.footnote` entries, even when declared in a heading. Source indentation in
a body folds away, while explicit paragraph breaks remain. A long bordered body
needs a breakable `block` container rather than `rect`. See
`docs/guides/footnotes.md` and `examples/long-footnote.typ`.

== Move An Explanation Into The Margin

Set the page geometry before setup, leaving room for the body:

```source
#import "@preview/deixis:0.2.0": *
#set page(margin: (left: 25mm, right: 50mm, y: 25mm))
#show: deixis-setup-notes

Our #deixis-margin-note(id: <method>, width: 38mm, side: right,
  connector: "right-angle",
)[method][The explanation stays beside the passage it describes.]
keeps the main text short.
```

Two content arguments supply the marked passage and explanation. With one
content argument, a wrapper creates a solo numbered mark and uses that argument
as the explanation. Omit `connector:` for a note without a drawn connector.

#pagebreak()

= Marks, Bodies, And Connections

An annotation has one original mark, one number, and at most one attached body.
The original owns its logical identity and counter; the body owns its explanation,
formatting, and placement policy. A connection owns how two endpoints are joined.

== Share One Explanation

Use `id:` to create the original; use `of:` to attach a body or reuse the mark:

```source
#deixis-mark(id: <detail>)[First passage]
#deixis-margin-note-body(of: <detail>)[One explanation.]
#deixis-mark(of: <detail>)[A related passage]
See also @detail.
```

The original, body, and reused marks may appear in any order. Only the original
advances the counter. Another `id:` with the same name is an error. A body-only
`id:` creates a standalone explanation without a numbered original.

A reused mark adds a return-link origin and keeps the original number, body,
and captured mark style. It does not add another drawn connector. Set
`backlink: true` on the note/body to show return links. See
`docs/guides/identities.md` and `docs/guides/shared-notes.md`.

== Add A Connection Deliberately

A margin or inset body draws one connector from its original mark: a route name
is enough, as in `connector: "curve"`, and a record adds detail, as in
`connector: (route: "curve", heads: (body: "stealth"))`.
For a connection from another marked passage, name that occurrence:

```source
#deixis-mark(of: <detail>, occurrence: <again>)[Another passage]
#deixis-connect(
  from: (mark: <detail>, occurrence: <again>), to: <detail>,
  connector: (route: "curve", heads: (body: "stealth")),
)
```

Independent connections can target accepted margin/inset body frames, framed
inline bodies, live body points, pins, or attached objects. They neither create
nor move a body. Connections use their own foreground overlay by default;
`connector.layer` can select background independently of the body's layer.

#pagebreak()

= Choose A Placement Policy

Identity lookup and placement are different decisions. Declaring a body before
its original does not make every adapter follow that mark to another page.

#table(
  columns: (1.1fr, 2.7fr), inset: 7pt,
  stroke: 0.4pt + luma(210),
  table.header([*Body*], [*What Selects Its Position?*]),
  [Margin, overlay], [The original mark or an explicit anchor; packing may spill
    to later existing pages.],
  [Margin, flow], [Immediate placement on the declaration page, with no collision
    packing or cross-page relocation.],
  [Page footnote], [The native footer, allocated at the body declaration. Long
    bodies paginate.],
  [Inset], [The declaration page by default, with optional anchors, offsets,
    or a placement callback.],
  [Inline], [Native flow: right after its passage for the wrapper, or where a
    `-body` call appears.],
  [Endnote], [An eligible `deixis-print-endnotes` call.],
)

*Immediate/native flow* is useful when the body belongs in normal layout or
must stay on its declaration page. Native placement can affect the surrounding
paragraph; immediate margin notes do not use overlay packing.

*Foreground/background overlays* resolve document geometry before painting.
Overlay-only declarations add no text-flow space. Overlays can use existing
pages, but cannot create new pages. Within an overlay, `z-index` chooses drawing
priority; the body and its connectors have independent priorities.

*Collected flow* lets native layout own a local collection and its pagination:
block footnotes collect at the block's end, while endnotes use explicit printers.
See `docs/guides/ownership.md`, `rendering.md`, and `blocks.md`.

== Configure Appearance

```source
#deixis-set(palette: (rgb("3B6D9A"), rgb("387C69"), rgb("9A663F")))
```

Each annotation captures one accent; reuse does not consume another color.
Explicit styles win. `deixis-set` applies to subsequent declarations; a
`deixis-block` provides a local settings scope, while ordinary Typst brackets
do not. Body marker styles resolve at the body declaration; reused marks keep
the original mark style. See `docs/guides/configuration.md` and `appearance.md`.

#pagebreak()

= Drawings, Slides, And Next Steps

== Route Your Own Objects

The same routing core works without notes or numbering. Register content where
it is drawn, then declare each connection independently:

```source
#import "@preview/deixis:0.2.0": *
#show: deixis-setup-notes
#show: deixis-routing.with(policy: "avoid")

#grid(columns: (auto, 1fr, auto),
  deixis-attach(id: <source>)[Source], [],
  deixis-attach(id: <target>)[Target],
)
#deixis-connect(from: (node: <source>), to: (node: <target>),
  connector: (heads: (body: "stealth")))
```

`manual` keeps authored routes; `avoid` searches around registered obstacles;
`separate` also considers nearby connectors. Objects stay fixed. Pin ports,
exact waypoints, and optional cuts/crossing gaps refine the drawing without
replacing the connector model. For known coordinates, `deixis-route` returns
native geometry without document setup. Start with `examples/routing-in-place.typ`
and `docs/guides/document-routing.md`.

== Integrate With A Theme

Configure native foreground/background before applying setup. After replacing
either later, reapply `deixis-setup-notes`; existing identities and counters persist.
Host-owned themes can install explicit overlay hooks. Changing page dimensions
or margins alone does not require setup again. See `docs/guides/setup.md`.

Touying reveals retain hidden annotation ownership, but repeated subslides need
frame-local identities for explicit IDs/references. Use the maintained examples
and `docs/guides/visibility.md` / `touying-identities.md` for that integration.

== Read By Task

- *Prepare a final copy:* `review-comments.md`; write `deixis-comment` notes and
  use `deixis-set(omit: (series: ("review",)))` to keep passages without them.
  Omitted originals consume no numbers or colors; attached bodies/reused marks
  follow them. References to omitted IDs report an error. `omit: none` includes
  subsequent series; a Deixis block restores its parent's policy.
- *Style annotations:* `appearance.md`, `configuration.md`, `containers.md`.
- *Write long documents:* `collected-notes.md`, `blocks.md`, `counters.md`.
- *Customize drawing:* `connectors.md`, `document-routing.md`, `numeric-routing.md`.
- *Build an index:* `queries.md`, `outlines.md`, `note-data.md`.
- *Edit a text or build a glossary:* `editorial-recipes.md`, `review-comments.md`.
- *Replace body output:* `custom-renderers.md`, with live destination/content helpers.
- *Migrate or check limits:* `compatibility.md`.

These guides live in `docs/guides`; `docs/README.md` is the task-oriented index.
The compact reference follows this tour. A searchable documentation website can be built locally from the guides and source API catalog; hosting remains undecided.

#pagebreak()
