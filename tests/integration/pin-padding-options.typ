#import "../../src/lib.typ": *
#set page(width: 430pt, height: 350pt, margin: 35pt)
#set text(size: 10pt)
#show: deixis-setup-notes
#deixis-attach(prefix: "[", postfix: "]", padding: 2pt,
  pin-padding: (left: 5pt, rest: none, text: "text", edges: (x: -1pt, top: 3pt)),
  pins: (explicit: (dx: 0pt, padding: 7pt)),
)[#text("[left][rest][text][edges][fallback]")]
// Legacy non-edge per-name maps remain compatible.
#deixis-attach(prefix: "[", postfix: "]", padding: (legacy: 4pt))[
  #text("[legacy][unlisted]")
]
// Uniform edge dictionaries still apply to all scanned pins.
#deixis-attach(prefix: "[", postfix: "]", padding: (x: 2pt, y: 3pt))[
  #text("[uniform]")
]
// Empty dictionaries mean uniform zero, including a literal pin named rest.
#deixis-attach(prefix: "[", postfix: "]", padding: (:))[
  #text("[rest][empty]")
]
#context {
  let pins = query(<deixis-pin>)
  assert.eq(pins.len(), 11)
  let pad(name) = pins.find(p => p.value.name == name).value.padding
  assert.eq(pad("left").left, 5pt)
  assert.eq(pad("rest").left, 0pt)
  assert.eq(pad("text"), (left: 1pt, right: 1pt, top: 9pt, bottom: 2pt))
  assert.eq(pad("edges"), (left: -1pt, right: -1pt, top: 3pt, bottom: 0pt))
  assert.eq(pad("fallback").left, 2pt)
  assert.eq(pad("explicit").left, 7pt)
  assert.eq(pad("legacy").left, 4pt)
  assert.eq(pad("unlisted").left, 0pt)
  assert.eq(pad("uniform"), (left: 2pt, right: 2pt, top: 3pt, bottom: 3pt))
  assert.eq(pad("empty"), (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt))
  assert.eq(pins.filter(p => p.value.name == "rest").last().value.padding, pad("empty"))
}
