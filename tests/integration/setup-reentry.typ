#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#import "../../src/core/references.typ": _deixis-reference-sites
#set text(size: 10pt)
#set heading(numbering: "1.")
#let mode = sys.inputs.at("mode", default: "foreground")
#let override = sys.inputs.at("footnotes", default: "overlay") == "overlay"
#let live = state("reentry-live", ())
// Native theme decoration is often contextual; bare context equality must not
// make it look like an already-installed Deixis compositor.
#let decoration(name) = context [#metadata(name)<setup-decoration>]
#set page(width: 460pt, height: 340pt, margin: (x: 90pt, y: 30pt),
  foreground: decoration("native-fg-0"), background: decoration("native-bg-0"))
#show: deixis-setup-notes.with(foreground: decoration("user-fg"), background: decoration("user-bg"),
  override-page-footnotes: override)
#let paint(r) = {
  [#metadata(r.route.document.page)<setup-connection>]
  deixis-render-connector(r)
}
#let notes(n) = {
  let content(name) = [#live.update(xs => xs + (name,))#name]
  let id = "m" + str(n)
  deixis-margin-note(id: label(id), side: right, width: 65pt,
    layer: if calc.odd(n) { "foreground" } else { "background" },
    connector: (route: "polyline", render: paint))[Margin][#content("Margin " + str(n))]
  parbreak()
  deixis-inset-note(id: label("i" + str(n)), width: 65pt, layer: if calc.odd(n) { "background" } else { "foreground" },
    placement: body => place(top + left, dx: 15pt, dy: 150pt, body))[Inset][#content("Inset " + str(n))]
  parbreak()
  [Footnote#deixis-footnote(id: label("f" + str(n)))[#content("Footnote " + str(n))]]
  parbreak()
  [Endnote#deixis-endnote(id: label("e" + str(n)))[#content("Endnote " + str(n))]]
  parbreak()
  [Reference: #ref(label(id)). Heading: @heading.]
}
= Setup Once <heading>
#notes(1)
#pagebreak()
#set page(foreground: decoration("native-fg-1")) if mode in ("foreground", "both")
#set page(background: decoration("native-bg-1")) if mode in ("background", "both")
#set page(foreground: none, background: none) if mode == "clear"
#show: deixis-setup-notes.with(foreground: decoration("user-fg"), background: decoration("user-bg"),
  override-page-footnotes: override)
= Restore Composition
#notes(2)
#pagebreak()
// Repeating setup without changing either layer must remain safe too.
#show: deixis-setup-notes.with(foreground: decoration("user-fg"), background: decoration("user-bg"),
  override-page-footnotes: override)
#show: deixis-setup-notes.with(foreground: decoration("user-fg"), background: decoration("user-bg"),
  override-page-footnotes: override)
= Reapply Twice
#notes(3)
#pagebreak()
#set page(width: 500pt, height: 400pt, header: decoration("header"), footer: decoration("footer"))
= Other Page Fields
#notes(4)
#deixis-print-endnotes()
#hide[#deixis-inset-note(id: <hidden>, width: 60pt, dx: 100pt, dy: 40pt, layer: "foreground")[Hidden][
  #context panic("Hidden body executed")
]]
#let verify() = {
  assert.eq(live.final().len(), 16)
  assert.eq(live.final().dedup().len(), 16)
  assert.eq(deixis-system.final().registry.value.notes.len(), 17)
  let frames = query(<deixis-page-frame>).map(f => f.value)
  assert.eq(frames.map(f => f.page), (1, 2, 3, 4))
  assert.eq(frames.map(f => f.width), (460pt, 460pt, 460pt, 500pt))
  let events = query(<setup-decoration>).map(m => (page: m.location().page(), name: m.value))
  for p in range(1, 5) {
    let actual = events.filter(e => e.page == p).map(e => e.name).sorted()
    let fg = if p == 1 { "native-fg-0" } else if mode in ("foreground", "both") { "native-fg-1" }
      else { "native-fg-0" }
    let bg = if p == 1 { "native-bg-0" } else if mode in ("background", "both") { "native-bg-1" }
      else { "native-bg-0" }
    let native = if p > 1 and mode == "clear" { () } else { (fg, bg) }
    assert.eq(actual, (native + ("user-fg", "user-bg") + if p == 4 { ("header", "footer") } else { () }).sorted())
  }
  assert.eq(query(<setup-connection>).map(m => m.value).sorted(), (1, 2, 3, 4))
  let sites = _deixis-reference-sites()
  for n in range(1, 5) {
    let uid = deixis-system.final().registry.value.id-index.at("m" + str(n))
    assert.eq(sites.at(uid).len(), 1)
  }
  let destinations = query(<deixis-body-destination>).map(m => m.location())
  assert.eq(destinations.len(), 16)
  (destinations: destinations.map(l => (page: l.page(), x: l.position().x.pt(), y: l.position().y.pt())), events: events)
}
#context { let _ = verify() }
