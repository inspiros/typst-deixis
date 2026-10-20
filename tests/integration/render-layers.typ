#import "../../src/lib.typ": *
#set page(width: 600pt, height: 600pt, margin: 100pt)
#show: deixis-setup-notes

Native#deixis-footnote(layer: "flow", id: <native>)[Native footnote.]
Foreground#deixis-footnote(layer: "foreground", id: <foreground>)[Foreground footnote.]
Background#deixis-footnote(layer: "background", id: <background>)[Background footnote.]

#for (i, layer) in ("flow", "foreground", "background").enumerate() {
  v(35pt)
  [Mark #deixis-margin-note(layer: layer, side: right, dy: i * 20pt,
    connector: "right-angle")[#layer margin.]]
  deixis-inset-note(layer: layer, dx: 40pt, dy: 20pt, width: 90pt,
    connector: "straight-line")[#layer inset mark][#layer inset.]
}

#context [#metadata(query(<deixis-rendered-start>).map(n => (
  type: n.value.body-type,
  layer: n.value.at("layer", default: "flow"),
  page: n.location().page(),
)))<test-result>]
