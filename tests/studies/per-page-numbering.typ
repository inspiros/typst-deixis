// Experimental display markers, not a supported per-page numbering API.
#import "../../src/lib.typ": *
#set page(width: 300pt, height: 280pt, margin: 25pt)
#set text(size: 10pt)
#show: deixis-setup-notes
#let n = int(sys.inputs.at("n", default: "40"))
#let local = sys.inputs.at("local", default: "true") == "true"
#let forward = sys.inputs.at("forward", default: "false") == "true"
#let symbols = sys.inputs.at("symbols", default: "false") == "true"
#let page-marker(id, series) = context {
  let originals = query(<study-original>)
  let origin = originals.find(m => m.value.id == id)
  if origin != none {
    let preceding = originals.slice(0, originals.position(m => m.value.id == id) + 1)
      .filter(m => m.value.series == series and m.location().page() == origin.location().page())
    let count = preceding.len()
    [#metadata((id: id, count: count, page: origin.location().page()))<study-marker>]
    numbering(if symbols { "*" } else { "1" }, count)
  }
}
#let note(i, series: "notes") = {
  let id = label("study-" + str(i))
  [#metadata((id: id, series: series))<study-original>]
  deixis-footnote(id: id, series: series,
    marker: if local { page-marker(id, series) } else { auto },
    numbering: if symbols { "*" } else { "1" },
  )[Explanation #i.]
}
#if forward [A forward use#deixis-mark(of: <study-0>).]
#for i in range(n) [
  A naturally paginated paragraph #i#note(i). #lorem(12)
  #parbreak()
]
// A reused mark on a later page keeps the original's displayed marker.
#pagebreak()
A later use#deixis-mark(of: <study-0>).
#context {
  let originals = query(<study-original>)
  let markers = query(<study-marker>).map(m => m.value)
  assert.eq(originals.len(), n)
  if local {
    for o in originals {
      let same = originals.filter(m => m.value.series == o.value.series
        and m.location().page() == o.location().page())
      let expected = same.position(m => m.value.id == o.value.id) + 1
      let observed = markers.filter(m => m.id == o.value.id)
      assert(observed.len() >= 2)
      assert(observed.all(m => m.count == expected and m.page == o.location().page()))
    }
  }
  [#metadata((pages: here().page(), originals: originals.len(),
    markers: markers.len(), restart_pages: originals.map(m => m.location().page()).dedup().len()))<study-result>]
}
