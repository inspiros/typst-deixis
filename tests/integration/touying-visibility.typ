#import ("@preview/touying:" + sys.inputs.at("touying-version", default: "0.8.0")): *
#import themes.simple: simple-theme, slide
#import "../../src/lib.typ": *
#import "../../src/core/visibility.typ": _deixis-metadata
#let kind = sys.inputs.at("kind", default: "footnote")
#let layer = sys.inputs.at("layer", default: "foreground")
#let mode = sys.inputs.at("mode", default: "pause")
#let cover = sys.inputs.at("cover", default: "hide")
#let edge-layer = if layer == "flow" { "foreground" } else { layer }
#show: simple-theme.with(aspect-ratio: "16-9",
  if cover == "tint" { config-methods(cover: utils.method-wrapper(text.with(fill: gray))) } else { (:) },
  config-page(
  margin: (x: 95pt, y: 30pt),
  background: deixis-page-overlay(layer: "background"), foreground: deixis-page-overlay(),
))
#let annotations(body) = deixis-setup-notes(page-overlays: false, [
  #deixis-update-note-counter(0)
  #deixis-set(render-group: (endnote: deixis-native-render-group))
  #body
])
#let swatch(color) = rect(width: 7pt, height: 7pt, fill: color, stroke: none)
#let render(data, ..args) = {
  if not data.at("disable-links", default: false) {
    [#_deixis-metadata((kind: kind,), <visibility-body-event>)]
  }
  swatch(rgb("a10b31"))
  deixis-native-render-single(data, ..args.named())
}
#let edge(request) = [
  #metadata((layer: request.route.document.layer))<visibility-edge-event>
  #swatch(rgb("125ba2"))
]
#let shape(..args) = {
  let a = args.named()
  [#metadata((width: a.width, height: a.height))<visibility-region-event>]
  swatch(rgb("2b8c43"))
}
#let note() = {
  counter("visibility-note").step()
  context {
    let id = "note-" + str(counter("visibility-note").get().first())
    let body = text(size: 9pt)[TargetBody]
    let connector = (route: "straight-line", layer: edge-layer, render: edge)
    if kind == "region" {
      deixis-region-mark(id: id, inline: true, layer: layer, region-shape: shape,
        z-index: 2)[TargetPassage]
    } else if kind == "repeat-region" {
      deixis-mark(of: "owner-" + str(counter("visibility-owner").get().first()), mark-type: "region", occurrence: "again",
        inline: true, layer: layer, region-shape: shape, z-index: 2)[TargetPassage]
    } else {
      deixis-mark(id: id)[TargetMark]
      if kind == "footnote" { deixis-footnote-body(of: id, layer: layer, render-single: render, body) }
      else if kind == "endnote" { deixis-endnote-body(of: id, render-single: render, body) }
      else if kind == "inline" { deixis-inline-note-body(of: id, inline: false, render-single: render, body) }
      else if kind == "margin" {
        deixis-margin-note-body(of: id, layer: layer, side: right, width: 85pt,
          render-single: render, connector: connector, body)
      } else {
        deixis-inset-note-body(of: id, layer: layer, width: 120pt,
          dx: if layer == "flow" { none } else { 200pt },
          dy: if layer == "flow" { none } else { 70pt },
          render-single: render, connector: connector, body)
      }
      [ Allocation anchor.]
    }
  }
}
#slide(setting: annotations)[
  Visible introduction.#std.footnote[NativeIntro]
  #if kind == "repeat-region" {
    counter("visibility-owner").step()
    context { deixis-mark(id: "owner-" + str(counter("visibility-owner").get().first()), mark-type: "phantom") }
  }
  #if mode == "pause" {
    [#pause #note()]
  } else if mode == "uncover" {
    uncover("2-")[#note()]
  } else if mode == "only" {
    only("2-")[#note()]
  } else if mode == "nested" {
    uncover("2-")[#hide[#note()]]
  } else {
    [#uncover("1")[#note()]#pause]
  }
  #meanwhile
  #deixis-print-endnotes()
  Visible tail.#std.footnote[NativeTail]
  #_deixis-metadata((control: true,), <visibility-outside>)
]
