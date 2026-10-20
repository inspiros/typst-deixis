#import "../../src/lib.typ": *
#set page(width: 500pt, height: 420pt, margin: 60pt)
#show: deixis-setup-notes
#let priority = if sys.inputs.at("priority", default: "off") == "on" { 2 } else { auto }
#let covered = sys.inputs.at("cover", default: "off") == "on"
#let scoped = sys.inputs.at("target", default: "auto") == "named"
#let note-target = if scoped { <neutral-scope> } else { auto }

#let tag(key, body) = [#box(body)#label(key)]
#let cases = ()
// Block-targeted footnotes are native flow collections, not overlay declarations.
#for kind in if scoped { ("margin", "inset", "endnote") } else { ("margin", "inset", "footnote", "endnote") } {
  for layer in if kind == "endnote" { ("collected",) } else { ("foreground", "background") } {
    for mode in ("standalone", "before-mark", "after-mark", "wrapper") {
      if cases.len() > 0 { pagebreak() }
      let prefix = kind + "-" + layer + "-" + mode
      cases.push(prefix)
      let note-id(slot) = if mode == "standalone" { none } else { prefix + "-" + slot }
      let marks() = for slot in ("opening", "inline", "block", "paragraph", "repeat", "start", "tail") {
        deixis-inline-mark(id: note-id(slot), marker: none)[mark]
      }
      let declare-raw(slot) = {
        let id = note-id(slot)
        if mode == "wrapper" {
          if kind == "margin" { deixis-margin-note(of: id, target: note-target, z-index: priority, layer: layer)[Body.] }
          else if kind == "inset" { deixis-inset-note(of: id, target: note-target, z-index: priority, layer: layer, width: 45pt, dx: 20pt, dy: 120pt)[Body.] }
          else if kind == "footnote" { deixis-footnote(of: id, target: note-target, z-index: priority, layer: layer)[Body.] }
          else { deixis-endnote(of: id, target: note-target, z-index: priority)[Body.] }
        } else {
          if kind == "margin" { deixis-margin-note-body(of: id, target: note-target, z-index: priority, layer: layer)[Body.] }
          else if kind == "inset" { deixis-inset-note-body(of: id, target: note-target, z-index: priority, layer: layer, width: 45pt, dx: 20pt, dy: 120pt)[Body.] }
          else if kind == "footnote" { deixis-footnote-body(of: id, target: note-target, z-index: priority, layer: layer)[Body.] }
          else { deixis-endnote-body(of: id, target: note-target, z-index: priority)[Body.] }
        }
      }
      let declare(slot) = if covered { hide(declare-raw(slot)) } else { declare-raw(slot) }
      let sample(name, insert) = {
        insert("opening")
        [#tag(prefix + name + "origin", [AA])#insert("inline")#tag(prefix + name + "inline", [BB])]
        block[Top.]
        insert("block")
        block[#tag(prefix + name + "block", [Bottom.])]
        parbreak()
        insert("paragraph")
        insert("repeat")
        parbreak()
        [#tag(prefix + name + "paragraph", [Last.])]
        block[Top.]
        [#insert("start")#tag(prefix + name + "start", [Start.])]
        insert("tail")
        block[#tag(prefix + name + "tail", [Tail.])]
      }
      if mode in ("after-mark", "wrapper") { marks() }
      grid(columns: (170pt, 170pt), gutter: 10pt,
        sample("base", slot => []), sample("notes", declare))
      if mode == "before-mark" { marks() }
    }
  }
}
#if scoped { deixis-block(id: <neutral-scope>)[] }
#context {
  for prefix in cases {
    let origin(name) = query(label(prefix + name + "origin")).first().location().position()
    let baseline = origin("base")
    let annotated = origin("notes")
    assert.eq(baseline.page, annotated.page)
    assert.eq(baseline.y, annotated.y, message: prefix + ": leading declaration displaced the cell")
    for slot in ("origin", "inline", "block", "paragraph", "start", "tail") {
      let base = query(label(prefix + "base" + slot)).first().location().position()
      let notes = query(label(prefix + "notes" + slot)).first().location().position()
      assert(calc.abs((notes.x - annotated.x) - (base.x - baseline.x)) < 0.01pt,
        message: prefix + ": unexpected inline whitespace at " + slot)
      assert(calc.abs((notes.y - annotated.y) - (base.y - baseline.y)) < 0.01pt,
        message: prefix + ": unexpected paragraph/block displacement at " + slot)
    }
  }
  [#metadata(cases.len())<test-result>]
}
