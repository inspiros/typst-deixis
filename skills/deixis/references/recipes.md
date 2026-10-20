# Document Recipes

Each fenced example is a complete document. Use only the relevant recipe; page
geometry is illustrative. The maintained skill check compiles every snippet.

## Footnoted Paper With A Running Header

Native outlines and the plain header preserve heading text without registering
annotations twice. Keep the heading words outside the note call to preserve PDF
bookmark text. Page footer typography/spacing is native.

```typst
#import "@preview/deixis:0.2.0": *
#set page(width: 160mm, height: 190mm, margin: 20mm, header: context {
  let previous = query(selector(heading).before(here()))
  if previous.len() > 0 { emph(deixis-plain(previous.last().body)) }
})
#set text(size: 10pt)
#set footnote.entry(gap: 0.6em)
#show: deixis-setup-notes

#outline()
= A Method#deixis-footnote(id: <method>)[A shared explanation.]
The result follows from #deixis-mark(of: <method>)[the same method].
See @method.

#pagebreak()
= Discussion
The header can repeat the previous heading without creating its note again.
Another claim#deixis-footnote[An independent explanation.] follows.
```

## Margin-Noted Essay With Connectors

Leave enough right margin for bodies. A repeated mark shares its body but needs
an explicit connection when another edge is desired. The occurrence selector
names that second passage without creating a second annotation.

```typst
#import "@preview/deixis:0.2.0": *
#set page(width: 180mm, height: 190mm,
  margin: (left: 20mm, right: 60mm, y: 20mm))
#set text(size: 10pt)
#show: deixis-setup-notes
#deixis-set(palette: (rgb("3B6D9A"), rgb("387C69")))

= Reading An Argument
A #deixis-margin-note(id: <claim>, side: right, width: 45mm,
  connector: (route: "right-angle", heads: "stealth"),
  backlink: true,
)[central claim][One explanation beside both passages.]
anchors the discussion.

#v(12mm)
#deixis-mark(of: <claim>, occurrence: <again>)[A related passage returns to the same explanation.]
#deixis-connect(from: (mark: <claim>, occurrence: <again>), to: <claim>,
  connector: (route: "curve", heads: "stealth"))

See @claim for the explanation.
```

## Final Copy Without Editorial Notes

Write comments with `deixis-comment` (a margin note in the `"review"` series)
and omit that series at creation; real citations stay in their own series.
Conditionally remove references to omitted comments too.

```typst
#import "@preview/deixis:0.2.0": *
#set page(margin: (right: 45mm))
#show: deixis-setup-notes
#deixis-set(omit: (series: ("review",)))

A #deixis-comment(author: "Ada", status: "open")[provisional claim][Check this wording.]
needs evidence#deixis-footnote[A source retained in the final copy.].
```

## Touying Reveal

Let the theme own both page hooks and install setup with `page-overlays: false`
inside the slide setting. Content after the pause reveals with its annotation;
the hidden frame retains its semantic counter. Avoid reusing a public ID across
subslides directly. If shared named notes are needed, construct frame-local
labels in a pre-layout Touying callback using its subslide value, then use the
same label for each declaration/consumer on that frame.

```typst
#import "@preview/touying:0.8.0": *
#import themes.simple: simple-theme, slide
#import "@preview/deixis:0.2.0": *
#show: simple-theme.with(aspect-ratio: "16-9", config-page(
  background: deixis-page-overlay(layer: "background"),
  foreground: deixis-page-overlay(),
))
#let annotations(body) = deixis-setup-notes(page-overlays: false, [
  #deixis-update-note-counter(0)
  #body
])

#slide(setting: annotations)[
  = Explain An Idea In Stages
  The first idea is visible immediately.
  #pause
  A new point#deixis-footnote[The explanation appears with the new point.]
  appears with its note.
]
```
