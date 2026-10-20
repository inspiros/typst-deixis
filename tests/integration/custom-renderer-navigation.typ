#import "../../src/lib.typ": *
#import "../../src/core/references.typ": _deixis-reference-index, _deixis-reference-target
#set page(width: 620pt, height: 760pt, margin: (x: 110pt, y: 35pt), numbering: "1",
  header: context [#metadata((page: here().page(), ids: deixis-query-notes(page: here().page()).map(n => n.id)))<renderer-page>])
#set text(size: 10pt)
#show: deixis-setup-notes
#let kind = sys.inputs.at("kind", default: "inset")
#let layer = sys.inputs.at("layer", default: "foreground")
#let live = state("custom-renderer-live", ())
#let uses = state("custom-renderer-uses", ())
#let painter(point, request) = [#metadata((point: point, document: request.route.document))<renderer-route>]
#let cases = ()
#for hook in ("none", "meta", "content", "full") {
  for paired in (true, false) {
    let id = label(hook + if paired { "-paired" } else { "-standalone" })
    cases.push((id: id, hook: hook, paired: paired))
    if paired {
      deixis-mark(id: id)[Original]
      deixis-mark(of: id, occurrence: <again>)[Reused]
      uses.update(xs => xs + (str(id),))
      if hook == "full" {
        for point in ("start", "end") {
          deixis-connect(from: (mark: id, occurrence: <again>), to: (body: id, point: point),
            connector: (route: "curve", render: painter.with(point)))
        }
      }
    }
  }
}
#pagebreak()
#let emit() = {
  for (index, item) in cases.enumerate() {
    let renderer(data, ..args) = {
      if item.hook in ("meta", "full") { deixis-generate-body-meta(data) }
      if item.hook in ("content", "full") { deixis-generate-body-content(data) }
      else { data.body }
    }
    let body = [#live.update(xs => xs + (str(item.id),))Custom #str(item.id).]
    let opts = (of: if item.paired { item.id } else { none },
      id: if item.paired { none } else { item.id }, render-single: renderer,
      target: if kind == "block-footnote" { 0 } else { auto })
    [Body declaration #str(item.id).]
    if kind == "inline" { deixis-inline-note-body(..opts, body) }
    else if kind in ("footnote", "block-footnote") { deixis-footnote-body(..opts, layer: layer, body) }
    else if kind == "endnote" { deixis-endnote-body(..opts, body) }
    else if kind == "margin" {
      // Explicit pins also anchor standalone margin bodies.
      let name = "anchor-" + str(index)
      deixis-pin(name)
      deixis-margin-note-body(..opts, layer: layer, side: right, width: 88pt, anchor-pin: name, body)
    } else { deixis-inset-note-body(..opts, layer: layer, width: 100pt, dx: 100pt, dy: 8pt, body) }
    [Following allocation anchor.]
    v(38pt)
  }
}
#if kind == "block-footnote" { deixis-block(id: "local", inset: 8pt, emit()) } else { emit() }
#if kind == "endnote" { deixis-print-endnotes(render-group: deixis-native-render-group) }

#pagebreak()
#for item in cases {
  let has-destination = item.hook in ("meta", "full")
  let located = has-destination or item.paired
  [#str(item.id): ]
  deixis-ref(item.id, supplement: element => {
    [#metadata((id: item.id, located: located,
      page: if located { element.location().page() } else { none }))<renderer-supplement>]
  })
  [ Page: ]
  deixis-ref(item.id, form: "page")
  if has-destination { [ #link(item.id)[Native body link]] }
  linebreak()
}
#deixis-note-outline(include-unpaired: true, title: none)
// The runner evaluates assertions after layout; they must not erase late
// supplement/page evidence during native convergence.
#context [#metadata(deixis-query-notes(include-unpaired: true))<renderer-catalogue>]
#let verify() = {
  assert.eq(live.final().sorted(), cases.map(c => str(c.id)).sorted())
  assert.eq(uses.final().len(), 4)
  let catalogue = query(<renderer-catalogue>).first().value
  assert.eq(catalogue.len(), 8)
  let pages = query(<renderer-page>)
  let index = _deixis-reference-index(details: true)
  let routes = query(<renderer-route>)
  assert.eq(routes.len(), 4)
  let destinations = ()
  for item in cases {
    let n = catalogue.find(n => n.id == item.id)
    let has-destination = item.hook in ("meta", "full")
    let has-span = item.hook in ("content", "full")
    assert.eq(n.marks.len(), if item.paired { 2 } else { 0 })
    assert.eq(n.body.dest != none, has-destination)
    assert.eq(n.body.start != none and n.body.end != none, has-span)
    let resolved = _deixis-reference-target(index, item.id)
    let expected = if has-destination { n.body.dest } else if item.paired { n.marks.first().dest } else { none }
    assert.eq(resolved.dest, expected)
    assert.eq(query(item.id).len(), if has-destination { 1 } else { 0 })
    let supplement = query(<renderer-supplement>).find(m => m.value.id == item.id).value
    assert.eq(supplement.page, if expected == none { none } else { expected.page() })
    // Standalone catalogue rows retain a declaration link when no live body
    // destination exists; package references intentionally have no such fallback.
    assert.eq(n.dest, if item.paired { n.marks.first().dest }
      else if has-destination { n.body.dest } else { n.body.loc })
    let reported = pages.filter(p => item.id in p.value.ids).map(p => p.value.page).dedup().sorted()
    assert.eq(reported, if has-span { range(n.body.start.page(), n.body.end.page() + 1) } else { () })
    if item.hook == "full" and item.paired {
      for route in routes {
        let point = if route.value.point == "start" { n.body.start } else { n.body.end }
        let pos = point.position()
        let node = route.value.document.nodes.body
        assert.eq(node.page, point.page())
        assert.eq((node.bounds.left, node.bounds.right), (pos.x, pos.x))
        assert.eq((node.bounds.top, node.bounds.bottom), (pos.y, pos.y))
      }
    }
    if expected != none {
      let pos = expected.position()
      destinations.push((page: pos.page, x: pos.x.pt(), y: pos.y.pt()))
    }
  }
  (destinations: destinations)
}
