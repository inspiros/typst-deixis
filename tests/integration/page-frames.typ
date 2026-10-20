#import "../../src/lib.typ": *
#set page(width: 400pt, height: 300pt, margin: 10%)
#show: deixis-setup-notes
First#deixis-margin-note[First page note.]
#pagebreak()
#counter(page).update(1)
#set page(width: 600pt, height: 400pt, margin: (x: 15%, y: 5%))
Second#deixis-margin-note[Second page note after resetting numbering.]
#context [#metadata((
  frames: query(<deixis-page-frame>).map(f => (
    page: f.value.page, width: f.value.width.pt(), height: f.value.height.pt(),
    left: f.value.margins.left.pt(), top: f.value.margins.top.pt(),
  )),
  note-pages: query(<deixis-rendered-start>).map(n => n.location().page()).sorted(),
))<test-result>]
