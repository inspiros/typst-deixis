#import "@preview/deixis:0.2.0": *
#set page(width: 360pt, height: 270pt, margin: 20pt)
#set text(size: 10pt)
#show: deixis-setup-notes
#show: deixis-routing.with(spacing: 28pt, clearance: 1pt, max-detour: 50%)
= Giving Neighbouring Lines Room

#let card(id, x, y, body) = place(top + left, dx: x, dy: y,
  deixis-attach(id: id, rect(width: 45pt, height: 18pt, inset: 2pt,
    radius: 2pt, fill: white, stroke: luma(170) + 0.5pt, body)))
#card(<a>, 10pt, 65pt)[Input A]
#card(<b>, 250pt, 65pt)[Output A]
#card(<c>, 10pt, 89pt)[Input B]
#card(<d>, 250pt, 89pt)[Output B]
#deixis-connect(from: (node: <a>), to: (node: <b>), connector: (
  heads: "triangle", stroke: blue + 1pt))
#deixis-connect(from: (node: <c>), to: (node: <d>), connector: (
  heads: "triangle", stroke: orange + 1pt))

#v(125pt)
The large spacing makes the neighbouring middle outlets too close. The
`"separate"` policy may choose another permitted side to give the lines room,
within the detour allowance. Cards stay fixed.

An exact percentage or pin fixes its socket. Choose `"avoid"` to keep successful
preferred sockets without connector-separation repair; `"manual"` follows native
geometry without automatic search.
