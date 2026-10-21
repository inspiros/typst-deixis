---
name: deixis
description: Create or edit Typst documents using the unreleased Deixis 0.2.0 API for notes, highlights, shared explanations, and connectors, including Touying integration. Use for Deixis annotations rather than generic Typst typesetting.
---

# Deixis Documents

This skill targets the **unreleased 0.2.0 API**, requiring **Typst 0.15.0+**.
The published 0.1.1 API differs. Do not silently substitute that release.

## Start A Document

Use the public package facade. When working from the Deixis checkout, install
a copied preview package with `python3 scripts/install.py --namespace preview`;
add `--reinstall` to refresh that copy. A linked development install is also
available with `--link`. Elsewhere, use a supplied 0.2.0 package copy.
For an isolated install without writing the user package directory, pass
`--data-dir target/my-document/data` and give Typst
`--package-path target/my-document/data/typst/packages`.

Set page geometry and native layers before installing the show rule:

```typst
#import "@preview/deixis:0.2.0": *
#set page(margin: 25mm)
#show: deixis-setup-notes

A result#deixis-footnote[A short explanation.] continues here.
```

Reach for a one-call wrapper first. Two content arguments mean
`[passage][explanation]`; a single argument means a solo marker plus explanation.
Use separate marks/bodies when their authored positions differ.

| Need | API | Placement |
| --- | --- | --- |
| Page footnote | `deixis-footnote` | Native footer, long bodies paginate |
| Explanation beside text | `deixis-margin-note` | Overlay follows original; reserve wide margins |
| Inset callout | `deixis-inset-note` | At declaration or configured anchor/offset |
| Aside in the sentence | `deixis-inline-note` | Follows passage; `inline: false` gives a callout |
| Collected endnotes | `deixis-endnote`, `deixis-print-endnotes` | At an explicit printer |
| Highlight without explanation | `deixis-mark` | Inline, region, or phantom mark |

## Identity And Connections

- `id:` creates the original and owns its number. Omit it for a private wrapper.
  `of:` reuses a mark or attaches the one body. Forward declarations work.
- A body-only call with `id:` creates a standalone body; it does not attach to
  an original. An attachment inherits the original's series and rendering scope.
  Put creation options and `data` on the original, not its attachments.
- `deixis-mark(of: <idea>)[Another passage]` shares the number/body without an
  additional drawn edge. `@idea` or `deixis-ref(<idea>)` creates a reference,
  not another mark occurrence. `backlink: true` enables return links on the body.
- `connector: "curve"` is the simple shorthand. A record such as
  `connector: (route: "curve", heads: "stealth")` adds controls. Records merge
  field by field with `deixis-set(connector: ...)` defaults. The style component
  is also named `connector`. Legacy flat `link-*` options are removed.
- Use `deixis-connect` for extra edges, `deixis-attach` for ordinary object
  bounds, and `deixis-routing` for an explicit routing policy. Reuse accepted
  geometry; avoidance only knows registered obstacles and does not move objects.

## Layout And Repeated Content

Page footnotes use native flow and footer typography. Use a document-level
`set footnote.entry(...)` for footer separators/spacing. `layer: "foreground"`
opts into an unsplittable overlay reservation. Long bordered bodies need a
breakable container; a native rectangle can clip oversized content silently.

Overlay margins pack into existing pages and cannot create new ones. Inset flow
placement can interrupt paragraphs. Reapply `deixis-setup-notes` after replacing
a native page foreground/background; themes may instead own both overlay hooks.

Native outlines already suppress repeated annotations. Use `deixis-plain` when
a running header repeats heading content. Keep essential bookmark words outside
deferred marks because Typst can omit them from PDF bookmark text.

For final copies, `deixis-set(omit: (series: ("todo",)))` preserves passages
while removing annotations in that series, including counters, bodies and
connections. Attachments/reused marks follow the original across scopes and
forward declarations. `omit: none` includes all subsequent series. References
to omitted IDs are errors. See the final-build recipe in the recipes reference.

`deixis-block` scopes settings and numbering; ordinary brackets do not. Its
footnotes collect after the whole block. `target: "page"` selects a native
page-footer body. Float the entire local collection for table/figure notes.
Native parent-scope floats cannot allocate page footnotes.

For complete paper, margin-note and slide starting points, read
[document recipes](references/recipes.md). For current names and selected
defaults, consult the generated [API cheat sheet](references/api.md).

## Diagnose And Verify

Duplicate originals/bodies: keep one `id:` declaration and use `of:` elsewhere.
Missing setup: install the show rule, or both hooks plus setup for host themes.
Unknown container keywords: put native wrapper arguments in `container-args:`.
Unsupported frame target: use `breakable: false` for one inline body frame, or a
live start/end point for a paginated body. Native hiding suppresses painting but
retains semantic numbering; it is not a draft/final omission switch.

Compile against the supplied 0.2.0 package and reject warnings, especially
non-convergence. Inspect rendered pages for clipping, readable placement and
working navigation; a successful compile alone cannot establish those facts.
