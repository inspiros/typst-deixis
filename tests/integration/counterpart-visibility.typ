#import "../../src/lib.typ": *
#set page(width: 360pt, height: 250pt, margin: 30pt)
#show: deixis-setup-notes
#let policy = sys.inputs.at("policy", default: "native")
#let mode = sys.inputs.at("mode", default: "dots")
#show: body => if policy == "native" { body } else { deixis-routing(policy: policy, body) }
#let marker(r) = {
  let other = (r.counterpart)()
  if other != none { [#metadata(other.page)<covered-pair>]; circle(radius: 2pt) }
}
#let options = (route: "orthogonal", radius: 0pt,
  continuation: if mode == "dots" { auto } else if mode == "none" { none } else { marker })
#let edge = deixis-connect(from: (pin: <a>), to: (pin: <b>),
  connector: if mode == "disabled" { none } else { options })
#if mode == "declaration" { hide(edge) } else { edge }
#let a = place(top + left, dx: 40pt, dy: 60pt, deixis-pin(<a>, padding: 0pt))
#if mode == "source" { hide(a) } else { a }
First Page
#pagebreak()
#let b = place(top + left, dx: 160pt, dy: 80pt, deixis-pin(<b>, padding: 0pt))
#if mode == "target" { hide(b) } else { b }
Second Page
#context {
  assert.eq(query(<deixis-continuation-site>).len(), 0)
  assert.eq(query(<covered-pair>).len(), 0)
}
