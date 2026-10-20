#import "../../src/lib.typ": *
#import "../../src/core/query.typ": _deixis-pin-index, _deixis-select-pins, _deixis-pins-for
#import "../../src/layout/geometry.typ": _deixis-region-bounds
#set page(width: 500pt, height: 460pt, margin: 40pt)
#show: deixis-setup-notes
#let ticks = state("pin-components", 0)
#let component(title) = context {
  let scope = here()
  let pin(name) = (name: name, scope: scope)
  [#metadata(scope)<pin-component>]
  // Forward geometry must not combine the other copy's identically named pins.
  deixis-region-mark(pins: (pin("corner"), pin("edge")), layer: "foreground",
    region-shape: (width: auto, height: auto, ..styles) => {
      [#metadata((scope: scope, width: width, height: height))<pin-shape>]
      deixis-rect-region(width: width, height: height, ..styles)
    })
  deixis-attach(scope: scope, prefix: "[", postfix: "]", padding: 0pt,
    pin-padding: (scan: 2pt), pins: (
      corner: (anchor: top + left), edge: (anchor: bottom + right),
    ))[
    #block(width: 120pt, height: 45pt)[
      #ticks.update(n => n + 1)#title
      #text("[scan]") #raw("[raw]")
    ]
  ]
  deixis-pin(<direct>, scope: scope, padding: none)
}
#deixis-pin("corner", padding: none)
#deixis-pin("repeat", padding: none)
#component[First component]
#deixis-pin("repeat", padding: none)
#deixis-block(inset: 8pt)[#component[Second component]]
#deixis-pin("named", scope: <diagram>, padding: none)
#deixis-pin("named", scope: "another", padding: none)
#deixis-pin(<mixed>, scope: <labels>, padding: none)
#deixis-pin("mixed", scope: "labels", padding: none)
#deixis-attach(prefix: none, scope: <labels>, pins: (
  (<corner>, (anchor: top + left)),
  (<edge>, (anchor: bottom + right)),
))[
  #block(width: 30pt, height: 12pt)[Pair.]
]
#context {
  let index = _deixis-pin-index()
  let scopes = query(<pin-component>).map(p => p.value)
  assert.eq(scopes.len(), 2)
  assert(scopes.first() != scopes.last())
  assert.eq(ticks.final(), 2)
  assert.eq(_deixis-pins-for(index, ("corner",)).len(), 1)
  assert.eq(_deixis-pins-for(index, ("scan",)).len(), 0)
  for scope in scopes {
    let target(name) = (name: name, scope: scope)
    let corners = _deixis-pins-for(index, (target("corner"), target("edge")))
    let bounds = _deixis-region-bounds(corners, 1)
    assert.eq(bounds.right - bounds.left, 120pt)
    assert.eq(bounds.bottom - bounds.top, 45pt)
    for name in ("direct", "raw", "scan") {
      assert.eq(_deixis-pins-for(index, (target(name),)).len(), 1)
    }
    assert.eq(_deixis-pins-for(index, (target("scan"),)).first().value.padding.left, 2pt)
    let shape = query(<pin-shape>).find(s => s.value.scope == scope)
    assert.eq((shape.value.width, shape.value.height), (120pt, 45pt))
  }
  assert.eq(_deixis-pins-for(index, ((name: "named", scope: "diagram"),)).len(), 1)
  assert.eq(_deixis-pins-for(index, ((name: <mixed>, scope: "labels", select: "all"),)).len(), 2)
  assert.eq(_deixis-pins-for(index, ((name: "mixed", scope: <labels>, select: "first"),)).len(), 1)
  let mixed-corners = _deixis-pins-for(index, ((name: <corner>, scope: "labels"), (name: "edge", scope: <labels>)))
  let mixed-bounds = _deixis-region-bounds(mixed-corners, 1)
  assert.eq(mixed-bounds.right - mixed-bounds.left, 30pt)
  assert.eq(mixed-bounds.bottom - mixed-bounds.top, 12pt)
  let repeats = _deixis-pins-for(index, ("repeat",))
  assert.eq(repeats.len(), 2)
  assert.eq(_deixis-pins-for(index, (<repeat>,)).map(p => p.location()), repeats.map(p => p.location()))
  for (choice, expected) in (("first", repeats.first()), ("last", repeats.last())) {
    assert.eq(_deixis-select-pins(index, (name: "repeat", select: choice)).first().location(), expected.location())
  }
  assert.eq(_deixis-pins-for(index, ("repeat", (name: "repeat", select: "first"), "repeat")).len(), 2)
  assert.eq(_deixis-pins-for(index, ((name: "repeat", select: "all"),)).len(), 2)
}
