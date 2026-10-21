#import "../../src/lib.typ": *
#set page(width: 740pt, height: 900pt, margin: (left: 45pt, right: 185pt, y: 35pt))
#set text(size: 11pt)
#show: deixis-setup-notes
#deixis-set(margin-layout: "exact", marker-style: it => [], stroke: (mark: none))
#text(size: 23pt, weight: "bold")[Body Container Presets]
#parbreak()
#text(fill: gray)[Inset bodies in the main column; margin bodies at right.]
#for (palette, heading) in ((none, "Default Accent"), ((rgb("387C69"),), "Palette Accent")) {
  deixis-set(palette: palette)
  v(8pt)
  text(size: 16pt, weight: "bold", heading)
  for name in ("plain", "rect", "alert", "stripe", "tinted") {
    parbreak()
    text(weight: "bold", name)
    deixis-inset-note(container-func: name, width: 260pt, dx: 100pt, dy: 2pt)[Inset aside with the #name preset.]
    deixis-margin-note(container-func: name, side: right, width: 155pt)[Margin aside with the #name preset.]
    v(24pt)
  }
}
#context {
  assert.eq(query(<deixis-rendered-start>).len(), 20)
  assert.eq(query(<deixis-rendered-end>).len(), 20)
}
