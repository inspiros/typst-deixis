#import "../../src/lib.typ": *
#set page(width: 400pt, height: 300pt, margin: 70pt,
  background: [#metadata("native-background")<layer-event>],
  foreground: [#metadata("native-foreground")<layer-event>],
)
#show: deixis-setup-notes.with(
  background: [#metadata("user-background")<layer-event>],
  foreground: [#metadata("user-foreground")<layer-event>],
)
Layer composition.
#deixis-footnote[A real footnote.]
