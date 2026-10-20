#import "../../src/lib.typ": deixis-set
#deixis-set(palette: (blue, orange, teal))
// Reuse the exact paired inline/paragraph footprint assertions for all body
// kinds, declaration orders and overlay layers, now with palettes enabled.
#include "overlay-invisibility.typ"
#let verify() = { assert.eq(query(<test-result>).first().value, if sys.inputs.at("target", default: "auto") == "named" { 20 } else { 28 }); true }
