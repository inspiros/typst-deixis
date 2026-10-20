#import "../../src/lib.typ": *
#set page(width: 500pt, height: 330pt, margin: 80pt)
#show: deixis-setup-notes
#let painter(expected, request) = {
  assert.eq(request.stroke.paint, expected)
  [#metadata((paint: request.stroke.paint, layer: request.route.document.layer,
    bounds: request.route.document.nodes.body.bounds))<explicit-settings-route>]
}
#deixis-inset-note(id: <n>, width: 95pt, layer: "foreground", connector: none,
  dx: 100pt, dy: 90pt, placement: none)[Source][Single destination]
#deixis-set(connector: (connection: (route: "curve", layer: "background", render: painter.with(blue))),
  stroke: (connection: blue), radius: (connection: 3pt))
#deixis-connect(from: <n>, to: <n>)
#deixis-set(connector: (connection: (route: "orthogonal", layer: "foreground", render: painter.with(green))),
  stroke: (connection: green))
#deixis-connect(from: <n>, to: <n>)
#deixis-set(stroke: red)
// Explicit local options override connection defaults, not body metadata.
#deixis-connect(from: <n>, to: <n>, connector: (route: "straight-line", stroke: purple, render: painter.with(purple)))
