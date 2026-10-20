#import "../../src/lib.typ": *
#let mode = sys.inputs.at("mode", default: "point-font")
#let form = sys.inputs.at("form", default: "from")
#let bad-points = (
  point-type: 2pt, point-short: (2pt,), point-long: (2pt, 3pt, 4pt),
  point-unitless: (2, 3), point-percent: (50%, 2pt), point-font: (1em, 2pt),
  point-inf: (calc.inf * 1pt, 2pt),
)
#let bad-normals = (
  normal-zero: (0, 0), normal-unit: (1pt, 0pt), normal-bool: (true, false),
  normal-nan: (float.nan, 1), normal-inf: (calc.inf, 1), normal-short: (1,),
  normal-long: (1, 0, 0), normal-center: center, normal-corner: top + left, normal-none: none,
)
#let options = {
  let options = (from: (10pt, 20pt), to: (180pt, 80pt))
  if mode in bad-points {
    let value = bad-points.at(mode)
    if form in ("from", "to") { options.insert(form, value) }
    else if form == "via" { options.via = (value,) }
    else if form == "control" { options.route = (kind: "b-spline", controls: (value,)) }
    else { options.segments = ((route: (kind: "b-spline", controls: (value,))),) }
  } else if mode in bad-normals {
    options.insert(form, (point: (10pt, 20pt), normal: bad-normals.at(mode)))
  } else if mode.starts-with("radius-") {
    options.radius = (radius-negative: -1pt, radius-font: 1em, radius-percent: 5%,
      radius-auto: auto, radius-inf: calc.inf * 1pt).at(mode)
  } else if mode == "both" { options.via = (); options.segments = () }
  else if mode == "via-type" { options.via = 2pt }
  else if mode == "via-pin" { options.via = ((pin: <p>),) }
  else if mode == "via-frame" { options.via = ((relative-to: "page", offset: (2pt, 3pt)),) }
  else if mode == "via-split" { options.via = ("split",) }
  else if mode == "endpoint-key" { options.from = (point: (2pt, 3pt), bogus: 1) }
  else if mode == "endpoint-missing" { options.to = (normal: right) }
  else if mode == "endpoint-pin" { options.from = (pin: <p>) }
  else if mode == "endpoint-type" { options.to = "a" }
  else if mode == "route-auto" { options.route = auto }
  else if mode == "route-callback" { options.route = x => [] }
  else if mode == "route-invalid" { options.route = "not-a-route" }
  else if mode == "route-record" { options.route = (tension: 2) }
  else if mode == "segment-type" { options.segments = (route: "curve") }
  else if mode == "segment-key" { options.segments = ((route: "curve", bogus: 1),) }
  else if mode == "segment-via" { options.segments = ((via: 2pt),) }
  else if mode == "segment-callback" { options.segments = ((route: x => []),) }
  else if mode == "diagonal" { options.route = "orthogonal"; options.from = (point: options.from, normal: (1, 1)) }
  else if mode == "diagonal-end" { options.route = "chamfer"; options.to = (point: options.to, normal: (1, 1)) }
  else if mode == "prepare" { deixis-prepare-connector((:)) }
  else if mode == "prepare-incomplete" { deixis-prepare-connector((kind: "deixis-route", frame: "source-local-x-right-y-down")) }
  options
}
#let geometry = deixis-route(..options)
