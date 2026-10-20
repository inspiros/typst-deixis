#import "@preview/touying:0.8.0": *
#import themes.simple: simple-theme, slide
#import "@preview/deixis:0.2.0": *

#show: simple-theme.with(aspect-ratio: "16-9", config-colors(primary: rgb("235c70")), config-page(
  background: deixis-page-overlay(layer: "background"),
  foreground: deixis-page-overlay(),
))
#let annotations(body) = deixis-setup-notes(page-overlays: false, [
  #deixis-update-note-counter(0)
  #body
])

#slide(setting: annotations)[
  #text(size: 25pt, weight: "bold", fill: rgb("235c70"))[Reveal The Explanation With The Idea]
  #v(0.7em)
  Notes can stay on screen.#deixis-footnote[This note is present in both frames.]

  #pause
  #v(0.6em)
  Consider a #deixis-inset-note(
    mark-type: "region",
    inline: true,
    layer: (
      mark: "background",
      body: "foreground",
    ),
    width: 190pt,
    dx: 300pt, dy: 40pt,
    fill: rgb("e8f3f6"),
    stroke: rgb("235c70"),
    connector: (
      route: "curve",
      ports: (
        mark: "right",
        body: "left",
      ),
      heads: "triangle",
    ),
  )[new idea][
    Its highlight, connector,
    and explanation appear
    together.
  ]

  #v(0.5em)
  Footnotes reveal together with their marks.#deixis-footnote(layer: "foreground")[This entry appears only in the second frame.]
]
