#import "../../src/lib.typ": *
#show: deixis-setup-notes
#deixis-pin("a")
#deixis-pin(<a>)
#deixis-connect(from: (pin: (name: "a", select: "all")), to: (pin: (name: "a", select: "first")))
