#import "../../src/lib.typ": *
#set page(width: 520pt, height: 360pt, margin: (x: 105pt, y: 35pt))
#show: deixis-setup-notes
#let mark-style(it) = [Original #it]
#let later-mark(it) = [Later Mark #it]
#let early-body(it) = [Early Body #it]
#let later-body(it) = [Later Body #it]
#let local-body(it) = [Local Body #it]
#let checked = state("configuration-marker-checks", ())
#let live = state("configuration-marker-bodies", 0)
#let render(n, ..args) = {
  let expected = if n.data.mode == "body" { local-body }
    else if n.data.order == "forward" { early-body } else { later-body }
  assert.eq((n.body-marker-style)([1]), expected([1]))
  [#checked.update(ids => ids + (n.id,))#deixis-native-render-single(n, ..args.named())]
}
#let kinds = ("inline", "footnote", "endnote", "margin", "inset")
#let expected-ids = ()
#for (i, kind) in kinds.enumerate() {
  for order in ("forward", "backward") {
    for mode in ("inherit", "mark", "body") {
      if expected-ids.len() > 0 { pagebreak() }
      let id = kind + "-" + order + "-" + mode
      expected-ids.push(label(id))
      // Each adapter uses its body's declaration defaults, independently of
      // the original's captured marker callback, even for forward attachment.
      deixis-set(marker-style: (mark: mark-style, body: early-body), render-single: render,
        render-group: deixis-native-render-group)
      let original() = deixis-mark(..if calc.rem(i, 3) == 2 { () } else { ([Source],) }, id: id,
        mark-type: ("inline", "region", "phantom").at(calc.rem(i, 3)),
        ..if calc.rem(i, 3) == 1 { (inline: true, layer: "background") } else { (:) },
        data: (mode: mode, order: order))
      let body() = {
        let style = if mode == "mark" { (mark: later-mark) }
          else if mode == "body" { (body: local-body) } else { auto }
        let args = (of: id, marker-style: style)
        let content = [#live.update(n => n + 1)Destination.]
        if kind == "inline" { deixis-inline-note-body(..args, content) }
        else if kind == "footnote" { deixis-footnote-body(..args, content) }
        else if kind == "endnote" { deixis-endnote-body(..args, content) }
        else if kind == "margin" { deixis-margin-note-body(..args, width: 80pt, side: right, content) }
        else { deixis-inset-note-body(..args, layer: "foreground", width: 90pt, dy: 65pt, content) }
        [Native allocation anchor.]
      }
      if order == "forward" { body() } else { original() }
      deixis-set(marker-style: (mark: later-mark, body: later-body))
      if order == "forward" { original() } else { body() }
      deixis-print-endnotes()
    }
  }
}
#context {
  assert.eq(live.final(), 30)
  assert.eq(checked.final().map(str).sorted(), expected-ids.map(str).sorted())
  assert.eq(query(<deixis-rendered-start>).len(), 30)
}
