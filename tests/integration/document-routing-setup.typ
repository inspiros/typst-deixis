#import "../../src/lib.typ": *
#set page(width: 300pt, height: 180pt, margin: 20pt)
#show: deixis-setup-notes
#show: deixis-routing
#let pair() = {
  deixis-connect(from: (node: <a>), to: (node: <b>))
  place(top + left, dx: 0pt, dy: 40pt, deixis-attach(id: <a>, rect(width: 30pt, height: 20pt)))
  place(top + left, dx: 180pt, dy: 40pt, deixis-attach(id: <b>, rect(width: 30pt, height: 20pt)))
}
#pair()
#pagebreak()
#set page(foreground: text[Host Decoration])
#show: deixis-setup-notes
#pair()
#context {
  let plans = query(<deixis-routing-plan>).map(m => m.value)
  assert.eq(plans.map(p => p.page).sorted(), (1, 2))
  assert(plans.all(p => p.plan.routes.len() == 1))
}
