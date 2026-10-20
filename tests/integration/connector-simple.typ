#import "../../src/lib.typ": *
#import "../../src/core/state.typ": deixis-system
#import "../../src/core/connectors.typ": _deixis-connector-options
#set page(width: 520pt, height: 360pt, margin: (x: 100pt, y: 35pt))
#show: deixis-setup-notes

// Beginner calls need no ports, waypoint records, head factories, or callbacks.
A simple curve#deixis-margin-note(connector: "curve")[The default ports are automatic.]
#v(35pt)
An arrow#deixis-margin-note(connector: (route: "curve", heads: "stealth"))[One extra option adds an arrow.]
#v(35pt)
A route dictionary#deixis-margin-note(connector: (route: "orthogonal"))[The other connector fields are optional.]
#v(35pt)
#deixis-inset-note(layer: "foreground", dx: 120pt, dy: 25pt, width: 90pt,
  connector: "curve")[Inset][The same simple route works for inset notes.]
#v(35pt)
#deixis-set(connector: "curve")
Shared defaults#deixis-margin-note[This call inherits its connector.]
#v(30pt)
Disabled locally#deixis-margin-note(connector: none)[This call disables it.]

// A route name is shorthand for a record, also in deixis-set: repeated defaults
// merge field by field, and a note's own record merges over them.
#deixis-block[
  #deixis-set(connector: (route: "curve", heads: "stealth"))
  #deixis-set(connector: "polyline")
  #context {
    let sys = deixis-system.get()
    let merged = _deixis-connector-options(sys, "margin-note", auto)
    assert.eq((merged.route, merged.heads), ("straight-line", "stealth"))
    let local = _deixis-connector-options(sys, "margin-note", (heads: "bar"))
    assert.eq((local.route, local.heads), ("straight-line", "bar"))
    assert.eq(_deixis-connector-options(sys, "inset-note", "curve").heads, "stealth")
  }
]
#context {
  let bodies = query(<deixis-rendered-start>)
  assert.eq(bodies.len(), 6)
  assert(bodies.all(n => n.location().page() == 1))
  let kinds = bodies.map(n => n.value.body-type)
  assert.eq(kinds.filter(k => k == "margin-note").len(), 5)
  assert.eq(kinds.filter(k => k == "inset-note").len(), 1)
}
