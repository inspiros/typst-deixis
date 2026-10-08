#import "core.typ": *
#import "render.typ": *
#import "endnote.typ": *

/// Chicago Notes & Bibliography endnote renderer.
///
/// Renders the note number and body as one paragraph:
///   1. Author, Title ..., 12.
///
/// The first line is indented 0.5in while continuation lines
/// return to the normal margin.
#let deixis-chicago-render-single(
  data,
  inner-width: auto,
  ..args,
) = {
  let body-style = data.at("body-style", default: it => it)
  let body-marker = deixis-generate-body-marker(data)

  let active-body = data.body

  if _deixis-should-render-backlinks(data) {
    active-body = [
      #active-body
      #h(0.25em)
      #super(deixis-generate-backlinks(data))
    ]
  }

  let container = data.at(
    "container-func",
    default: deixis-plain-container,
  )

  let final-note = body-style(
    block(
      width: inner-width,
      above: 0pt,
      below: 0pt,
      {
        set par(
          leading: 0.475em,
          spacing: 0pt,
          justify: false,
        )

        [
          #h(data.at("indent", default: 0.5in))
          #body-marker.
          #active-body
        ]
      },
    ),
  )

  container(
    final-note,
    ..data.at("styles", default: (:)),
  )
}

/// Chicago Notes & Bibliography endnote printer.
///
/// Notes are single-spaced, with 19pt between notes.
#let deixis-chicago-print-endnotes(
  target: 0,
  series: auto,
  after: none,
  before: none,
  backlink: auto,
  gap: 19pt,
  indent: 0.5in,
) = {
  deixis-print-endnotes(
    target: target,
    series: series,
    after: after,
    before: before,
    backlink: backlink,
    gap: gap,
    indent: indent,
    marker-style: it => it,
    render-single: deixis-chicago-render-single,
    render-group: (notes, gap: auto, ..args) => {
      for (i, note) in notes.enumerate() {
        let local-gap = note.at("gap", default: 14pt)

        v(
          if gap == auto { local-gap } else { gap },
          weak: true,
        )

        let render = note.at(
          "render-single",
          default: deixis-chicago-render-single,
        )

        render(note)
      }
    },
  )
}
