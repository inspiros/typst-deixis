#set page(width: 300pt, height: auto, margin: 0pt)

#import "../src/lib.typ": *
#show: deixis-setup-notes

#import "demo.typ": show-demo
#show: show-demo

```preview
//| sandbox-mode: "inline", height: 200pt, margin: (x: 2cm, rest: 1em)

#lorem(10)
#deixis-inline-mark(id: <note1>, marker: lorem(2))
#lorem(10)
#deixis-inline-mark(id: <note2>)[This is a marked text].
#lorem(10)

#deixis-footnote-body(id: <note1>)[Note 1.]
#deixis-footnote-body(id: <note2>)[Note 2.]
```
