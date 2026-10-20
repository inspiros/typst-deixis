#import "@preview/deixis:0.2.0": *
#set page(width: 530pt, height: auto, margin: (left: 35pt, right: 150pt, y: 30pt))
#set text(size: 11pt)
#show: deixis-setup-notes

#text(size: 19pt, weight: "bold")[One Note, Different Marks]

Start by annotating #deixis-inline-mark(id: <idea>)[one idea].
#deixis-margin-note-body(of: <idea>, side: right, width: 110pt,
  dy: -8pt, connector: "straight-line", backlink: "multiple")[
  One number and one explanation serve every kind of mark.
]

#v(10pt)
A region can mark a related formula:
#deixis-mark(of: <idea>, mark-type: "region", inline: true,
  occurrence: <formula>, layer: "background", stroke: teal, fill: teal.lighten(92%))[$x^2 + y^2$].

#v(10pt)
#deixis-phantom-mark(of: <idea>, occurrence: <quiet>)This paragraph has an invisible
semantic mark, with its own return link.

A bare repeat remains inline: #deixis-mark(of: <idea>).

// Extra connections are deliberate; repetitions do not inherit the body's line.
#deixis-connect(from: (mark: <idea>, occurrence: <formula>), to: <idea>,
  connector: (route: "curve", stroke: teal, ports: (mark: right, body: left)))
