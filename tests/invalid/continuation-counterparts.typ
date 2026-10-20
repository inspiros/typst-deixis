#import "../../src/routing/continuations.typ": _deixis-counterpart-lookup, _deixis-continuation-site
#set page(width: 240pt, height: 160pt)
#let key = (kind: "duplicate")
#let record = (status: "resolved", page: 2, direction: "incoming", point: (80pt, 20pt), normal: (0, -1))
#_deixis-continuation-site(key, "foreground", record)
#_deixis-continuation-site(key, "foreground", record)
#context { let _ = (_deixis-counterpart-lookup(key, "foreground", "outgoing", 2))() }
