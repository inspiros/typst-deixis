#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#import "../../src/core/references.typ": _deixis-reference-sites
#set page(width: 580pt, height: 430pt, margin: (x: 110pt, y: 40pt))
#show: deixis-setup-notes
#let ticks = state("explicit-bodies", 0)
#let body = [#ticks.update(n => n + 1)One live body.]
#let painter(name, request) = {
  let doc = request.route.document
  assert.eq(text.size, 16pt)
  assert.eq(request.heads.mark != none, request.route.has-start and not doc.is-incoming)
  assert.eq(request.heads.body != none, request.route.has-end and not doc.is-outgoing)
  [#metadata((name: name, document: doc, heads: (request.heads.mark != none, request.heads.body != none),
    drawable: (request.route.has-start, request.route.has-end),
    shaft: request.shaft, segments: request.route.segments))<explicit-route>]
}
#let connector(name, layer: "foreground") = (route: "curve", layer: layer,
  heads: (mark: "triangle", body: "circle"), render: painter.with(name))
#{
  set text(size: 16pt)
  // Both declarations precede the original, repeated occurrence, and live body.
  deixis-connect(from: <shared>, to: (body: <shared>), connector: connector("primary"))
  deixis-connect(from: (mark: <shared>, occurrence: <later>), to: <shared>,
    connector: connector("repeat", layer: "background") + (ports: (mark: right, body: left)))
  deixis-inline-mark(id: <shared>)[Original source]
  deixis-inset-note-body(of: <shared>, connector: none,
    layer: "foreground", width: 90pt, dx: 120pt, dy: 80pt)[#body]
  v(60pt)
  deixis-mark(of: <shared>, occurrence: <later>)[Repeated passage]
  deixis-mark(of: <forward>, occurrence: <far>)[A forward repeated source]
  deixis-connect(from: (mark: <forward>, occurrence: <far>), to: <forward>,
    connector: connector("far-repeat", layer: "background"))
  // A body need not own this source's annotation. Standalone destinations work.
  deixis-margin-note-body(id: <standalone>, layer: "background", side: left, width: 90pt)[#body]
  deixis-connect(from: (mark: <shared>, occurrence: <later>), to: <standalone>, connector: connector("other-body"))
  // Disabled declarations neither draw nor require their endpoint geometry.
  deixis-connect(from: <unknown>, to: <unknown>, connector: none)
  pagebreak()
  deixis-inline-mark(id: <forward>)[Forward source]
  deixis-inset-note-body(of: <backward>, connector: none, width: 95pt,
    layer: "background", placement: it => place(top + right, it))[#body]
  deixis-connect(from: <forward>, to: <forward>, connector: connector("forward"))
  deixis-connect(from: <backward>, to: <backward>, connector: connector("backward", layer: "background"))
  pagebreak()
  [No continuation is painted on this intermediate page.]
  pagebreak()
  deixis-inline-mark(id: <backward>)[Backward source]
  deixis-inset-note-body(of: <forward>, connector: none, width: 95pt, layer: "flow",
    dx: 120pt, dy: 80pt)[#body]
}
#context {
  assert.eq(ticks.final(), 4)
  assert.eq(query(<deixis-rendered-start>).len(), 4)
  assert.eq(deixis-system.final().registry.value.notes.len(), 4)
  let shared = deixis-system.final().registry.value.id-index.at("shared")
  assert.eq(_deixis-reference-sites().at(shared).len(), 1)
}
