#import "../../src/lib.typ": *
#set page(width: 300pt, height: 200pt, margin: 20pt)
#show: deixis-setup-notes
#show: deixis-routing
#let mode = sys.inputs.at("mode", default: "fixed-point")
#let options = (if mode == "fixed-pin" { (ports: (mark: (pin: <socket>, side: right))) }
  else if mode == "fixed-side" { (ports: (mark: right)) }
  else if mode == "visit" { (via: ((relative-to: "page", offset: (60pt, 70pt)),)) }
  else if mode == "fixed-split" { (via: (("split", 50pt),)) }
  else { (ports: (mark: (side: right, at: 50%))) })
#deixis-connect(from: (node: <a>), to: (node: <b>), connector: options)
#place(top + left, dx: 0pt, dy: 40pt, deixis-attach(id: <a>, pins: (socket: (anchor: right)),
  rect(width: 30pt, height: 20pt)))
#if mode == "fixed-split" {
  place(top + left, dx: 55pt, dy: 145pt, deixis-attach(behavior: "avoid", rect(width: 20pt, height: 35pt)))
  [First Page]
  pagebreak()
} else {
  place(top + left, dx: 30pt, dy: if mode == "fixed-side" { 36pt } else { 45pt },
    deixis-attach(behavior: "avoid", rect(width: 20pt, height: if mode == "fixed-side" { 28pt } else { 10pt })))
}
#place(top + left, dx: 200pt, dy: 80pt, deixis-attach(id: <b>, rect(width: 30pt, height: 20pt)))
