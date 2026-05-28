#set page(width: 300pt, height: 240pt, margin: (x: 2.5cm, rest: 1cm))

#import "@preview/deixis:0.1.0": *
#show: deixis-setup-notes
#show raw: set text(size: 0.85em)

#deixis-set(container-func: (margin-note: rect))

Update default parameters with ```typst #deixis-set```:
#deixis-margin-note[A simple margin note.]
- ```typc stroke: green```
  #deixis-set(stroke: green)
  #deixis-margin-note[This affects all subsequent notes.]
- ```typc stroke: (margin-note: blue)```
  #deixis-set(stroke: (margin-note: blue))
  #deixis-margin-note[This affects only margin notes.]
- ```typc stroke: (body: teal)```
  #deixis-set(stroke: (body: teal))
  #deixis-margin-note[][This affects all notes' bodies.]
- ```typc stroke: (margin-note: (body: maroon))```
  #deixis-set(stroke: (margin-note: (body: maroon)))
  #deixis-margin-note[][This affects only margin notes' bodies.]
