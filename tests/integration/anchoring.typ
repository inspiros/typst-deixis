#import "../../src/lib.typ": *
#set page(width: 500pt, height: 500pt, margin: 80pt)
#show: deixis-setup-notes
#for (i, layer) in ("flow", "foreground", "background").enumerate() {
  v(60pt)
  let pin = "anchor-" + str(i)
  deixis-pin(pin, padding: 0pt)
  deixis-inset-note(layer: layer, anchor-pin: pin, width: 80pt,
    anchor: (mark: top + left, body: top + left), dx: 25pt, dy: 20pt,
    connector: "straight-line")[Mark][Two lines of anchored content.]
}
#context [#metadata(query(<deixis-inset-note>).map(n => {
  let data = n.value
  let pin = query(<deixis-pin>).find(p => p.value.name == data.anchor-pin).location().position()
  let top-port = query(data.dest-top-lbl).first().location().position()
  let bottom-port = query(data.dest-bot-lbl).first().location().position()
  let left-port = query(data.dest-left-lbl).first().location().position()
  (dx: (left-port.x - pin.x).pt(), dy: (top-port.y - pin.y).pt(),
    height: (bottom-port.y - top-port.y).pt())
}))<test-result>]
