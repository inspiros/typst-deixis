#import "../../src/core/internal.typ": *
#context {
  let sys = (stack: (), stroke: (margin-note: (body: blue, mark: green), rest: red))
  assert.eq(_deixis-resolve-typed-param(sys, auto, "stroke", "margin-note", component: "body"), blue)
  assert.eq(_deixis-resolve-typed-param(sys, auto, "stroke", "margin-note", component: "mark"), green)
  assert.eq(_deixis-resolve-typed-param(sys, none, "stroke", "margin-note", component: "body"), none)
  assert.eq(_deixis-resolve-typed-param(sys, auto, "stroke", "footnote", component: "body"), red)
  sys.stack.push((stroke: (nodes: orange, connector: purple)))
  assert.eq(_deixis-resolve-typed-param(sys, auto, "stroke", "margin-note", component: "body"), orange)
  assert.eq(_deixis-resolve-typed-param(sys, auto, "stroke", "margin-note", component: "connector"), purple)
  // Ordinary value dictionaries must never be mistaken for scopes.
  assert.eq(_deixis-resolve-typed-param(sys, (top-left: 2pt), "radius", "margin-note"), (top-left: 2pt))
  assert.eq(_deixis-resolve-typed-param((stack: (), stroke: (inline-mark: blue, rest: red)),
    auto, "stroke", "inline-mark", component: "mark"), blue)
  let configured = _deixis-connector-options((stack: (), connector: (inset-note: (route: "orthogonal", heads: (body: "circle")))),
    "inset-note", auto)
  assert.eq((configured.route, configured.heads), ("right-angle", (body: "circle")))
  // Incompatible representations replace rather than contaminating native data.
  assert.eq(_deixis-merge-config((body: 2pt), (top-left: 4pt)), (top-left: 4pt))
  assert.eq(_deixis-merge-config((top-left: 4pt), (body: 2pt)), (body: 2pt))
  assert.eq(_deixis-merge-config((nodes: 2pt), (inset-note: 4pt)), (inset-note: 4pt))
  assert.eq(_deixis-merge-config((inset-note: 4pt), (nodes: 2pt)), (nodes: 2pt))
  assert.eq(_deixis-merge-config((body: 2pt), (:)), (:))
  assert.eq(_deixis-merge-styles((radius: (body: (top-left: 4pt))),
    (radius: (body: (top-right: auto, bottom-left: 7pt)))),
    (radius: (body: (top-left: 4pt, bottom-left: 7pt))))
  assert.eq(_deixis-resolve-typed-param(none, (:), "radius", "inline-mark", component: "mark"), (:))
  // Endpoint maps are literal data even though they use component spellings.
  let heads = _deixis-connector-options((stack: (), connector: (inset-note: (heads: (body: "circle")))),
    "inset-note", (heads: (:),))
  assert.eq(heads.heads, (:))
  let configured-heads = _deixis-connector-options((stack: (), connector: (inset-note: (heads: (body: "circle")))),
    "inset-note", auto)
  assert.eq(configured-heads.heads, (body: "circle"))
  let alignment = (mark: bottom, body: top)
  assert.eq(_deixis-resolve-typed-param(none, alignment, "mark-align", "margin-note"), alignment)
  assert.eq(_deixis-resolve-typed-param((stack: (), mark-align: (margin-note: alignment)),
    auto, "mark-align", "margin-note"), alignment)

  // Repeated resolutions must track both the selected value and its origin
  // as local overrides and partial stack scopes change.
  let settings = (stack: ((gap: (endnote: 9pt)),), gap: 6pt)
  let gap(local) = _deixis-resolve-typed-param(settings, local, "gap", "footnote", with-origin: true)
  assert.eq(gap(auto), (value: 6pt, origin: "global"))
  assert.eq(gap((body: 0pt)), (value: 0pt, origin: "local"))
  settings.stack.push((gap: (footnote: (body: 3pt))))
  assert.eq(_deixis-resolve-typed-param(settings, auto, "gap", "footnote", with-origin: true),
    (value: 3pt, origin: "stack"))
  assert.eq(_deixis-resolve-typed-param(none, auto, "gap", "footnote", with-origin: true),
    (value: 0.5em, origin: "factory"))
  let policy = (restart: "page", pattern: "*")
  settings.stack.push((numbering: (footnote: policy)))
  assert.eq(_deixis-resolve-typed-param(settings, auto, "numbering", "footnote", with-origin: true),
    (value: policy, origin: "stack"))
}
