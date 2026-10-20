#import "@preview/deixis:0.2.0": *
#set page(width: 460pt, height: 500pt, margin: (left: 30pt, right: 100pt, y: 30pt))
#show: deixis-setup-notes
#let kind = sys.inputs.at("kind", default: "inset")
#let paint(name, searched, r) = {
  assert.eq(r.route.at("search", default: none) != none, searched)
  [#metadata(name)<scoped-note-painted>]
  deixis-render-connector(r)
}
#let body(name, searched) = {
  let options = (route: if searched { "orthogonal" } else { "curve" },
    radius: if searched { 0pt } else { 3pt }, render: paint.with(name, searched))
  if kind == "inset" {
    deixis-inset-note-body(of: name, layer: "foreground", width: 65pt, connector: options,
      placement: x => place(top + left, dx: 190pt, dy: 110pt, x))[Body]
  } else {
    deixis-margin-note-body(of: name, width: 65pt, connector: options)[Body]
  }
}
// Forward body attachments capture their declaration scope, not the later mark.
#body("outside", false)
#deixis-routing[
  #body("outer-one", true)
  #deixis-routing(policy: "manual")[#body("manual", false)]
  #deixis-routing(policy: "avoid")[#body("avoid", true)]
  #body("outer-two", true)
]
#block[
  #show: deixis-routing.with(policy: "avoid")
  #body("show-avoid", true)
  #show: deixis-routing.with(policy: "manual")
  #body("show-manual", false)
  #show: deixis-routing.with(policy: "separate")
  #body("show-separate", true)
]
#for name in ("outside", "outer-one", "manual", "avoid", "outer-two", "show-avoid", "show-manual", "show-separate") {
  deixis-mark(id: name)[Source]
}
#context {
  let paints = query(<scoped-note-painted>).map(m => m.value).sorted()
  assert.eq(paints, ("avoid", "manual", "outer-one", "outer-two", "outside", "show-avoid", "show-manual", "show-separate"))
  let plans = query(<deixis-routing-plan>).map(m => m.value)
  assert.eq(plans.map(p => p.policy).sorted(), ("avoid", "avoid", "separate", "separate"))
  assert.eq(plans.filter(p => p.policy == "separate").map(p => p.members.len()).sorted(), (1, 2))
}
