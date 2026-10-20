#import "../../src/lib.typ": *
#let mode = sys.inputs.at("mode", default: "type")
#let policy = sys.inputs.at("policy", default: "avoid")
#show: deixis-setup-notes
#let bounds = (left: 100pt, top: 30pt, right: 170pt, bottom: 120pt)
#let spec = (if mode == "type" { true }
  else if mode == "item" { (3,) }
  else if mode == "mix" { ((body: <n>, mark: <n>),) }
  else if mode == "field" { ((body: <n>, bogus: true),) }
  else if mode == "behavior" { ((body: <n>, behavior: "jump"),) }
  else if mode == "id" { ((body: <n>, id: 3),) }
  else if mode == "point" { ((body: <n>, point: "middle"),) }
  else if mode == "padding" { ((body: <n>, padding: 25%),) }
  else if mode == "padding-key" { ((body: <n>, padding: (bogus: 2pt)),) }
  else if mode == "pin" { ((pin: (name: <p>, extra: true)),) }
  else if mode == "pins" { ((pins: ()),) }
  else if mode == "page" { ((body: <n>, page: 0),) }
  else if mode == "unpaged" { ((bounds: bounds),) }
  else if mode == "bounds" { ((bounds: bounds + (left: 180pt), page: 1),) }
  else if mode == "count" { range(129).map(i => (body: <n>)) }
  else if mode == "missing" { ((body: <missing>),) }
  else if mode == "unframed" { ((body: <unframed>),) }
  else if mode == "owner-padding" { ((body: <n>, padding: 8pt),) }
  else if mode == "duplicate" { ((body: <n>), (body: <n>)) }
  else { ((body: <n>), (bounds: bounds, page: 1)) })
#deixis-routing(policy: policy, nodes: spec)[
  #if mode in ("missing", "unframed", "owner-padding", "duplicate", "foreign") {
    deixis-inline-note-body(id: <unframed>, inline: true)[No Frame]
    deixis-inset-note-body(id: <n>, connector: none, width: 70pt,
      placement: x => place(top + left, dx: 100pt, dy: 30pt, x))[Body]
    place(top + left, dy: 80pt, deixis-pin(<a>, padding: 0pt))
    deixis-connect(from: (pin: <a>), to: (body: <n>),
      connector: (ports: (body: left)))
  }
]
