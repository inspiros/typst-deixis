#import "@preview/deixis:0.2.0": *
#set page(width: 420pt, height: 260pt, margin: (left: 30pt, right: 110pt, y: 30pt))
#set text(size: 10pt)
#show: deixis-setup-notes
#deixis-set(stroke: blue + 0.5pt, fill: blue.lighten(96%))
#let continuation(name, request) = {
  if request.peer != none {
    // Separate this example's labels below/above the shared page boundary.
    let offset = (int(name) - 2) * 8pt
    place(center + horizon, dy: if request.direction == "outgoing" { offset } else { -offset }, link(request.peer.destination,
      box(fill: white, inset: 2pt, text(size: 7pt,
        [#name: #if request.direction == "outgoing" { [To] } else { [From] } p. #request.peer-page]))))
  }
}
= Linked Page Continuations

#for i in range(5) {
  let name = str(i + 1)
  deixis-margin-note(width: 85pt, connector: (route: "polyline", continuation: continuation.with(name)),
    [Source #name], [#block(height: 55pt)[Explanation #name.]])
  parbreak()
}
#pagebreak()
= The Second Page
The incoming marker links to its original mark.
#pagebreak()
= The Final Page
The last body was placed here. Its source marker links directly to this page.
