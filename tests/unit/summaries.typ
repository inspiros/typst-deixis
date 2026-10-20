#import "../../src/render/summary.typ": _deixis-summary-text, _deixis-note-summary
#let updates = state("summary-unit-state", 0)
#assert.eq(_deixis-summary-text([Plain *bold* _emphasis_ `code`]), "Plain bold emphasis code")
#assert.eq(_deixis-summary-text(link("https://example.org")[A link]), "A link")
#assert.eq(_deixis-summary-text(text(fill: blue)[Styled]), "Styled")
#assert.eq(_deixis-summary-text([Before #updates.update(1)#context [Hidden] after]), "Before  after")
#assert.eq(_deixis-summary-text([#metadata((body: [Never visit payload]))]), "")
#assert.eq(_deixis-note-summary([a\ b]), text("a b"))
#assert.eq(_deixis-note-summary([First

Second]), text("First Second"))
#let long = "word " * 80
#let summary = _deixis-note-summary(long)
#assert(summary.text.len() <= 160 and summary.text.ends-with("…"))
#let multilingual = _deixis-note-summary("été " * 80)
#assert(multilingual.text.clusters().len() <= 160 and multilingual.text.ends-with("…"))
#context assert.eq(updates.final(), 0)
