#import "@preview/deixis:0.2.0": *
#set page(width: 560pt, height: 390pt, margin: (left: 35pt, right: 145pt, y: 30pt))
#set text(size: 11pt)
#show: deixis-setup-notes

= Automatic Annotation Colors

#deixis-set(palette: (rgb("3B6D9A"), rgb("387C69"), rgb("9A663F")))

Each annotation takes one accent. Its mark, marker and connector share it;
reading text keeps the document's color.

#for i in range(4) {
  v(20pt)
  deixis-margin-note(id: "note" + str(i), width: 110pt, side: right,
    connector: (route: "orthogonal", radius: 3pt))[
    Passage #(i + 1)
  ][Detail #(i + 1): a short explanation.]
}

#v(15pt)
#deixis-mark(of: "note0")[The first passage again] keeps its accent automatically.

#pagebreak()
= The Original Owns The Accent

// Start a fresh cycle for the next originals. The earlier note stays blue.
#deixis-set(palette: (rgb("387C69"), rgb("9A663F")))

#deixis-inset-note-body(of: <forward>, width: 130pt, dx: 190pt, dy: 30pt,
  connector: (route: "orthogonal", radius: 3pt))[This body precedes its original.]

#deixis-mark(id: <forward>)[A forward declaration]

The body still receives the original's accent.

#v(65pt)
#deixis-inset-note(width: 130pt, dx: 190pt, dy: 0pt,
  connector: (route: "orthogonal", radius: 3pt))[The next annotation][The second color.]

#v(65pt)
#deixis-mark(of: "note0")[The earlier passage] keeps the first page's blue.

#v(15pt)
`palette: none` disables coloring for later originals. Local styles can override
individual borders, fills and marker styles.
