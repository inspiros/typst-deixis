#import "../../src/lib.typ": *
#set page(width: 260pt, height: auto, margin: 12pt)
#set text(size: 13pt)
#show: deixis-setup-notes

// BEGIN EXAMPLE
#deixis-block[
  #figure(caption: [Measurements.])[
    #table(columns: (1fr, 1fr),
      [Sample], [Result],
      [Control], [12.4],
      [Trial], [18.7#deixis-footnote(
        numbering: "a",
      )[Excludes one damaged sample.]],
    )
  ]
]
// END EXAMPLE
