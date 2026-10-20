# Changelog

User-facing changes follow [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
The full [overhaul development journal](docs/maintainers/archive/changelog-through-2026-10-20.md)
is preserved separately.

## [Unreleased]

The 0.2.0 overhaul requires **Typst 0.15.0+**. See the
[compatibility and migration guide](docs/guides/compatibility.md) before updating
from 0.1.1 or an earlier development snapshot.

### Breaking

- Rename `deixis-default-render-single` / `deixis-default-render-group` to
  `deixis-aligned-render-single` / `deixis-aligned-render-group` (short names:
  `aligned-render-single` / `aligned-render-group`), without compatibility aliases.
- Remove `deixis-set-pin-pattern`; set attachment `prefix:`/`postfix:` per call
  or bind a `deixis-attach.with(...)` preset. Default delimiters stay unchanged.
- Make `deixis-group-layout`, `deixis-default-footnote-style` and
  `deixis-show-refs` private. Choose `render-group`, supply a `body-style`
  callback, and let `deixis-setup-notes` install the reference bridge.
- Remove `internal-id:` from `deixis-place-anchored`; use public `pin:` targets.
  Inset adapters retain private original-ID placement.
- Remove `deixis-highlight-rect-region` / `deixis-highlight-ellipse-region`.
  Use region marks with `stroke: none`; add `region-shape: deixis-ellipse-region`
  for an elliptical highlight.

- Use `id:` to create an annotation and `of:` to attach its body or reuse its
  mark. Removed `label:`, `deixis-repeat-mark`, and positional reuse targets.
  The original owns numbering; the body adapter owns placement and formatting.
- Import only the public package facade. Internal modules, state and underscore
  helpers are private.
- Configure connections with `connector:` (a route string or a record), including
  the `connector` style component. Removed the flat `link`, `link-ports`,
  `link-waypoints`, `link-marks`, and `link-heads` options.
- Use `deixis-query-notes(page: ...)` instead of `deixis-page-notes`, and
  `include-unpaired` instead of `include-celibates`. Query/outline callbacks
  receive semantic records and safe summaries rather than executable bodies.
- Put native container arguments in `container-args:`. Unknown options, unresolved
  attachments and invalid scope/geometry selections now produce diagnostics.
- Page footnotes default to paginating native flow and native footer typography.
  Configure separators and spacing with `set footnote.entry(...)`;
  `override-page-footnotes: true` restores the overlay default.

### Added

- Opt-in `short` module of direct function aliases. `configure` also has the
  prefixed alias `deixis-configure`; `deixis-set` remains supported. The scoped
  container is `note-block`, preserving native `block`.

- Unnumbered notes: a resolved `numbering: none` takes no counter value, so
  `deixis-set(numbering: (margin-note: none, inset-note: none))` turns margin and
  inset notes into asides while footnotes keep counting 1, 2, 3.
- Named palettes: `deixis-set(palette: "okabe-ito")`, plus `"tol-bright"`,
  `"tol-muted"`, `"tableau"` and the house `"deixis"` set.

- Per-family numbering such as `deixis-set(numbering: (footnote: "*", endnote: "i"))`;
  a wrapper's family key precedes mark-type keys and `rest`.

- Opt-in page-local display numbering with `numbering: (restart: "page", pattern: "1")`
  (including symbol patterns). Assigned counters remain stable; shared notes,
  references, outlines and split bodies keep their original marker.

- Scoped `deixis-set(omit: (series: ("todo",)))` for draft/final builds. Preserves
  passages while skipping annotations, counting, bodies, and connections;
  references to omitted IDs report a clear diagnostic.
- Unified original/reused inline, region and phantom marks, forward attachments,
  named occurrences, standalone bodies, references and return links.
- `deixis-inline-note[passage][explanation]` for a one-call inline aside;
  `inline: false` selects a callout. `deixis-plain` repeats marked content without
  creating annotations; native outlines apply this automatically.
- Scoped/threaded numbering, counter resets, local table/figure collections,
  paginated blocks, annotation data, queries and custom catalogue/outline views.
- Opt-in automatic color palettes, native containers and custom body renderers,
  component layers and `z-index`, plus native-hide and Touying reveal support.
- Independent connections between marks, bodies, pins and attached objects;
  native line/curve routes, heads, ports, exact waypoints, cuts, crossing gaps,
  continuation markers, and custom connector painters.
- Numeric route/scene/group APIs and scoped document routing with bounded
  obstacle avoidance and group separation. Explicit geometry stays constrained;
  failed searches never paint an unchecked fallback.
- Task guides, editable examples, an illustrated PDF manual, a local searchable
  mdBook website, and an agent skill with checked document recipes.
  API reference material is generated from source. Editorial recipes cover a
  critical apparatus, author/status review lists and first-use glossaries.
- A scripted README hero and focused reading, equation and editorial-review
  showcases replace the legacy gallery.
- Experimental HTML export keeps every note body with linked markers and
  backlinks; margin, inset and comment bodies follow the document as one list,
  while connectors and other page paint are omitted.

### Changed

- `deixis-minipage(margin: ...)` retains 0.1.1's internal padding semantics
  (`inset: margin`, `outset: 0pt`); its documentation now describes that behavior.
- Default decoration uses muted blue-gray with a light tint. Inline, margin and
  inset marker-to-body spacing is 0.25em. Explicit styles retain precedence.
- Connector records merge field by field with scoped defaults. Connector layers
  are independent of body layers and default to foreground.
- Registry and geometry indexes reduce repeated work in documents with hundreds
  of notes. Reference, palette and margin preparation share stable evidence.
- Typed settings resolution reuses a smaller cache key; local 400-note workloads
  show a 1.20–1.25× margin speedup without changing rendered output.
- Margin planning measures each body once per layout pass instead of once per
  later page; identity lookups and internal state updates avoid redundant
  hashing. Rendered output is unchanged.
- Bodies preserve authored content and explicit breaks; inline decoration can
  wrap and paginate. Collections retain per-note typography and grouping rules.

### Fixed

- Outline and running-header replays duplicating annotations, shifting numbers
  or reporting duplicate IDs.
- Footnote reservation, migration, spacing and typography mismatches, including
  orphan separators and heading styles leaking into page footers.
- Anonymous nested regions oscillating during layout; deferred declarations,
  measurement and repeated output creating late or duplicate effects.
- Scope/thread collisions, forward-attachment ownership, incorrect references,
  reused-mark page lists and missing native PDF destinations.
- Multi-page margin/region geometry, cross-page relay bounds and peer links,
  hidden annotations escaping slide reveals, and repeated setup composition.
- Curve/orthogonal endpoint constraints, route trimming and bounded-search
  correctness. The migration guide records remaining native/routing limits.
- Boxed, underlined and highlighted marks breaking their frame or fill around a
  superscript marker.
- Custom margin renderers whose measured size depends on their location could
  be placed twice or not at all: every page now plans earlier notes with the
  same measurement.

## [0.1.1] - 2026-06-04

### Added
- Added a geometric path pullback calculation for routed links when `link-marks` is enabled, ensuring thick lines stay hidden inside the arrowheads.

### Changed
- Improved the `#deixis-note-outline` rendering engine. It now allows multi-line note bodies to wrap naturally without clipping, and aligns page numbers to the bottom.

### Fixed
- Fixed a panic caused by backlinks on celibate (mark-only) endnotes.
- Fixed an issue where multi-page region marks would calculate incorrect vertical boundaries on non-A4 paper sizes by dynamically resolving Typst's native `auto` margins.

## [0.1.0] - 2026-06-01

### Added
- Initial public release of `deixis` to the Typst Universe.
