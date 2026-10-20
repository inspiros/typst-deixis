#import "../../src/lib.typ": *
#show: deixis-setup-notes
#deixis-pin("a")
#deixis-connect(from: (pin: "a"), to: (pin: "b"), connector: (via: ((pin: "via"),)))
#pagebreak()
#deixis-pin("b")
#deixis-pin("via")
