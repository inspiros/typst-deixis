#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#set page(width: 500pt, height: 360pt, margin: 35pt)
#show: deixis-setup-notes
#let policy = sys.inputs.at("policy", default: "manual")
#show: deixis-routing.with(policy: policy)
#deixis-set(palette: (blue, orange))
#let paint(expected, r) = {
 assert.eq(r.route.document.accent, expected)
 assert.eq(r.stroke.paint, if expected == none { rgb("496579") } else { expected })
 [#metadata(expected)<edge-accent>]
 deixis-render-connector(r)
}
// Edge declarations precede original marks, live destination frames and pins.
#deixis-connect(from: <a>, to: <b>, connector: (render: paint.with(orange)))
#deixis-connect(from: <a>, to: (pin: <p>), connector: (render: paint.with(blue)))
#deixis-connect(from: (pin: <p>), to: <b>, connector: (render: paint.with(orange)))
#deixis-connect(from: (pin: <p>), to: (pin: <q>), connector: (render: paint.with(none)))
#deixis-mark(id: <a>)[One]
#v(35pt)
#deixis-inset-note(id: <b>, width: 90pt, dx: 170pt, dy: 30pt, connector: none)[Two][Body]
#place(top + left, dx: 100pt, dy: 130pt, deixis-pin(<p>, padding: 0pt))
#place(top + left, dx: 230pt, dy: 220pt, deixis-pin(<q>, padding: 0pt))
#let verify() = {
 assert.eq(query(<edge-accent>).map(n=>n.value), (orange, blue, orange, none))
 assert.eq(deixis-system.final().palette-counts.values().sum(), 2)
 true
}
