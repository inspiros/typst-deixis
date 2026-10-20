#import "@preview/deixis:0.2.0": *
#set page(width: 320pt, height: 200pt, margin: 18pt)
#set text(size: 10pt)
#show: deixis-setup-notes

= Inline Asides

The garden was full of
#deixis-inline-note[apricity][the warmth of the sun in winter]
on that pale afternoon, and the path smelled of
#deixis-inline-note(inline-mode: "underline", marker: none)[petrichor][rain on dry earth]
after the storm.

A longer explanation can follow the line instead:
#deixis-inline-note(inline: false)[callout][A callout block keeps a longer explanation out of the sentence.]
