#import "../../src/lib.typ": *
#set page(width: 300pt, height: 200pt, margin: 20pt)
#show: deixis-setup-notes
#show: deixis-routing.with(rounds: 0)
#let edge(size) = {
  set text(size: size)
  let paint(request) = {
    let route = request.route
    assert.eq(text.size, size)
    assert.eq(route.origin, (40pt + size, 100pt))
    let visit = (100pt - route.origin.first(), 4 * size - route.origin.last())
    assert(route.segments.any(s => s.start == visit or s.end == visit))
    [#metadata(size)<captured-size>]
    deixis-render-connector(request)
  }
  deixis-connect(from: (pin: <a>), to: (pin: <b>), connector: (
    ports: (mark: (pin: <a>, side: right, gap: 1em)),
    via: ((relative-to: "page", offset: (100pt, 4em)),), render: paint))
}
#edge(10pt)
#edge(20pt)
#place(top + left, dx: 20pt, dy: 80pt, deixis-pin(<a>, padding: 0pt))
#place(top + left, dx: 220pt, dy: 80pt, deixis-pin(<b>, padding: 0pt))
#context assert.eq(query(<captured-size>).map(m => m.value), (10pt, 20pt))
