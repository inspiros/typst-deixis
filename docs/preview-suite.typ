#set page(width: 300pt, height: auto, margin: 0pt)

#import "../src/lib.typ": *
#show: deixis-setup-notes

#import "demo.typ": show-demo
#show: show-demo

```preview
//| sandbox-mode: "inline", height: 200pt, margin: (x: 2cm, rest: 1em)

#lorem(10)
#deixis-margin-note[Test note.]
```
