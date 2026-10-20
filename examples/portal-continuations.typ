#import "@preview/deixis:0.2.0": *
#set page(width: 400pt, height: 250pt, margin: 28pt)
#set text(size: 10pt)
#show: deixis-setup-notes

= Small Portals Between Pages

A ring can show where a connector continues without a text badge.
Choose `continuation: none` when the break is clear already.

#place(top + left, dx: 245pt, dy: 100pt, deixis-pin(<out>, padding: 0pt))
#place(top + left, dx: 310pt, dy: 100pt, deixis-pin(<quiet-out>, padding: 0pt))
#place(top + left, dx: 225pt, dy: 85pt, [Portal])
#place(top + left, dx: 290pt, dy: 85pt, [No Marker])
#deixis-connect(from: (pin: <out>), to: (pin: <in>), connector: (
  route: "orthogonal", stroke: blue + 1pt, ports: (mark: bottom, body: top),
  heads: "stealth", continuation: (shape: "portal", link: "counterpart")))
#deixis-connect(from: (pin: <quiet-out>), to: (pin: <quiet-in>), connector: (
  route: "orthogonal", stroke: gray + 1pt, ports: (mark: bottom, body: top),
  heads: "stealth", continuation: none))

#pagebreak()
#block(width: 170pt)[
  = The Other End

  The ring stays small and transparent on both pages. Click it to jump to the
  opposite portal. The shaft stops at its rim.

  The arrowhead belongs to the real target.
]
#place(top + left, dx: 215pt, dy: 135pt, deixis-pin(<in>, padding: 0pt))
#place(top + left, dx: 310pt, dy: 135pt, deixis-pin(<quiet-in>, padding: 0pt))
#place(top + left, dx: 180pt, dy: 155pt, [Portal Target])
#place(top + left, dx: 280pt, dy: 155pt, [Quiet Target])
