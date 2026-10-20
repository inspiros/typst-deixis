#import ("@preview/touying:" + sys.inputs.at("touying-version", default: "0.8.0")): *
#import themes.simple: simple-theme, slide
#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#import "../../src/core/references.typ": _deixis-reference-index, _deixis-reference-target, _deixis-reference-sites

#let kind = sys.inputs.at("kind", default: "inset")
#let mark = sys.inputs.at("mark", default: "inline")
#let covered = sys.inputs.at("cover", default: "off") == "on"
#let domain = sys.inputs.at("domain", default: "page")
#let frame-count = if domain == "page" { 6 } else { 2 }
#let frames = counter("test-annotation-frame")
// Host callbacks expose subslide before layout. The authored slide key keeps
// these native labels separate from labels belonging to other logical slides.
#let frame-id(name, frame) = label(repr(("identity-fixture", frame, str(name))))
#let bodies = state("frame-live-bodies", ())
#let edge(request) = {
  [#metadata((page: request.route.document.page, source: request.route.document.source-page,
    target: request.route.document.target-page))<frame-edge>]
  line(length: 9pt, stroke: rgb("125ba2"))
}
#let connector = (route: "straight-line", render: edge)

#show: simple-theme.with(aspect-ratio: "16-9", config-page(
  background: deixis-page-overlay(layer: "background"), foreground: deixis-page-overlay(),
))
#let annotations(body) = deixis-setup-notes(page-overlays: false, [
  #frames.step()
  #deixis-update-note-counter(0)
  #body
])
#let frame-content(self: none) = {
  let n = self.subslide
  let id = frame-id(<shared>, n)
  let content = {
    // Keep the geometry probe before deferred reference text. Its position must
    // not depend on link widths that settle after the final registry.
    deixis-pin(<socket>, scope: id, padding: none)
    let original() = {
      let options = (id: id, mark-type: mark)
      if mark == "phantom" { deixis-mark(..options) }
      else if mark == "region" { deixis-mark(..options, inline: true, layer: "background")[Original passage] }
      else { deixis-mark(..options)[Original passage] }
    }
    let repeated() = {
      let options = (of: id, mark-type: mark, occurrence: <again>)
      if mark == "phantom" { deixis-mark(..options) }
      else if mark == "region" { deixis-mark(..options, inline: true, layer: "foreground")[Reused passage] }
      else { deixis-mark(..options)[Reused passage] }
    }
    let body() = {
      let options = (of: id, backlink: true)
      let content = [#bodies.update(values => values + (n,))FrameBody]
      if kind == "inline" { deixis-inline-note-body(..options, inline: false, breakable: false, content) }
      else if kind == "endnote" { deixis-endnote-body(..options, content) }
      else if kind == "footnote" { deixis-footnote-body(..options, layer: "foreground", content) }
      else if kind == "margin" { deixis-margin-note-body(..options, layer: "foreground", side: right,
        width: 65pt, connector: connector, content) }
      else { deixis-inset-note-body(..options, layer: "foreground", width: 95pt, dx: 140pt, dy: 40pt,
        connector: connector, content) }
    }
    let order = ("mbr", "mrb", "bmr", "brm", "rmb", "rbm").at(n - 1)
    let components = {
      for action in order {
        if action == "m" { original() } else if action == "b" { body() } else { repeated() }
        [ Following text. ]
      }
      deixis-connect(from: (mark: id, occurrence: <again>), to: (body: id, point: "start"), connector: connector)
    }
    if covered and calc.odd(n) { hide(components) } else { components }
    deixis-print-endnotes()
    // Both native ref and package ref select this frame's computed native label.
    [Local: #deixis-ref(id) #ref(id).]
    if not (covered and calc.odd(n)) { [#link(id)[NativeLink].] }
    // These selectors deliberately cross frames; selection remains explicit.
    if not covered {
      let other = frame-id(<shared>, if n == frame-count { 1 } else { frame-count })
      [CrossFrame: #deixis-ref(other) #ref(other, form: "page", supplement: none) #link(other)[OtherFrame].]
    }
    // Local pin namespaces stay independent of note numbering/rendering scopes.
    deixis-connect(from: (pin: (name: <socket>, scope: id)), to: (body: id, point: "end"), connector: connector)
    // A literal document-wide identity can coexist with a same-named local one.
    if n == 1 { deixis-mark(id: <shared>, mark-type: "phantom", series: "global") }
    [Global: @shared.]
    [#metadata((frame: n, id: id, order: order, covered: covered and calc.odd(n)))<frame-case>]
  }
  if domain == "page" { content } else {
    deixis-block(thread: if domain == "thread" { "frame-stream" }, inset: (x: 80pt, y: 5pt), content)
  }
}
#let verify() = context {
  let sys = deixis-system.final()
  let index = _deixis-reference-index()
  let sites = _deixis-reference-sites()
  let cases = query(<frame-case>)
  assert.eq(frames.final(), (frame-count,))
  assert.eq(cases.len(), frame-count)
  let expected-live = range(1, frame-count + 1).filter(n => not covered or kind == "inline" or calc.even(n))
  assert.eq(bodies.final().sorted(), expected-live)
  let notes = deixis-query-notes()
  assert.eq(notes.len(), frame-count)
  assert.eq(_deixis-reference-target(index, <shared>).dest.page(), 1)
  for c in cases {
    let data = c.value
    assert.eq(c.location().page(), data.frame)
    assert.eq(query(data.id).len(), if data.covered and kind != "inline" { 0 } else { 1 })
    let reg = sys.registry.value.notes.at(sys.registry.value.id-index.at(str(data.id)))
    assert.eq(reg.count, if domain == "thread" { data.frame } else { 1 })
    if domain == "page" { assert.eq(reg.target-id, "page") }
    else if domain == "thread" { assert.eq(reg.target-id, repr(("thread", "frame-stream"))) }
    else { assert.ne(reg.target-id, "page") }
    let note = notes.find(note => note.id == data.id)
    assert.eq(note.marks.len(), 2)
    assert.eq(note.marks.map(m => m.loc.page()), (data.frame, data.frame))
    assert.eq(note.body.loc.page(), data.frame)
    if not data.covered { assert.eq(_deixis-reference-target(index, data.id).dest.page(), data.frame) }
    // Every frame has local package/native references plus its reused mark.
    assert(sites.at(reg.internal-id).len() >= 3)
  }
  let destinations = query(<deixis-body-destination>).map(m => m.location())
  if frames.get().first() == frame-count {
    [#metadata((destinations: destinations.map(loc => (
      page: loc.page(), x: loc.position().x.pt(), y: loc.position().y.pt(),
    ))))<test-result>]
  }
}
#slide(setting: annotations)[
  #set text(size: 10pt)
  Native control#std.footnote[NativeOne].
  #touying-fn-wrapper(frame-content)
  Tail control#std.footnote[NativeTwo].
  #pause
  Reveal one.
  #if domain == "page" [
    #pause
    Reveal two.
    #pause
    Reveal three.
    #pause
    Reveal four.
    #pause
    Reveal five.
  ]
  #meanwhile
  #verify()
]
