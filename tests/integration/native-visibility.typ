#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 560pt, height: 720pt, margin: (x: 100pt, y: 35pt))
#set text(size: 10pt)
#show: deixis-setup-notes
#let render(name, data, ..args) = {
  if not data.at("disable-links", default: false) { [#metadata(name)<native-visibility-body>] }
  deixis-native-render-single(data, ..args.named())
}
#let edge(name, request) = [#metadata(name)<native-visibility-edge>#line(length: 12pt, stroke: red)]
#let connector(name) = (route: "straight-line", render: edge.with(name))
#let body(id, name, link: false) = deixis-inset-note-body(of: id, layer: "foreground",
  width: 100pt, dx: 140pt, dy: 15pt, render-single: render.with(name),
  connector: if link { connector(name) } else { none }, [#name])

// Each component owns its declaration visibility. A covered mark does not hide
// a separately declared body, but both shorthand/explicit edges to it disappear.
#hide[#deixis-mark(id: <mark-covered>)[Covered mark]]
#body(<mark-covered>, "MarkCoveredBody", link: true)
#deixis-connect(from: <mark-covered>, to: <mark-covered>, connector: connector("mark-covered-explicit"))
#deixis-mark(of: <mark-covered>, occurrence: "shown-after")[Visible reuse of the covered original]
#deixis-connect(from: (mark: <mark-covered>, occurrence: "shown-after"), to: <mark-covered>,
  connector: connector("shown-after"))
#v(45pt)

#deixis-mark(id: <body-covered>)[Visible mark]
#hide[#body(<body-covered>, "HiddenInsetBody", link: true)]
#deixis-connect(from: <body-covered>, to: <body-covered>, connector: connector("body-covered-explicit"))
#v(45pt)

#deixis-mark(id: <edge-covered>)[Visible mark]
#body(<edge-covered>, "EdgeCoveredBody")
#hide[#deixis-connect(from: <edge-covered>, to: <edge-covered>, connector: connector("covered-edge"))]
#v(45pt)

#deixis-mark(id: <shown>)[Visible mark]
#body(<shown>, "ShownBody", link: true)
#deixis-connect(from: <shown>, to: <shown>, connector: connector("shown-explicit"))
#v(45pt)

// Named reused inline/region/phantom sources have independent native hiding.
#deixis-mark(id: <reuse-owner>, mark-type: "phantom")
#body(<reuse-owner>, "RepeatedBody")
#hide[
  #deixis-mark(of: <reuse-owner>, occurrence: "inline-covered")[Covered occurrence]
  #deixis-mark(of: <reuse-owner>, occurrence: "region-covered", mark-type: "region",
    inline: true, layer: "background")[Covered region]
  #deixis-mark(of: <reuse-owner>, occurrence: "phantom-covered", mark-type: "phantom")
]
#deixis-mark(of: <reuse-owner>, occurrence: "shown")[Shown occurrence]
#for name in ("inline-covered", "region-covered", "phantom-covered", "shown") {
  deixis-connect(from: (mark: <reuse-owner>, occurrence: name), to: <reuse-owner>, connector: connector(name))
}

#pagebreak()
// A covered region keeps its geometric anchor for a separately visible body.
#hide[#deixis-region-mark(id: <covered-region>, inline: true, layer: "foreground")[Covered region]]
#deixis-margin-note-body(of: <covered-region>, layer: "foreground", side: right,
  width: 80pt, render-single: render.with("RegionBody"), connector: connector("region-covered"))[RegionBody]
#deixis-connect(from: <covered-region>, to: <covered-region>, connector: connector("region-covered-explicit"))

// Endpoint pins inherit hide; a pin used only as a socket/waypoint is geometry.
#deixis-pin("destination", padding: none)Destination
#hide[#deixis-pin("covered-pin", padding: none)Covered pin]
#deixis-pin("shown-pin", padding: none)Shown pin
#deixis-connect(from: (pin: "covered-pin"), to: (pin: "destination"), connector: connector("covered-pin-source"))
#deixis-connect(from: (pin: "shown-pin"), to: (pin: "covered-pin"), connector: connector("covered-pin-target"))
#deixis-connect(from: (pin: "shown-pin"), to: (pin: "destination"), connector: connector("shown-pins"))
#deixis-connect(from: (pin: "shown-pin"), to: (pin: "destination"),
  connector: connector("geometric-pin") + (via: ((pin: "covered-pin"),)))

// Nested native hide restores its context, including block footer collectors.
#deixis-block[
  Visible#deixis-footnote(id: <block-shown>, render-single: render.with("BlockBody"))[BlockBody].
  #hide[#hide[Covered#deixis-footnote(id: <block-covered>, render-single: render.with("HiddenBlockBody"))[HiddenBlockBody].]]
]
#deixis-set(render-group: (endnote: deixis-native-render-group))
#hide[#deixis-endnote(id: <end-covered>, render-single: render.with("HiddenEndBody"))[HiddenEndBody]]
#deixis-endnote(id: <end-shown>, render-single: render.with("EndBody"))[EndBody]
#deixis-print-endnotes()
#deixis-endnote-body(id: <unprinted-body>, series: "unprinted")[UnprintedBody]
#deixis-connect(from: (pin: "covered-pin"), to: (body: <unprinted-body>, point: "start"),
  connector: connector("covered-pin-unprinted-target"))
#deixis-connect(from: <shown>, to: (body: <end-covered>, point: "start"),
  connector: connector("covered-body-point"))
#pagebreak()
// Native hide also applies inside deferred bodies; no hidden shape callback runs.
#deixis-inset-note(id: <nested-outer>, series: "outers", layer: "foreground", width: 150pt,
  dx: 100pt, dy: 30pt, render-single: render.with("NestedOuter"))[Outer][
  NestedOuter
  #hide[#deixis-region-mark(id: <nested-region>, series: "inner", inline: true, layer: "foreground",
    region-shape: (..args) => panic("A covered nested region must not invoke its shape callback."))[HiddenNested]]
]
#for id in (<mark-covered>, <edge-covered>, <shown>, <reuse-owner>, <covered-region>, <block-shown>, <end-shown>, <nested-outer>) {
  [#link(id)[Body] ]
}

#context {
  assert.eq(query(<native-visibility-body>).map(m => m.value).sorted(),
    ("MarkCoveredBody", "EdgeCoveredBody", "ShownBody", "RepeatedBody", "RegionBody", "BlockBody", "EndBody", "NestedOuter").sorted())
  assert.eq(query(<native-visibility-edge>).map(m => m.value).sorted(),
    ("ShownBody", "shown-explicit", "shown", "shown-after", "shown-pins", "geometric-pin").sorted())
  let sys = deixis-system.final()
  assert.eq(sys.registry.value.notes.at("id-reuse-owner").count, 5)
  assert.eq(sys.registry.value.notes.at("id-nested-region").count, 1)
  assert.eq(query(<deixis-rendered-start>).len(), 8)
  [#metadata((destinations: query(<deixis-body-destination>).map(m => {
    let p = m.location().position()
    (page: p.page, x: p.x.pt(), y: p.y.pt())
  })))<test-result>]
}
