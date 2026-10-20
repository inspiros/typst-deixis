#import "../../src/lib.typ": *
#show: deixis-setup-notes
#place(top + left, dx: 50pt, dy: 40pt, deixis-pin("a"))
#place(top + left, dx: 160pt, dy: 90pt, deixis-pin("b"))
#deixis-connect(from: (pin: "a"), to: (pin: "b"), connector: (via: ((pin: "missing"),)))
