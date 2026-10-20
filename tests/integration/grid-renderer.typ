#import "../../src/lib.typ": *
#import "../../src/render/body.typ": _deixis-render-context
#set page(width: 460pt, height: 390pt, margin: 40pt)
#show: deixis-setup-notes
#let ticks = state("grid-body-evaluations", 0)
#let records = ()
#for (i, size) in (10pt, 20pt).enumerate() {
  set text(size: size, fill: if i == 0 { blue } else { green })
  set par(leading: 9pt)
  context [#metadata((
    body-type: "endnote", internal-id: "grid-" + str(i),
    id: label("grid-" + str(i)), body-lbl: none, mark-lbl: none,
    marker-str: str(i + 1), render-context: _deixis-render-context(),
    marker-gap: 1em, gap: 8pt,
    body-marker-style: it => {
      assert.eq(text.size, size)
      super(it)
    },
    body-style: it => {
      assert.eq(par.leading, 9pt)
      assert.eq(text.size, size)
      it
    },
    body: [
      #context {
        assert.eq(text.size, size)
        assert(par.leading in (9pt, 0.65em))
        ticks.update(n => n + 1)
      }
      A grid body with preserved declaration typography.
    ],
  ))<grid-record>]
}
#for (i, (name, renderer)) in (("grid", deixis-grid-render-group),
  ("aligned", deixis-aligned-render-group), ("native", deixis-native-render-group)).enumerate() {
  if i > 0 { pagebreak() }
  context {
    assert.eq(deixis-grid-render-group(()), [])
    let data = query(<grid-record>).map(n => n.value).map(n => n + (
      internal-id: name + str(n.marker-str), id: label(name + str(n.marker-str)),
    ))
    renderer(data)
  }
}
#context {
  assert.eq(ticks.final(), 6)
  assert.eq(query(<deixis-rendered-start>).len(), 6)
  assert.eq(query(<deixis-rendered-end>).len(), 6)
  for name in ("grid", "aligned", "native") {
    for marker in ("1", "2") { assert.eq(query(label(name + marker)).len(), 1) }
  }
}
