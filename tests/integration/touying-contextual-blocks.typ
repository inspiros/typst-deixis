#import ("@preview/touying:" + sys.inputs.at("touying-version", default: "0.8.0")): *
#import themes.simple: simple-theme, slide
#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system, _deixis-layout-scopes
#let frames = counter("contextual-scope-frames")
#let live = state("contextual-scope-live", ())
#let kind = sys.inputs.at("kind", default: "inset")
#let nested = sys.inputs.at("nested", default: "off") == "on"
#show: simple-theme.with(aspect-ratio: "16-9", config-page(
  background: deixis-page-overlay(layer: "background"), foreground: deixis-page-overlay(),
))
#let annotations(body) = deixis-setup-notes(page-overlays: false, [#frames.step()#body])
#let note() = context {
  let frame = frames.get().first()
  let id = label("contextual-frame-" + str(frame))
  deixis-mark(of: id, occurrence: <first>)[Earlier reuse]
  let body = [#live.update(values => values + (frame,))DynamicBody]
  if kind == "footnote" { deixis-footnote-body(of: id, body) }
  else if kind == "margin" { deixis-margin-note-body(of: id, side: right, width: 60pt, body) }
  else { deixis-inset-note-body(of: id, layer: "foreground", width: 90pt, dx: 100pt, dy: 30pt, body) }
  deixis-mark(id: id)[Original]
}
#slide(setting: annotations)[
  #deixis-block(inset: (x: 70pt, y: 8pt), stroke: blue)[
    #if nested { deixis-block(inset: (x: 8pt, y: 4pt), note()) } else { note() }
  ]
  #pause
  Extra.
  #meanwhile
  #context {
    assert.eq(frames.final(), (2,))
    assert.eq(live.final().sorted(), (1, 2))
    assert.eq(deixis-system.final().registry.value.notes.len(), 2)
    assert.eq(deixis-system.final().stack, ())
    assert.eq(_deixis-layout-scopes.final().stack, ())
    assert.eq(query(<deixis-rendered-start>).len(), 2)
    for frame in (1, 2) {
      let id = label("contextual-frame-" + str(frame))
      assert.eq(query(id).first().location().page(), frame)
    }
  }
]
