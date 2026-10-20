#import "../../src/lib.typ": *
#set page(width: 360pt, height: 260pt, margin: 25pt)
#show: deixis-setup-notes
#let mode = sys.inputs.at("mode", default: "body")
#let layer = sys.inputs.at("layer", default: "foreground")
#let spec = (if mode == "body" { (body: <hidden>) }
  else if mode == "repeat" { (mark: <hidden>, occurrence: <again>) }
  else if mode == "region" { (mark: <hidden>, occurrence: <area>) }
  else { (mark: <hidden>) })
#show: deixis-routing.with(nodes: (spec,))
#hide[
  #deixis-inset-note(id: <hidden>, width: 65pt, connector: none)[Source][Hidden Body]
  #deixis-mark(of: <hidden>, occurrence: <again>)[Repeat]
  #deixis-mark(of: <hidden>, occurrence: <area>, mark-type: "region")[Area]
]
#place(top + left, dx: 10pt, dy: 110pt, deixis-pin(<a>, padding: 0pt))
#place(top + left, dx: 285pt, dy: 110pt, deixis-pin(<b>, padding: 0pt))
#deixis-connect(from: (pin: <a>), to: (pin: <b>), connector: (layer: layer,
  render: r => [#metadata(r.route.length)<node-hidden-length>]))
#let verify() = { assert.eq(query(<node-hidden-length>).map(m => m.value), (275pt,)) }
