#import "@preview/deixis:0.2.0": *
#set page(width: 480pt, height: 330pt, margin: 30pt, numbering: "1")
#set text(size: 10pt)
#show: deixis-setup-notes
#deixis-set(margin-layout: "exact", min-margin-width: 30pt)

= Notes Across A Block

Margin notes follow their passages. Footnotes collect at the block's end.

#deixis-block(breakable: true, inset: (x: 70pt, y: 10pt),
  stroke: rgb("8baab7"), radius: 4pt)[
  #for i in range(6) {
    [*Observation #(i + 1).* A longer discussion can continue on another page
    while its annotation stays beside the relevant passage.
    #deixis-margin-note(side: right, width: 58pt, dx: 4pt,
      marker: none, mark-align: bottom, container-func: deixis-rect-container,
      fill: rgb("eef5f8"), stroke: rgb("8baab7"),
      container-args: (inset: 3pt))[Passage #(i + 1).]
    #if calc.even(i) {
      deixis-footnote(series: "sources")[Source for observation #(i + 1).]
    }]
    v(16pt)
  }
]

The block, including its collected notes, has finished here.
