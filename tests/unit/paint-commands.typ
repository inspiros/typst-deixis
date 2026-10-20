#import "../../src/render/commands.typ": *
#import "../../src/layout/margin.typ": _deixis-margin-batch-output
#let events = state("command-events", ())
#let painted(id, color) = {
  events.update(values => values + (id,))
  [#metadata(id)<command-painted>]
  place(top + left, dx: 80pt, dy: 80pt,
    rect(width: 35pt, height: 35pt, fill: color, stroke: none))
}
#let commands = (
  _deixis-paint-command("inset", "a", () => painted("a", rgb("123456"))),
  _deixis-paint-command("connection", "b", () => painted("b", rgb("234567")), priority: -2),
  _deixis-paint-command("margin", "c", () => painted("c", rgb("345678"))),
)
// Constructing and ordering output must never invoke callbacks. No live content
// is emitted by this unused custom batch, even with a deliberate failing hook.
#let unused = _deixis-margin-batch-output(
  (..args) => panic("Custom batch was invoked during preparation."),
  ((note-data: (internal-id: "x")), (note-data: (internal-id: "y"))),
  0pt, 180pt, 0pt, 200pt, 180pt, 0pt, 0pt, 1,
)
#assert.eq(unused.evidence, [])
#assert.eq(unused.commands.len(), 1)
#assert.eq(unused.commands.first().kind, "margin-batch")
#assert.eq(unused.commands.first().members, ("x", "y"))
#assert.eq(_deixis-order-paint-commands(unused.commands).len(), 1)
#let sorted = _deixis-order-paint-commands(commands)
#assert.eq(sorted.map(c => c.identity), ("b", "a", "c"))
#assert.eq(sorted.map(c => c.ordinal), (1, 0, 2))
#assert.eq(commands.map(c => c.identity), ("a", "b", "c"))
#set page(width: 200pt, height: 180pt, margin: 20pt,
  foreground: context _deixis-emit-paint-commands(commands))
Native flow remains here.
#context {
  assert.eq(events.final(), ("b", "a", "c"))
  assert.eq(query(<command-painted>).map(m => m.value), ("b", "a", "c"))
  assert.eq(query(<command-painted>).len(), 3)
}
