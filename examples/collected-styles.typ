#import "@preview/deixis:0.2.0": *
#set page(width: 430pt, height: auto, margin: 35pt)
#set text(size: 11pt)
#show: deixis-setup-notes

#text(size: 19pt, weight: "bold")[Collect Now, Render Later]

Endnote bodies keep the style of their declaration. The printer can collect
several independent series in one call.

#{
  set text(fill: rgb("176c63"))
  [A reading note#deixis-endnote(series: "reading", id: <reading>)[
    Read this as a short aside. Its color follows the declaration.
  ].]
}

#{
  set text(size: 10pt, fill: rgb("72522c"))
  [A smaller technical note#deixis-endnote(series: "technical", id: <technical>)[
    Both the marker and the body preserve their local typography.
  ].]
}

#deixis-print-endnotes()

For custom single renderers or containers, choose a stacked layout:

```typst
#deixis-print-endnotes(
  render-group: deixis-native-render-group,
)
```
