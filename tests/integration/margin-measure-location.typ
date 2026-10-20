// Every page plans the preceding pages again. A renderer whose detached size
// depends on its location must still give all pages one consistent cascade:
// measuring at each planning page painted some bodies twice and lost others.
#import "../../src/lib.typ": *
#set page(width: 15cm, height: 9cm, margin: (left: 1.5cm, right: 4.5cm, y: 1.5cm))
#set text(size: 9pt)
#show: deixis-setup-notes
#let paged(data, ..args) = context block(width: 100%, height: 8pt * here().page(),
  fill: luma(220))[#data.marker-str p#here().page()]
#let n = 24
#for i in range(n) [
  Sentence #i #deixis-margin-note(render-single: paged)[term][Margin #i.] .
  #parbreak()
]
#context {
  let painted = query(<deixis-body-frame>).map(it => it.value.identity)
  assert.eq(painted.len(), n, message: "Each margin body must be placed once.")
  assert.eq(painted.dedup().len(), n, message: "No margin body may be placed twice.")
}
