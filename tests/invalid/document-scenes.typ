#import "../../src/lib.typ": *
#let mode = sys.inputs.at("mode", default: "selector-mix")
#show: body => if mode == "setup" { body } else { deixis-setup-notes(body) }
#if mode != "setup" {
  deixis-inset-note(id: <n>, width: 60pt, connector: none)[Original][Body]
  deixis-mark(of: <n>, occurrence: <empty>, marker: none)
  deixis-region-mark(of: <n>, occurrence: <region>, pins: (<p1>, <p2>))
  deixis-endnote-body(id: <unprinted>)[Unprinted]
  deixis-inline-note-body(id: <unframed>, inline: true)[Unframed Body]
}
#deixis-pin(<p1>, padding: 0pt)
#deixis-pin(<ambiguous>, padding: 0pt)
#deixis-pin(<ambiguous>, padding: 0pt)
#hide[#deixis-pin(<hidden>)]
#pagebreak()
#deixis-pin(<p2>, padding: 0pt)
#context {
  let b = (left: 1pt, top: 1pt, right: 10pt, bottom: 10pt)
  let spec = if mode == "selector-mix" { (pin: <p1>, body: <n>) }
    else if mode == "literal-mix" { (pin: <p1>, bounds: b) }
    else if mode == "field" { (pin: <p1>, point: "start") }
    else if mode == "occurrence-field" { (body: <n>, occurrence: <a>) }
    else if mode == "missing" { (body: <missing>) }
    else if mode == "mark-missing" { (mark: <missing>) }
    else if mode == "occurrence" { (mark: <n>, occurrence: <missing>) }
    else if mode == "empty-mark" { (mark: <n>, occurrence: <empty>) }
    else if mode == "body-page" { (body: <n>, page: 2) }
    else if mode == "mark-page" { (mark: <n>, page: 2) }
    else if mode == "page-zero" { (pin: <p1>, page: 0) }
    else if mode == "page-none" { (pin: <p1>, page: none) }
    else if mode == "page-bool" { (pin: <p1>, page: true) }
    else if mode == "point" { (body: <n>, point: "middle") }
    else if mode == "body-unprinted" { (body: <unprinted>, point: "start") }
    else if mode == "body-collected" { (body: <unprinted>) }
    else if mode == "body-unframed" { (body: <unframed>) }
    else if mode == "pin-missing" { (pin: <missing>) }
    else if mode == "pin-ambiguous" { (pin: <ambiguous>) }
    else if mode == "pin-page" { (pin: <p1>, page: 2) }
    else if mode == "pins-type" { (pins: <p1>) }
    else if mode == "pins-empty" { (pins: ()) }
    else if mode == "pins-pages" { (pins: (<p1>, <p2>)) }
    else if mode == "region-page" { (mark: <n>, occurrence: <region>) }
    else if mode == "region-outside" { (mark: <n>, occurrence: <region>, page: 5) }
    else if mode == "padding" { (pin: <p1>, padding: 50%) }
    else if mode == "hidden-padding" { (pin: <hidden>, padding: 50%) }
    else if mode == "padding-key" { (pin: <p1>, padding: (bogus: 2pt)) }
    else if mode == "padding-reversed" { (pins: (<p1>,), padding: -10pt) }
    else if mode == "point-avoid" { (pin: <p1>, behavior: "avoid") }
    else { (pin: <p1>) }
  let scene = deixis-routing-scene(nodes: (spec,))
}
