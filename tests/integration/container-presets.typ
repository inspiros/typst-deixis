#import "../../src/lib.typ": *
#import "../../src/core/config.typ": _deixis-resolve-typed-param
#import "../../src/render/body.typ": _deixis-resolve-container
#set page(width: 600pt, height: 480pt, margin: (left: 55pt, right: 145pt, y: 35pt))
#set text(size: 10pt)
#show: deixis-setup-notes
#let names = ("plain", "rect", "alert", "stripe", "tinted")
#let ticks = state("preset-bodies", 0)
#let bodies = ()
#let audit(data, ..args) = {
  assert("_deixis-origins" not in data.styles)
  show rect: it => {
    if not data.at("disable-links", default: false) {
      [#metadata((id: data.id, stroke: it.stroke, fill: it.fill,
        radius: it.radius, inset: it.inset))<preset-frame>]
    }
    it
  }
  if not data.at("disable-links", default: false) {
    [#metadata((id: data.id, accent: data.accent, styles: data.styles,
      container: data.container-func))<preset-renderer>]
  }
  deixis-native-render-single(data, ..args)
}
#deixis-set(render-single: audit, margin-layout: "exact")
#for palette in (none, (rgb("387C69"),)) {
  deixis-set(palette: palette)
  for name in names {
    if bodies.len() > 0 { pagebreak() }
    let prefix = name + if palette == none { "-default" } else { "-palette" }
    text(size: 18pt, weight: "bold", name + if palette == none { " / Default Accent" } else { " / Palette Accent" })
    for kind in ("margin", "inset", "inline", "footnote") {
      let id = prefix + "-" + kind
      bodies.push(id)
      let body = [#ticks.update(n => n + 1)#name #kind body.]
      let selected = if sys.inputs.at("counterparts", default: "names") == "functions" and name in ("plain", "rect", "alert") {
        _deixis-resolve-container(name)
      } else { name }
      let opts = (id: id, container-func: (body: selected))
      if kind == "margin" { [Margin#deixis-margin-note(..opts, side: right, width: 115pt, body).] }
      else if kind == "inset" { [Inset#deixis-inset-note(..opts, width: 180pt, body).] }
      else if kind == "inline" { deixis-inline-note-body(..opts, inline: false, body) }
      else { [Footnote#deixis-footnote(..opts, body).] }
      v(25pt)
    }
  }
}
#pagebreak()
// Names resolve to the very same existing public functions, including scopes.
#for (name, func) in (("plain", deixis-plain-container), ("rect", deixis-rect-container), ("alert", deixis-alert-container)) {
  assert.eq(_deixis-resolve-container(name), func)
  assert.eq(_deixis-resolve-typed-param(none, (body: name), "container-func", "footnote"), func)
  let resolved = _deixis-resolve-container(name)
  context assert.eq(measure(func[Same body.]), measure(resolved[Same body.]))
}
#deixis-set(palette: none, container-func: (margin-note: (body: "stripe"), inset-note: (body: "tinted")))
#deixis-margin-note(id: "scoped-margin", side: right, width: 115pt)[Scoped stripe.]
#deixis-inset-note(id: "scoped-inset", width: 180pt)[Scoped tint.]
#deixis-set(container-func: (body: "tinted"))
#deixis-inline-note-body(id: "scoped-component")[Component-scoped tint.]
#for name in ("stripe", "tinted") {
  deixis-inline-note-body(id: name + "-override", container-func: name,
    stroke: (body: (left: red + 3pt, rest: none)), fill: (body: yellow), radius: (body: 7pt),
    container-args: (inset: 11pt, outset: 2pt))[Explicit overrides.]
  deixis-inline-note-body(id: name + "-none", container-func: name,
    stroke: none, fill: none, radius: 0pt)[Explicit none.]
}
#deixis-inline-note-body(id: "stroke-tint", container-func: "tinted", stroke: purple)[Stroke paint supplies the tint.]
#deixis-inline-note-body(id: "weight-tint", container-func: "tinted", stroke: 2pt)[A stroke without paint uses the default accent.]
#deixis-inline-note-body(id: "gradient-tint", container-func: "tinted", stroke: gradient.linear(red, blue))[Gradient stroke paint.]
// Endnote printer overrides bypass the ordinary typed option resolver.
#deixis-endnote(id: "printed", container-func: "plain")[Printer stripe.]
#deixis-print-endnotes(render-group: deixis-native-render-group, container-func: _deixis-resolve-container("stripe"))
#context {
  assert.eq(ticks.final(), 40)
  assert.eq(query(<deixis-rendered-start>).len(), 51)
  assert.eq(query(<deixis-rendered-end>).len(), 51)
  let renders = query(<preset-renderer>)
  let frames = query(<preset-frame>)
  for id in bodies {
    let render = renders.find(r => r.value.id == id).value
    assert.eq(render.container, _deixis-resolve-container(id.split("-").first()))
    let start = query(<deixis-rendered-start>).find(r => r.value.id == id)
    let end = query(<deixis-rendered-end>).find(r => r.value.id == id)
    assert.eq(start.location().page(), end.location().page())
    assert(end.location().position().y >= start.location().position().y)
    assert.eq(query(label(id)).len(), 1)
    if id.starts-with("stripe") or id.starts-with("tinted") {
      let frame = frames.find(f => f.value.id == id).value
      let accent = if "palette" in id { rgb("387C69") } else { rgb("496579") }
      if id.starts-with("stripe") {
        assert.eq(frame.stroke.left.paint, accent)
        assert.eq(frame.stroke.left.thickness, 2pt)
        assert.eq(frame.stroke.right, none)
        assert.eq(frame.radius, 0pt)
        assert.eq(frame.fill, accent.transparentize(94%))
      } else {
        assert.eq(frame.fill, accent.transparentize(90%))
        assert.eq(frame.stroke, none)
      }
    }
  }
  for name in ("stripe", "tinted") {
    let frame = frames.find(f => f.value.id == name + "-override").value
    assert.eq(frame.stroke.left.paint, red)
    assert.eq(frame.stroke.left.thickness, 3pt)
    assert.eq(frame.fill, yellow)
    assert.eq(frame.inset, 11pt)
    assert.eq(frame.radius, 7pt)
    let empty = frames.find(f => f.value.id == name + "-none").value
    assert.eq(empty.fill, none)
    assert.eq(empty.stroke, none)
  }
  assert.eq(frames.find(f => f.value.id == "stroke-tint").value.fill, purple.transparentize(90%))
  assert.eq(frames.find(f => f.value.id == "weight-tint").value.fill, rgb("496579").transparentize(90%))
  assert.eq(frames.find(f => f.value.id == "gradient-tint").value.fill, gradient.linear(red, blue).sample(50%).transparentize(90%))
  for (id, name) in (("scoped-margin", "stripe"), ("scoped-inset", "tinted"), ("scoped-component", "tinted"), ("printed", "stripe")) {
    assert.eq(renders.find(r => r.value.id == id).value.container, _deixis-resolve-container(name))
  }
  [#metadata((bodies: bodies.len(), live: query(<deixis-rendered-start>).len(), frames: frames.len(),
    geometry: bodies.map(id => {
      let start = query(<deixis-rendered-start>).find(r => r.value.id == id)
      let end = query(<deixis-rendered-end>).find(r => r.value.id == id)
      (id: id, start: start.location().position(), end: end.location().position())
    })))<test-result>]
}
