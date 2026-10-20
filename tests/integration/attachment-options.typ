#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 520pt, height: 460pt, margin: (x: 105pt, y: 40pt))
#show: deixis-setup-notes
#let ticks = state("attachment-options-live", 0)
#let adapters = (
  (kind: "inline", body: deixis-inline-note-body, wrapper: none),
  (kind: "footnote", body: deixis-footnote-body, wrapper: deixis-footnote),
  (kind: "endnote", body: deixis-endnote-body, wrapper: deixis-endnote),
  (kind: "margin-note", body: deixis-margin-note-body, wrapper: deixis-margin-note),
  (kind: "inset-note", body: deixis-inset-note-body, wrapper: deixis-inset-note),
  (kind: "sidenote", body: deixis-sidenote-body, wrapper: deixis-sidenote),
)
#let container(body, token: none, ..style) = rect(..style.named(), [
  #metadata(token)<attachment-container>
  #body
])
#let options(kind) = if kind in ("margin-note", "sidenote") {
  (width: 75pt, side: right, connector: none)
} else if kind == "inset-note" {
  (width: 90pt, dx: 60pt, dy: 35pt, connector: none)
} else { (:) }
#let expected = ()

// Same thread, different block instances: a rendering owner alone is insufficient.
// Forward named scopes can synchronize counters without sharing rendering owners.
#for adapter in adapters {
  for entry in if adapter.wrapper == none { ("body",) } else { ("body", "wrapper") } {
    let call = if entry == "body" { adapter.body } else { adapter.wrapper }
    for (i, mode) in ("backward-thread", "forward-thread", "forward-scope", "explicit").enumerate() {
      if expected.len() > 0 { pagebreak() }
      let id = adapter.kind + "-" + entry + "-" + mode
      let owner = id + "-owner"
      let caller = id + "-caller"
      let threaded = mode.ends-with("thread")
      let target = if mode == "explicit" { 0 } else { auto }
      let render-id = if mode == "explicit" { repr(("block", caller)) } else if threaded { repr(("thread", id)) } else { repr(("block", owner)) }
      let inst-id = if mode == "explicit" { caller } else { owner }
      let layer = ("foreground", "background", "flow").at(calc.rem(i, 3))
      let body-options = options(adapter.kind) + (
        marker-style: s => text(blue, s), backlink: true,
        stroke: blue + 0.6pt, fill: blue.lighten(95%), radius: 2pt,
        container-func: container, container-args: (token: id),
      )
      if adapter.kind not in ("inline", "endnote") { body-options += (layer: layer) }
      if adapter.kind == "inline" {
        let removed = body-options.remove("container-func")
        let removed = body-options.remove("container-args")
        body-options += (inline: true, inline-mode: "underline")
      }
      let mark() = deixis-mark(id: id, series: id,
        target: if mode == "forward-scope" { owner } else { 0 })[Original]
      let owner-block() = deixis-block(id: owner,
        thread: if threaded { id } else { none },
        sync-counters-with: if threaded { auto } else { "page" }, inset: 5pt)[
        Owning block. #if mode != "forward-scope" { mark() }
      ]
      if mode == "backward-thread" or mode == "explicit" { owner-block() }
      if mode == "forward-scope" { mark() }
      deixis-block(id: caller, thread: if threaded { id } else { none }, inset: 5pt)[
        Calling block.
        #call(of: id, target: target, ..body-options)[#ticks.update(n => n + 1)One body.]
        Following text.
      ]
      if mode in ("forward-thread", "forward-scope") { owner-block() }
      if adapter.kind == "endnote" { deixis-print-endnotes(target: inst-id, render-group: deixis-native-render-group) }
      [#link(label(id))[Native body link.]]
      expected.push((id: id, kind: adapter.kind, target: render-id, instance: repr(("block", inst-id)),
        count-owner: if threaded { repr(("thread", id)) } else { "page" },
        original-instance: repr(("block", owner)), series: id, count: 1, layer: layer))
    }
  }
}

// Creation retains the current scope and each adapter's established series.
#for adapter in adapters.filter(a => a.wrapper != none) {
  for series in (auto, "custom") {
    pagebreak()
    let id = adapter.kind + "-create-" + repr(series)
    let actual-series = if series != auto { series }
      else if adapter.kind == "endnote" { "endnote" } else { "default" }
    deixis-block(id: id, inset: 5pt)[
      #(adapter.wrapper)(id: id, series: series, ..options(adapter.kind))[
        #ticks.update(n => n + 1)Created body.
      ]
      Following text.
      #if adapter.kind == "endnote" { deixis-print-endnotes() }
    ]
    expected.push((id: id, kind: adapter.kind, target: repr(("block", id)), instance: repr(("block", id)),
      count-owner: repr(("block", id)), original-instance: repr(("block", id)), series: actual-series, count: 1, layer: auto))
  }
}

// A standalone collection may choose a series without creating a counter.
#for adapter in adapters {
  pagebreak()
  let id = adapter.kind + "-standalone"
  (adapter.body)(id: id, series: "standalone", ..options(adapter.kind))[
    #ticks.update(n => n + 1)Standalone body.
  ]
  [Following text.]
  if adapter.kind == "endnote" { deixis-print-endnotes(series: "standalone") }
  [#link(label(id))[Native standalone body link.]]
  expected.push((id: id, kind: adapter.kind, target: "page", instance: "page",
    series: "standalone", count: none, layer: auto))
}
#context {
  assert.eq(expected.len(), 60)
  assert.eq(ticks.final(), expected.len())
  assert.eq(query(<deixis-rendered-start>).len(), expected.len())
  assert.eq(query(<attachment-container>).len(), 40)
  let sys = deixis-system.final()
  assert.eq(sys.registry.value.notes.len(), expected.len())
  assert.eq(sys.registry.value.pending-bodies.len(), 0)
  for e in expected {
    let kind = if e.kind == "sidenote" { "margin-note" } else if e.kind == "inline" { "inline-note" } else { e.kind }
    let bodies = query(label("deixis-" + kind)).filter(b => str(b.value.id) == e.id)
    assert.eq(bodies.len(), 1)
    let data = bodies.first().value
    assert.eq((data.target-id, data.inst-id, data.series, data.count),
      (e.target, e.instance, e.series, e.count))
    if e.layer != auto and kind not in ("inline-note", "endnote") {
      assert.eq(data.layer, if kind == "footnote" { "flow" } else { e.layer })
    }
    if e.count != none {
      let original = sys.registry.value.notes.at("id-" + e.id)
      assert.eq((original.count-id, original.inst-id, original.series, original.count),
        (e.count-owner, e.original-instance, e.series, e.count))
    }
    assert.eq(query(label(e.id)).len(), 1)
  }
  assert.eq(deixis-note-counter(series: "standalone"), 0)
  // Geometry assertions run after layout; observing all deferred destination
  // positions here feeds a dense forward-scope document back into convergence.
}
#let verify() = (destinations: query(<deixis-body-destination>).map(body => {
  let pos = body.location().position()
  (page: pos.page, x: pos.x.pt(), y: pos.y.pt())
}))
