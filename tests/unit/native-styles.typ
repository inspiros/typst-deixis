#import "../../src/core/styles.typ": *
#import "../../src/core/config.typ": _deixis-resolve-body-styles
#import "../../src/render/body.typ": deixis-alert-container
#context {
  let native = _deixis-normalize-stroke((x: blue, top: red + 2pt, rest: none))
  assert.eq(native.left.thickness, 1pt)
  assert.eq(native.right.paint, blue)
  assert.eq(native.top.thickness, 2pt)
  assert.eq(native.bottom, none)
  assert.eq(_deixis-normalize-stroke((:)), (:))
  assert.eq(_deixis-stroke-edges((:)), (top: none, right: none, bottom: none, left: none))
  let scalar = _deixis-normalize-stroke((paint: orange, dash: "dashed"))
  assert.eq(scalar.paint, orange)
  assert.eq(scalar.thickness, 1pt)
  let selected = _deixis-resolve-body-styles(none, "inline-note", stroke: (body: (left: blue)), radius: auto)
  assert.eq(selected.stroke.left.paint, blue)
  assert.eq(_deixis-radius-corners((rest: 2pt, top: 4pt, bottom-left: 9pt)),
    (top-left: 4pt, top-right: 4pt, bottom-left: 9pt, bottom-right: 2pt))
  assert.eq(_deixis-radius-corners((:)), (top-left: 0pt, top-right: 0pt, bottom-left: 0pt, bottom-right: 0pt))
  let percent = _deixis-radius-corners((top: 20%,))
  assert.eq(percent.top-left, 20% + 0pt)
  assert.eq(percent.bottom-right, 0pt)
  let alert = deixis-alert-container(stroke: blue)[Body]
  assert.eq(alert.stroke.left.thickness, 2pt)
  assert.eq(alert.stroke.left.paint, blue)
  let native-alert = deixis-alert-container(stroke: (x: red, rest: none))[Body]
  assert.eq(native-alert.stroke.left.thickness, 1pt)
  assert.eq(native-alert.stroke.top, none)
}
