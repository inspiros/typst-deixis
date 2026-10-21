#import "../../src/lib.typ": *

#set page(width: 430pt, height: 760pt, margin: 40pt)
#set text(size: 11pt)
#set par(leading: 13pt, spacing: 17pt, justify: false,
  first-line-indent: 9pt, hanging-indent: 3pt)
#show: deixis-setup-notes

// Inspect the actual linked marker, independently of the record's default
// marker style. The destination metadata remains outside this link.
#let plain(it) = {
  if type(it) == str { return it }
  if type(it) != content { return "" }
  if it.func() == text { return it.text }
  if it.has("children") { return it.children.map(plain).join() }
  if it.has("body") { return plain(it.body) }
  if it.has("child") { return plain(it.child) }
  ""
}
#show link: it => context {
  let dest = it.dest
  show text: t => context [#metadata((dest: dest, value: t.text,
    size: text.size))<chicago-link-text>#t]
  let body = plain(it.body)
  if body.ends-with(".") and body.len() <= 3 {
    assert.eq(measure(it.body).height, measure(text(body)).height,
      message: "Chicago note numbers must use the body text's full size.")
  }
  [#metadata((dest: it.dest, body: body, raw: it.body))<chicago-link>#it]
}

#let inherited() = context {
  assert.eq(par.leading, 13pt)
  assert.eq(par.spacing, 17pt)
  assert.eq(par.justify, false)
  assert.eq(text.size, 11pt)
  [#metadata(none)<chicago-inherited>]
}

= Per Print Call

First#deixis-endnote(id: <chicago-first>, series: "first", backlink: true)[#inherited()First line of a longer citation.#linebreak()
#box(width: 0pt)[#metadata(none)<chicago-continuation>]Continuation returns to the left margin.

#box(width: 0pt)[#metadata(none)<chicago-paragraph>]Another paragraph keeps its authored break.]
Second#deixis-endnote(id: <chicago-second>, series: "first")[#inherited()A second citation.]

// The default group must honor the custom single renderer, without requiring
// a second printer or an explicit render-group option.
#deixis-print-endnotes(series: "first", gap: 23pt,
  marker-style: it => super(it), render-single: deixis-chicago-render-single)

= Settings Wide

#deixis-set(render-single: (endnote: deixis-chicago-render-single),
  indent: (endnote: 18pt))
Configured#deixis-endnote(id: <chicago-settings>, series: "settings")[#inherited()A settings-wide citation.]
#deixis-print-endnotes(series: "settings")
#v(15pt)

Explicit#deixis-endnote(id: <chicago-explicit>, series: "explicit")[An explicitly indented citation.]
#deixis-print-endnotes(series: "explicit", indent: 0pt)
#v(15pt)

Unnumbered#deixis-endnote(id: <chicago-unnumbered>, series: "unnumbered", numbering: none)[#box(width: 0pt)[#metadata(none)<chicago-unnumbered-text>]An unnumbered explanation.]
#deixis-print-endnotes(series: "unnumbered")

#pagebreak()
= Configured Gap

// Equal one-line bodies isolate the group's inter-note gap from paragraph
// height. Comparing two gaps also avoids assuming a font's line metrics.
#for (name, gap) in (("near", 23pt), ("far", 47pt)) {
  deixis-endnote(id: label("chicago-" + name + "-one"), series: name)[Equal citation.]
  deixis-endnote(id: label("chicago-" + name + "-two"), series: name)[Equal citation.]
  deixis-print-endnotes(series: name, gap: gap)
}

#deixis-set(indent: (endnote: 0pt))
Custom#deixis-endnote(id: <chicago-custom>, series: "custom", numbering: none,
  marker: "X")[A custom marker with an explicit settings-wide zero indent.]
#deixis-print-endnotes(series: "custom")

Page one#deixis-endnote(id: <chicago-page-one>, series: "paged",
  numbering: (restart: "page", pattern: "1"))[A citation from the preceding page.]
#pagebreak()
= Page Local Markers

Page two#deixis-endnote(id: <chicago-page-two>, series: "paged",
  numbering: (restart: "page", pattern: "1"))[A citation from this page.]
#deixis-print-endnotes(series: "paged")

#context {
  let starts = query(<deixis-rendered-start>)
  let ends = query(<deixis-rendered-end>)
  assert.eq(starts.len(), 12)
  assert.eq(ends.len(), 12)
  assert.eq(query(<chicago-inherited>).len(), 3)
  let records = deixis-query-notes(include-types: "endnote")
  assert.eq(records.len(), 12)
  for n in records {
    assert(n.body.dest != none and n.body.start != none and n.body.end != none,
      message: "Chicago output must retain a destination and one complete live span.")
  }
  let note(id) = records.find(n => n.id == id)
  let close(a, b) = assert(calc.abs(a - b) < 0.01pt, message: repr((a, b)))
  // The destination precedes the marker, so its position proves there is no
  // extra markup space after the one first-line indent.
  close(note(<chicago-first>).body.dest.position().x, 40pt + 0.5in)
  close(query(<chicago-continuation>).first().location().position().x, 40pt)
  close(query(<chicago-paragraph>).first().location().position().x, 40pt)
  assert(query(<chicago-paragraph>).first().location().position().y
    > query(<chicago-continuation>).first().location().position().y)
  close(note(<chicago-settings>).body.dest.position().x, 58pt)
  close(note(<chicago-explicit>).body.dest.position().x, 40pt)
  close(note(<chicago-custom>).body.dest.position().x, 40pt)

  let links = query(<chicago-link>)
  for id in (<chicago-first>, <chicago-second>, <chicago-settings>, <chicago-explicit>) {
    let data = starts.find(n => n.value.id == id).value
    let marker = links.filter(n => n.value.dest == data.mark-lbl
      and n.value.body == data.marker-str + ".")
    assert.eq(marker.len(), 1,
      message: "Each numbered body needs one full-size marker plus period linked to its mark.")
  }
  let first = starts.find(n => n.value.id == <chicago-first>).value
  assert(links.any(n => n.value.dest == first.mark-lbl
    and n.value.raw == [#emoji.arrow.l.hook]),
    message: "Enabled backlinks must follow the body.")
  let unnumbered = starts.find(n => n.value.id == <chicago-unnumbered>).value
  assert.eq(unnumbered.marker-str, none)
  assert.eq(links.filter(n => n.value.dest == unnumbered.mark-lbl).len(), 0)
  close(note(<chicago-unnumbered>).body.dest.position().x,
    query(<chicago-unnumbered-text>).first().location().position().x)
  let glyphs = query(<chicago-link-text>)
  for (id, marker) in ((<chicago-custom>, "X."),
    (<chicago-page-one>, "1."), (<chicago-page-two>, "1.")) {
    let data = starts.find(n => n.value.id == id).value
    let painted = glyphs.filter(n => n.value.dest == data.mark-lbl)
    assert.eq(painted.map(n => n.value.value).join(), marker,
      message: "Custom and page-local markers must retain their displayed values.")
    assert(painted.all(n => n.value.size == 11pt))
  }
  let separation(name) = {
    (note(label("chicago-" + name + "-two")).body.start.position().y
      - note(label("chicago-" + name + "-one")).body.start.position().y)
  }
  close(separation("far") - separation("near"), 24pt)
}
