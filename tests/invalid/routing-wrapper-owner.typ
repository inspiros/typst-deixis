#import "../../src/lib.typ": *
#set page(width: 360pt, height: 240pt, margin: 25pt)
#show: deixis-setup-notes
#show: deixis-routing.with(policy: "avoid")
#deixis-connect(from: (pin: <start>), to: (body: <shared>))
#place(top + left, dx: 10pt, dy: 100pt, deixis-pin(<start>, padding: 0pt))
// Equal spelling grants no ownership of a foreign containing avoidance frame.
#place(top + left, dx: 220pt, dy: 80pt)[
  #deixis-attach(id: "shared")[
    #pad(10pt)[#deixis-inline-note-body(id: <shared>, breakable: false)[Body]]
  ]
]
