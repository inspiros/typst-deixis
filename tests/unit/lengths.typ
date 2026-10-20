#import "../../src/core/utils.typ": resolve-signed-len, resolve-padding
#set text(size: 17pt)
#context {
  for (value, expected) in ((2em, 34pt), (-0.25em, -4.25pt), (1em - 3pt, 14pt),
    (-0.00000001pt, -0.00000001pt), (0pt, 0pt)) {
    assert.eq(resolve-signed-len(value), expected)
  }
  assert.eq(resolve-padding((x: -0.25em, y: 1em - 3pt)),
    (left: -4.25pt, right: -4.25pt, top: 14pt, bottom: 14pt))
  // Relative lengths retain their containing-frame measurement behavior.
  assert.eq(resolve-signed-len(0% + 3pt), 3pt)
}
