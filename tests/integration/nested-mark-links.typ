// Painted marker bounds and both directions of PDF navigation are checked by
// tests/run.py. The parameters also permit isolated nesting investigations.
#import "../../src/lib.typ": *
#set page(width: 620pt, height: 650pt, margin: (left: 40pt, right: 180pt, y: 40pt))
#show: deixis-setup-notes
#deixis-set(backlink: true)
#let host = sys.inputs.at("host", default: "endnote-grid")
#let kind = sys.inputs.at("kind", default: "margin")
#let mode = sys.inputs.at("mode", default: "box")
#let effects = state("nested-mark-body-effects", 0)
#let inner-body = [#effects.update(n => n + 1)Inner body.]
// Spacing isolates tokens in pdftotext's painted-word output. Distinct mark
// and body tokens let the checker associate each rectangle with its direction.
#let token(value) = it => [#h(3pt)#super(value)#h(3pt)]
#let styles = (mark: token("MARK"), body: token("BODY"))
#let nested = {
  if kind == "margin" {
    deixis-margin-note(data: (test: "nested-link"), marker-style: styles, inline-mode: mode,
      side: right, width: 100pt)[passage][#inner-body]
  } else if kind == "inset" {
    deixis-inset-note(data: (test: "nested-link"), marker-style: styles, inline-mode: mode,
      width: 105pt, dx: 12pt, dy: 70pt)[passage][#inner-body]
  } else if kind == "footnote" {
    deixis-footnote(data: (test: "nested-link"), marker-style: styles, inline-mode: mode,
      layer: "flow")[passage][#inner-body]
  } else if kind == "inline" {
    deixis-inline-note(data: (test: "nested-link"), marker-style: styles, inline-mode: mode,
      inline: false)[passage][#inner-body]
  } else if kind == "region" {
    deixis-region-mark(id: <inner>, inline: true, marker-style: token("MARK"))[passage]
    deixis-inline-note-body(of: <inner>, marker-style: token("BODY"))[#inner-body]
  } else if kind == "phantom" {
    deixis-phantom-mark(id: <inner>)
    deixis-inline-note-body(of: <inner>, marker-style: token("BODY"))[#inner-body]
  } else if kind == "reuse" {
    deixis-mark(id: <inner>, marker-style: token("MARK"), inline-mode: mode)[original]
    [ and ]
    deixis-mark(of: <inner>, occurrence: <again>, marker-style: token("REUSE"), inline-mode: mode)[reused]
    deixis-inline-note-body(of: <inner>, marker-style: token("BODY"))[#inner-body]
  } else { panic("Unknown nested mark kind: " + kind) }
}
#let outer-body = [Outer body with #nested.]
Outer#deixis-mark(id: <outer>).
#{
  if host.starts-with("endnote-") {
    deixis-endnote-body(of: <outer>, outer-body)
    if host == "endnote-native" { deixis-print-endnotes(render-group: deixis-native-render-group) }
    else if host == "endnote-chicago" { deixis-print-endnotes(render-single: deixis-chicago-render-single) }
    else { deixis-print-endnotes() }
  } else if host == "margin" {
    deixis-margin-note-body(of: <outer>, side: right, width: 150pt, outer-body)
  } else if host == "inset" {
    deixis-inset-note-body(of: <outer>, width: 300pt, dx: 15pt, dy: 30pt, outer-body)
  } else if host == "inline" {
    deixis-inline-note-body(of: <outer>, inline: false, outer-body)
  } else if host.starts-with("footnote-") {
    deixis-footnote-body(of: <outer>, layer: host.slice("footnote-".len()), outer-body)
  } else if host == "block" {
    deixis-block(id: <local>)[Local#deixis-footnote(layer: "flow", outer-body).]
    deixis-inline-note-body(of: <outer>)[Outer body.]
  } else if host == "comment" {
    deixis-comment(header: none, outer-body)
    deixis-inline-note-body(of: <outer>)[Outer body.]
  } else { panic("Unknown nested host: " + host) }
}
After host.
#let verify() = {
  assert.eq(effects.final(), 1)
  let bodies = query(<deixis-body-destination>).filter(m =>
    if kind in ("margin", "inset", "footnote", "inline") {
      m.value.data.at("test", default: none) == "nested-link"
    } else { m.value.id == <inner> })
  assert.eq(bodies.len(), 1)
  let body = bodies.first().value
  let point(loc) = {
    let p = loc.position()
    (page: p.page, x: p.x.pt(), y: p.y.pt())
  }
  // A live destination/span must appear exactly once despite host measurement.
  let spans = query(<deixis-rendered-start>).filter(m => m.value.internal-id == body.internal-id)
  assert.eq(spans.len(), 1)
  assert.eq(query(<deixis-rendered-end>).filter(m => m.value.internal-id == body.internal-id).len(), 1)
  let mark = query(body.mark-lbl)
  assert.eq(mark.len(), 1)
  let destinations = (
    body: point(bodies.first().location()),
    mark: point(mark.first().location()),
  )
  if kind == "reuse" {
    let again = query(<deixis-mark-occurrence>)
    assert.eq(again.len(), 1)
    let painted = query(<deixis-occurrence-corner>).find(m => m.value.corner == "tl")
    destinations.insert("reuse", point(painted.location()))
  }
  (kind: kind, host: host, mode: mode, destinations: destinations)
}
