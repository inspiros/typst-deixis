#import "utils.typ" as deixis-utils

#let deixis-waypoint-split = "split"
#let deixis-link-types = ("none", "straight-line", "right-angle", "chamfer", "curve", "ccr", "ucr")

// Draw the rectangle around mark marker.
#let _deixis-draw-marker-highlight(
  mark-x,
  mark-y,
  marker-width,
  marker-str,
  stroke: 0.5pt + luma(200),
  text-size: auto,
  has-inline-box: false,
  mark-type: "inline",
) = {
  let t-val = deixis-utils.resolve-len(if text-size != auto and type(text-size) == length { text-size } else { 11pt })
  let box-y = mark-y - (t-val * 0.8)
  let box-x = mark-x - 1.5pt
  let actual-box-h = t-val * 0.85

  if not has-inline-box {
    if marker-str == none {
      // do nothing
    } else if mark-type == "phantom" or marker-str == "" {
      return place(dx: mark-x, dy: box-y, line(start: (0pt, 0pt), end: (0pt, actual-box-h), stroke: stroke))
    } else if mark-type == "inline" {
      return place(dx: box-x, dy: box-y, box(
        width: marker-width + 3pt,
        height: actual-box-h,
        stroke: stroke,
        radius: 1pt,
      ))
    }
  }
  return none
}

// Draw an arrowhead.
#let _deixis-draw-arrowhead(p1, p2, stroke: luma(0)) = {
  let dx = (deixis-utils.resolve-signed-len(p2.at(0)) - deixis-utils.resolve-signed-len(p1.at(0))) / 1pt
  let dy = (deixis-utils.resolve-signed-len(p2.at(1)) - deixis-utils.resolve-signed-len(p1.at(1))) / 1pt

  let angle = calc.atan2(dx, dy)

  let s-obj = std.stroke(stroke)
  let abs-thick = if s-obj.thickness == auto { 1.0 } else { deixis-utils.resolve-len(s-obj.thickness) / 1pt }

  let arrow-length = calc.max(4.0, abs-thick * 4.0)
  let arrow-half-width = calc.max(2.5, abs-thick * 2.5)
  let inset-depth = arrow-length * 0.4

  // push the tip forward mathematically to envelop the flat line cap
  let t-half = abs-thick / 2.0
  let tip-forward = ((t-half * arrow-length) / (arrow-half-width - t-half)) + 0.2

  let tip = (
    p2.at(0) + tip-forward * calc.cos(angle) * 1pt,
    p2.at(1) + tip-forward * calc.sin(angle) * 1pt,
  )

  let p_back = (
    p2.at(0) - arrow-length * calc.cos(angle) * 1pt,
    p2.at(1) - arrow-length * calc.sin(angle) * 1pt,
  )

  let p_inset = (
    p2.at(0) - (arrow-length - inset-depth) * calc.cos(angle) * 1pt,
    p2.at(1) - (arrow-length - inset-depth) * calc.sin(angle) * 1pt,
  )

  let p_left = (
    p_back.at(0) - arrow-half-width * calc.sin(angle) * 1pt,
    p_back.at(1) + arrow-half-width * calc.cos(angle) * 1pt,
  )

  let p_right = (
    p_back.at(0) + arrow-half-width * calc.sin(angle) * 1pt,
    p_back.at(1) - arrow-half-width * calc.cos(angle) * 1pt,
  )

  place(top + left, curve(
    fill: s-obj.paint,
    stroke: none,
    curve.move(tip),
    curve.line(p_left),
    curve.line(p_inset),
    curve.line(p_right),
    curve.close(),
  ))
}

// Corners for right-angle and chamfer links.
#let _deixis-orthogonal-cmds(vertices, radius: 0pt, corner-style: "fillet") = {
  let cmds = ()
  if vertices.len() < 2 { return cmds }

  let abs-radius = deixis-utils.resolve-len(if radius == auto { 0pt } else { radius })

  // deduplicate consecutive identical points
  let clean_pts = ()
  for p in vertices {
    if clean_pts.len() == 0 or clean_pts.last() != p { clean_pts.push(p) }
  }
  if clean_pts.len() < 2 { return cmds }

  for i in range(1, clean_pts.len() - 1) {
    let p_prev = clean_pts.at(i - 1)
    let p_curr = clean_pts.at(i)
    let p_next = clean_pts.at(i + 1)

    let dx_in = p_prev.at(0) - p_curr.at(0)
    let dy_in = p_prev.at(1) - p_curr.at(1)
    let len_in = calc.sqrt((dx_in / 1pt) * (dx_in / 1pt) + (dy_in / 1pt) * (dy_in / 1pt)) * 1pt

    let dx_out = p_next.at(0) - p_curr.at(0)
    let dy_out = p_next.at(1) - p_curr.at(1)
    let len_out = calc.sqrt((dx_out / 1pt) * (dx_out / 1pt) + (dy_out / 1pt) * (dy_out / 1pt)) * 1pt

    // shrink the radius/chamfer cut if the line segment is extremely short
    let r = calc.min(abs-radius, len_in / 2.0, len_out / 2.0)

    if r <= 0.05pt or len_in == 0pt or len_out == 0pt {
      cmds.push(curve.line(p_curr))
    } else {
      let p_in = (
        p_curr.at(0) + (dx_in / len_in) * r,
        p_curr.at(1) + (dy_in / len_in) * r,
      )
      let p_out = (
        p_curr.at(0) + (dx_out / len_out) * r,
        p_curr.at(1) + (dy_out / len_out) * r,
      )

      cmds.push(curve.line(p_in))

      if corner-style == "chamfer" {
        cmds.push(curve.line(p_out))
      } else {
        cmds.push(curve.quad(p_curr, p_out))
      }
    }
  }
  cmds.push(curve.line(clean_pts.last()))
  return cmds
}

// Resolves the optimal geometric connection between a set of source and destination ports based on Manhattan or Euclidean distance.
#let _deixis-resolve-best-ports(source-ports, dest-ports, metric: "euclidean") = {
  let best-S = none
  let best-D = none
  let min-cost = 0pt

  for S in source-ports {
    for D in dest-ports {
      let sx = deixis-utils.resolve-signed-len(S.x)
      let sy = deixis-utils.resolve-signed-len(S.y)
      let dx = deixis-utils.resolve-signed-len(D.x)
      let dy = deixis-utils.resolve-signed-len(D.y)

      let diff_x = dx - sx
      let diff_y = dy - sy

      let abs_dx = if diff_x < 0pt { -diff_x } else { diff_x }
      let abs_dy = if diff_y < 0pt { -diff_y } else { diff_y }

      let dist = if metric == "euclidean" {
        let diff_x-num = deixis-utils.to-float(diff_x)
        let diff_y-num = deixis-utils.to-float(diff_y)
        calc.sqrt(diff_x-num * diff_x-num + diff_y-num * diff_y-num) * 1pt
      } else {
        abs_dx + abs_dy
      }
      let penalty = 0pt

      if D.id == "top" and sy > dy { penalty += 1e10pt }
      if D.id == "bottom" and sy < dy { penalty += 1e10pt }
      if D.id == "left" and sx > dx { penalty += 1e10pt }
      if D.id == "right" and sx < dx { penalty += 1e10pt }

      if S.id == "top" and dy > sy { penalty += 1e10pt }
      if S.id == "bottom" and dy < sy { penalty += 1e10pt }
      if S.id == "left" and dx > sx { penalty += 1e10pt }
      if S.id == "right" and dx < sx { penalty += 1e10pt }

      let cost = dist + penalty

      if best-S == none or cost < min-cost {
        min-cost = cost
        best-S = S
        best-D = D
      }
    }
  }
  return (best-S, best-D)
}

// Translates user-provided relative waypoints into absolute page coordinates.
#let _deixis-resolve-waypoints(waypoints, start_x, start_y, m-box, b-box) = {
  if waypoints in (none, auto) { return () }
  let wps = if type(waypoints) == array { waypoints } else { (waypoints,) }

  let resolved = ()

  let current_x = start_x
  let current_y = start_y

  let get_anchor(spec) = {
    if type(spec) != str { return none }

    let is-m = spec.starts-with("mark") or spec in ("source", "start")
    let is-b = spec.starts-with("body") or spec in ("target", "end")
    if not is-m and not is-b { return none }

    let box = if is-m { m-box } else { b-box }
    let res-x = box.center-x
    let res-y = box.center-y

    if "left" in spec { res-x = box.left } else if "right" in spec { res-x = box.right }

    if "top" in spec { res-y = box.top } else if "bottom" in spec { res-y = box.bottom }

    return (res-x, res-y)
  }

  let resolve_coord(spec, cur, is_x) = {
    // 1. Check if it's an anchor string
    let anchor = get_anchor(spec)
    if anchor != none { return if is_x { anchor.at(0) } else { anchor.at(1) } }

    // 2. Otherwise, resolve relative/ratio logic from the center
    let s = if is_x { m-box.center-x } else { m-box.center-y }
    let e = if is_x { b-box.center-x } else { b-box.center-y }

    let val = 0pt
    if type(spec) == ratio {
      let r_val = float(repr(spec).replace("%", "")) / 100.0
      val = (e - s) * r_val
    } else if type(spec) == relative {
      let r_val = float(repr(spec.ratio).replace("%", "")) / 100.0
      val = deixis-utils.resolve-signed-len(spec.length) + (e - s) * r_val
    } else {
      val = deixis-utils.resolve-signed-len(spec)
    }
    return cur + val
  }

  for wp in wps {
    if (
      wp == deixis-waypoint-split
        or wp in deixis-link-types
        or (type(wp) == array and wp.len() > 0 and wp.at(0) == deixis-waypoint-split)
    ) {
      resolved.push(wp)
      continue
    }

    let norm_wp = wp
    let anchor = get_anchor(wp)
    if anchor != none {
      norm_wp = (wp, wp) // Both X and Y evaluate to the same anchor object
    } else if type(wp) != array {
      norm_wp = (wp, 0pt)
    }

    let x_spec = if type(norm_wp) == array and norm_wp.len() > 0 { norm_wp.at(0) } else { 0pt }
    let y_spec = if type(norm_wp) == array and norm_wp.len() > 1 { norm_wp.at(1) } else { 0pt }

    // sanity check
    let valid_x = type(x_spec) in (length, ratio, relative) or get_anchor(x_spec) != none
    let valid_y = type(y_spec) in (length, ratio, relative) or get_anchor(y_spec) != none
    if not valid_x or not valid_y {
      panic(
        "deixis: Invalid waypoint coordinate. Must be a length, ratio, relative, link type, or an anchor string. Got: "
          + repr(norm_wp),
      )
    }

    let next_x = resolve_coord(x_spec, current_x, true)
    let next_y = resolve_coord(y_spec, current_y, false)

    resolved.push((next_x, next_y))
    current_x = next_x
    current_y = next_y
  }
  return resolved
}

#let _deixis-render-waypoint-path(
  S_x,
  S_y,
  E_x,
  E_y,
  waypoints: (),
  link-type: "straight-line",
  link-stroke: luma(0),
  link-radius: 0pt,
  link-marks: "none",
  source-dir: "vertical",
  target-dir: "horizontal",
) = {
  let end_rel = (E_x - S_x, E_y - S_y)

  let clean-wps = ()
  let cur-pt = (0pt, 0pt)
  for wp in waypoints {
    if type(wp) == str {
      clean-wps.push(wp)
      continue
    }

    let dx = wp.at(0) - cur-pt.at(0)
    let dy = wp.at(1) - cur-pt.at(1)
    let dist-sq = (dx / 1pt) * (dx / 1pt) + (dy / 1pt) * (dy / 1pt)

    let edx = wp.at(0) - end_rel.at(0)
    let edy = wp.at(1) - end_rel.at(1)
    let edist-sq = (edx / 1pt) * (edx / 1pt) + (edy / 1pt) * (edy / 1pt)

    if dist-sq > 0.01 and edist-sq > 0.01 {
      clean-wps.push(wp)
      cur-pt = wp
    }
  }

  // chunking
  let raw_points = ()
  let raw_types = ()
  let cur_type = link-type

  for wp in clean-wps {
    if type(wp) == str {
      cur_type = wp
    } else {
      raw_points.push(wp)
      raw_types.push(cur_type)
    }
  }
  raw_points.push(end_rel)
  raw_types.push(cur_type)

  let chunks = ()
  let chunk_start = (0pt, 0pt)
  let current_chunk_wps = ()
  let current_chunk_type = raw_types.first()

  for i in range(raw_points.len()) {
    let pt = raw_points.at(i)
    let typ = raw_types.at(i)

    if typ == current_chunk_type {
      current_chunk_wps.push(pt)
    } else {
      let chunk_end = current_chunk_wps.last()
      let inner_wps = current_chunk_wps.slice(0, -1)
      chunks.push((start: chunk_start, end: chunk_end, wps: inner_wps, type: current_chunk_type))
      chunk_start = chunk_end
      current_chunk_type = typ
      current_chunk_wps = (pt,)
    }
  }
  let chunk_end = current_chunk_wps.last()
  let inner_wps = current_chunk_wps.slice(0, -1)
  chunks.push((start: chunk_start, end: chunk_end, wps: inner_wps, type: current_chunk_type))

  let cmds = (curve.move((0pt, 0pt)),)
  let global_t_start = (0pt, 0pt)
  let global_t_end = (0pt, 0pt)

  // render each chunk independently
  for (i, chunk) in chunks.enumerate() {
    let C_start = chunk.start
    let C_end = chunk.end
    let wps = chunk.wps
    let l_type = chunk.type

    let c_s_dir = if i == 0 { source-dir } else { "none" }
    let c_t_dir = if i == chunks.len() - 1 { target-dir } else { "none" }

    let t_start = (0pt, 0pt)
    let t_end = (0pt, 0pt)

    if l_type in ("none", none) {
      t_start = if wps.len() > 0 { wps.first() } else { C_end }
      t_end = if wps.len() > 0 { wps.last() } else { C_start }
      cmds.push(curve.move(C_end))
    } else if l_type == "straight-line" {
      t_start = if wps.len() > 0 { wps.first() } else { C_end }
      t_end = if wps.len() > 0 { wps.last() } else { C_start }
      for wp in wps { cmds.push(curve.line(wp)) }
      cmds.push(curve.line(C_end))
    } else if l_type in ("right-angle", "chamfer") {
      let pts = (C_start,)
      let eff_s_dir = if c_s_dir == "none" { "vertical" } else { c_s_dir }
      let eff_t_dir = if c_t_dir == "none" { "horizontal" } else { c_t_dir }

      if wps.len() == 0 {
        let is_same_dir = (eff_s_dir == eff_t_dir)

        if not is_same_dir {
          if eff_s_dir == "vertical" {
            pts.push((C_start.at(0), C_end.at(1)))
            t_start = (C_start.at(0), C_end.at(1))
            t_end = if C_end.at(0) != C_start.at(0) { (C_start.at(0), C_end.at(1)) } else { C_start }
          } else {
            pts.push((C_end.at(0), C_start.at(1)))
            t_start = (C_end.at(0), C_start.at(1))
            t_end = if C_end.at(1) != C_start.at(1) { (C_end.at(0), C_start.at(1)) } else { C_start }
          }
        } else {
          if eff_s_dir == "vertical" {
            if C_end.at(0) == C_start.at(0) {
              t_start = C_end
              t_end = C_start
            } else {
              let mid_y = C_start.at(1) + (C_end.at(1) - C_start.at(1)) / 2.0
              pts.push((C_start.at(0), mid_y))
              pts.push((C_end.at(0), mid_y))
              t_start = (C_start.at(0), mid_y)
              t_end = (C_end.at(0), mid_y)
            }
          } else {
            if C_end.at(1) == C_start.at(1) {
              t_start = C_end
              t_end = C_start
            } else {
              let mid_x = C_start.at(0) + (C_end.at(0) - C_start.at(0)) / 2.0
              pts.push((mid_x, C_start.at(1)))
              pts.push((mid_x, C_end.at(1)))
              t_start = (mid_x, C_start.at(1))
              t_end = (mid_x, C_end.at(1))
            }
          }
        }
        pts.push(C_end)
      } else {
        let current_pt = C_start
        for wp in wps {
          if current_pt == C_start {
            if eff_s_dir == "vertical" {
              t_start = (C_start.at(0), wp.at(1))
              pts.push(t_start)
            } else {
              t_start = (wp.at(0), C_start.at(1))
              pts.push(t_start)
            }
          } else {
            pts.push((current_pt.at(0), wp.at(1)))
          }
          pts.push(wp)
          current_pt = wp
        }
        if eff_t_dir == "horizontal" {
          pts.push((current_pt.at(0), C_end.at(1)))
          t_end = if current_pt.at(0) != C_end.at(0) { (current_pt.at(0), C_end.at(1)) } else { current_pt }
        } else {
          pts.push((C_end.at(0), current_pt.at(1)))
          t_end = if current_pt.at(1) != C_end.at(1) { (C_end.at(0), current_pt.at(1)) } else { current_pt }
        }
        pts.push(C_end)
      }

      let stroke-obj = std.stroke(link-stroke)
      let thick = deixis-utils.resolve-len(if stroke-obj.thickness == auto { 1pt } else { stroke-obj.thickness })
      let c-rad = if link-radius == auto { calc.max(3pt, thick * 4) } else { deixis-utils.resolve-len(link-radius) }

      let c-style = if l_type == "chamfer" { "chamfer" } else { "fillet" }
      let r_cmds = _deixis-orthogonal-cmds(pts, radius: c-rad, corner-style: c-style)

      for c in r_cmds { cmds.push(c) }
    } else if l_type in ("curve", "ccr", "ucr") {
      let dx = C_end.at(0) - C_start.at(0)
      let dy = C_end.at(1) - C_start.at(1)
      let eff_s_dir = if c_s_dir == "none" { "vertical" } else { c_s_dir }
      let eff_t_dir = if c_t_dir == "none" { "horizontal" } else { c_t_dir }

      if wps.len() == 0 {
        t_start = if eff_s_dir == "horizontal" { (C_start.at(0) + dx * 0.5, C_start.at(1)) } else {
          (C_start.at(0), C_start.at(1) + dy * 0.5)
        }
        t_end = if eff_t_dir == "horizontal" { (C_start.at(0) + dx * 0.5, C_end.at(1)) } else {
          (C_end.at(0), C_start.at(1) + dy * 0.5)
        }
        cmds.push(curve.cubic(t_start, t_end, C_end))
      } else {
        let pts = (C_start,) + wps + (C_end,)

        let add(p1, p2) = (p1.at(0) + p2.at(0), p1.at(1) + p2.at(1))
        let sub(p1, p2) = (p1.at(0) - p2.at(0), p1.at(1) - p2.at(1))
        let scale(p, s) = (p.at(0) * s, p.at(1) * s)

        let get_pt(idx) = {
          if idx < 0 {
            let p0 = pts.at(0)
            let p1 = pts.at(1)
            (p0.at(0) * 2 - p1.at(0), p0.at(1) * 2 - p1.at(1))
          } else if idx >= pts.len() {
            let pL = pts.last()
            let pP = pts.at(pts.len() - 2)
            (pL.at(0) * 2 - pP.at(0), pL.at(1) * 2 - pP.at(1))
          } else { pts.at(idx) }
        }

        for j in range(pts.len() - 1) {
          let p_prev = get_pt(j - 1)
          let p_curr = get_pt(j)
          let p_next = get_pt(j + 1)
          let p_next2 = get_pt(j + 2)

          let c1 = (0pt, 0pt)
          let c2 = (0pt, 0pt)

          if l_type == "curve" {
            // Weighted Bessel Spline
            let tension = 0.25
            let d_curr_x = p_next.at(0) - p_curr.at(0)
            let d_curr_y = p_next.at(1) - p_curr.at(1)
            let len_curr = calc.sqrt((d_curr_x / 1pt) * (d_curr_x / 1pt) + (d_curr_y / 1pt) * (d_curr_y / 1pt))

            let get_dir(pa, pb) = {
              let dx = (pb.at(0) - pa.at(0)) / 1pt
              let dy = (pb.at(1) - pa.at(1)) / 1pt
              let l = calc.max(1e-5, calc.sqrt(dx * dx + dy * dy))
              (dx / l, dy / l)
            }

            let t1_x = 0
            let t1_y = 0
            if j == 0 {
              if eff_s_dir == "vertical" { t1_y = if d_curr_y > 0pt { 1 } else { -1 } } else {
                t1_x = if d_curr_x > 0pt { 1 } else { -1 }
              }
            } else {
              let dir_in = get_dir(p_prev, p_curr)
              let dir_out = get_dir(p_curr, p_next)
              t1_x = dir_in.at(0) + dir_out.at(0)
              t1_y = dir_in.at(1) + dir_out.at(1)
            }
            let t1_len = calc.max(1e-5, calc.sqrt(t1_x * t1_x + t1_y * t1_y))
            let cp_dist1 = len_curr * tension
            c1 = (
              p_curr.at(0) + deixis-utils.to-length(t1_x / t1_len) * cp_dist1,
              p_curr.at(1) + deixis-utils.to-length(t1_y / t1_len) * cp_dist1,
            )

            let t2_x = 0
            let t2_y = 0
            if j == pts.len() - 2 {
              if eff_t_dir == "vertical" { t2_y = if d_curr_y > 0pt { 1 } else { -1 } } else {
                t2_x = if d_curr_x > 0pt { 1 } else { -1 }
              }
            } else {
              let dir_in = get_dir(p_curr, p_next)
              let dir_out = get_dir(p_next, p_next2)
              t2_x = dir_in.at(0) + dir_out.at(0)
              t2_y = dir_in.at(1) + dir_out.at(1)
            }
            let t2_len = calc.max(1e-5, calc.sqrt(t2_x * t2_x + t2_y * t2_y))
            let cp_dist2 = len_curr * tension
            c2 = (
              p_next.at(0) - deixis-utils.to-length(t2_x / t2_len) * cp_dist2,
              p_next.at(1) - deixis-utils.to-length(t2_y / t2_len) * cp_dist2,
            )
          } else if l_type == "ccr" {
            // Centripetal Catmull-Rom
            let get_dist(pa, pb) = calc.sqrt(
              calc.pow((pa.at(0) - pb.at(0)) / 1pt, 2) + calc.pow((pa.at(1) - pb.at(1)) / 1pt, 2),
            )

            let d1 = calc.sqrt(get_dist(p_prev, p_curr)) + 1e-5
            let d2 = calc.sqrt(get_dist(p_curr, p_next)) + 1e-5
            let d3 = calc.sqrt(get_dist(p_next, p_next2)) + 1e-5

            let d1_sq = d1 * d1
            let d2_sq = d2 * d2
            let d3_sq = d3 * d3

            let off1_x = (
              (d1_sq * (p_next.at(0) - p_curr.at(0)) + d2_sq * (p_curr.at(0) - p_prev.at(0))) / (3.0 * d1 * (d1 + d2))
            )
            let off1_y = (
              (d1_sq * (p_next.at(1) - p_curr.at(1)) + d2_sq * (p_curr.at(1) - p_prev.at(1))) / (3.0 * d1 * (d1 + d2))
            )

            let off2_x = (
              (d2_sq * (p_next2.at(0) - p_next.at(0)) + d3_sq * (p_next.at(0) - p_curr.at(0))) / (3.0 * d3 * (d2 + d3))
            )
            let off2_y = (
              (d2_sq * (p_next2.at(1) - p_next.at(1)) + d3_sq * (p_next.at(1) - p_curr.at(1))) / (3.0 * d3 * (d2 + d3))
            )

            c1 = (p_curr.at(0) + off1_x, p_curr.at(1) + off1_y)
            c2 = (p_next.at(0) - off2_x, p_next.at(1) - off2_y)
          } else {
            // Uniform Catmull-Rom
            let get_tan(idx) = scale(sub(get_pt(idx + 1), get_pt(idx - 1)), 1.0 / 6.0)
            c1 = add(p_curr, get_tan(j))
            c2 = sub(p_next, get_tan(j + 1))
          }

          if j == 0 { t_start = c1 }
          if j == pts.len() - 2 { t_end = c2 }
          cmds.push(curve.cubic(c1, c2, p_next))
        }
      }
    }

    if i == 0 { global_t_start = t_start }
    if i == chunks.len() - 1 { global_t_end = t_end }
  }

  let elements = ()

  elements.push(place(top + left, dx: S_x, dy: S_y, curve(stroke: link-stroke, ..cmds)))

  let abs_t_start = (S_x + global_t_start.at(0), S_y + global_t_start.at(1))
  let abs_t_end = (S_x + global_t_end.at(0), S_y + global_t_end.at(1))

  if link-marks in ("mark", "start", "both") {
    elements.push(_deixis-draw-arrowhead(abs_t_start, (S_x, S_y), stroke: link-stroke))
  }
  if link-marks in ("body", "end", "both") {
    elements.push(_deixis-draw-arrowhead(abs_t_end, (E_x, E_y), stroke: link-stroke))
  }

  return elements
}

#let _deixis-draw-direct-link(
  S_x,
  S_y,
  E_x,
  E_y,
  waypoints: (),
  link-type: "straight-line",
  link-stroke: luma(0),
  link-radius: 0pt,
  link-marks: "none",
  source-dir: "vertical",
  target-dir: "horizontal",
  is-incoming: false,
  is-outgoing: false,
  extra-data: (:),
) = {
  let actual-mark = link-marks
  if is-incoming {
    if actual-mark == "both" { actual-mark = "end" } else if actual-mark == "start" { actual-mark = "none" }
  } else if is-outgoing {
    if actual-mark == "both" { actual-mark = "start" } else if actual-mark == "end" { actual-mark = "none" }
  }

  let elements = ()

  let c_content = if type(link-type) == function {
    let func_args = (
      S_x: S_x,
      S_y: S_y,
      E_x: E_x,
      E_y: E_y,
      waypoints: waypoints,
      stroke: link-stroke,
      radius: link-radius,
      mark: actual-mark,
      is-incoming: is-incoming,
      is-outgoing: is-outgoing,
    )
    for (k, v) in extra-data { func_args.insert(k, v) }
    (place(top + left, dx: S_x, dy: S_y, link-type(func_args)),)
  } else {
    _deixis-render-waypoint-path(
      S_x,
      S_y,
      E_x,
      E_y,
      waypoints: waypoints,
      link-type: link-type,
      link-stroke: link-stroke,
      link-radius: link-radius,
      link-marks: actual-mark,
      source-dir: source-dir,
      target-dir: target-dir,
    )
  }

  for el in c_content { elements.push(el) }

  // draw spill marks
  if is-incoming or is-outgoing {
    let c_obj = std.stroke(link-stroke)
    let c_paint = if c_obj.paint == auto { black } else { c_obj.paint }
    let c_rad = if c_obj.thickness == auto { 1.5pt } else { 1.5 * c_obj.thickness }
    let spill_mark = circle(radius: c_rad, fill: c_paint, stroke: none)

    if is-outgoing {
      elements.push(place(top + left, dx: E_x - c_rad, dy: E_y - c_rad, spill_mark))
    } else if is-incoming {
      elements.push(place(top + left, dx: S_x - c_rad, dy: S_y - c_rad, spill_mark))
    }
  }

  return elements
}

// The routing engine for rendering connector lines between marks and bodies.
#let _deixis-route-link(
  data,
  internal-id,
  current-page,
  S_page,
  E_page,
  S_candidates,
  D_candidates,
  c-link: auto,
  c-link-stroke: auto,
  c-link-radius: auto,
  c-link-marks: auto,
  split-default: "source",
  turn-x: auto,
  synthetic-waypoints: auto,
  is-margin: false,
  extra-data: (:),
) = {
  let paths = ()
  let is-cross-page = (S_page != E_page)
  let is-outgoing = (is-cross-page and current-page == S_page)
  let is-incoming = (is-cross-page and current-page == E_page)

  // user link-ports
  let S_candidates = S_candidates
  let D_candidates = D_candidates
  let c-ports = data.at("link-ports", default: auto)
  if type(c-ports) == dictionary {
    if "mark" in c-ports {
      let f_S = S_candidates.filter(p => p.id == c-ports.mark)
      if f_S.len() > 0 { S_candidates = f_S }
    }
    if "body" in c-ports {
      let f_D = D_candidates.filter(p => p.id == c-ports.body)
      if f_D.len() > 0 { D_candidates = f_D }
    }
  }

  let m_cx = S_candidates.first().x
  let m_y = S_candidates.first().y
  let D_top_x = D_candidates.first().x
  let D_top_y = D_candidates.first().y

  let extract-box(candidates) = {
    let xs = candidates.map(c => c.x)
    let ys = candidates.map(c => c.y)
    let min-x = calc.min(..xs); let max-x = calc.max(..xs)
    let min-y = calc.min(..ys); let max-y = calc.max(..ys)
    return (
      left: min-x, right: max-x, top: min-y, bottom: max-y,
      center-x: (min-x + max-x) / 2.0, center-y: (min-y + max-y) / 2.0
    )
  }
  let m-box = extract-box(S_candidates)
  let b-box = extract-box(D_candidates)

  let raw_waypoints = data.at("link-waypoints", default: auto)
  if raw_waypoints == auto {
    raw_waypoints = if synthetic-waypoints != auto { synthetic-waypoints } else { none }
  }
  let raw_wps = if type(raw_waypoints) == array {
    raw_waypoints
  } else if raw_waypoints != none {
    (raw_waypoints,)
  } else {
    ()
  }

  let split_item = raw_wps.find(x => (
    x == deixis-waypoint-split or (type(x) == array and x.len() > 0 and x.at(0) == deixis-waypoint-split)
  ))

  let explicit_config = if type(split_item) == array and split_item.len() > 1 { split_item.at(1) } else { auto }
  let split_idx = raw_wps.position(x => x == split_item)

  // spill mark coordinates
  let current_x = if split-default == "source" { m-box.center-x } else {
    if turn-x != auto { turn-x } else { b-box.center-x }
  }

  if split_idx != none and split_idx > 0 {
    let pre_wps = raw_wps.slice(0, split_idx)
    let dry_run = _deixis-resolve-waypoints(pre_wps, m-box.center-x, m-box.center-y, m-box, b-box)
    let valid_wps = dry_run.filter(x => type(x) == array)
    if valid_wps.len() > 0 { current_x = valid_wps.last().at(0) }
  }

  let split_x = current_x

  if explicit_config != auto {
    if explicit_config == "average" {
      split_x = (m-box.center-x + if turn-x != auto { turn-x } else { b-box.center-x }) / 2.0
    } else if (
      type(explicit_config) == str
        and (
          "mark" in explicit_config or "body" in explicit_config or explicit_config in ("source", "target")
        )
    ) {
      let is-m = explicit_config.starts-with("mark") or explicit_config == "source"
      let box = if is-m { m-box } else { b-box }

      split_x = if explicit_config == "target" and turn-x != auto { turn-x } else { box.center-x }
      if "left" in explicit_config { split_x = box.left } else if "right" in explicit_config { split_x = box.right }
    } else {
      split_x = current_x + deixis-utils.resolve-signed-len(explicit_config)
    }
  } else {
    if split_idx != none and split_idx > 0 {
      let pre_wps = raw_wps.slice(0, split_idx)
      let dry_run = _deixis-resolve-waypoints(pre_wps, m-box.center-x, m-box.center-y, m-box, b-box)
      let valid_wps = dry_run.filter(x => type(x) == array)

      if valid_wps.len() > 0 {
        split_x = valid_wps.last().at(0)
      } else {
        split_x = if split-default == "source" { m-box.center-x } else {
          if turn-x != auto { turn-x } else { b-box.center-x }
        }
      }
    } else {
      split_x = if split-default == "source" { m-box.center-x } else {
        if turn-x != auto { turn-x } else { b-box.center-x }
      }
    }
  }

  let goes-forward = S_page < E_page
  let p-margins = deixis-utils.get-page-margins(current-page)
  let page-h = if type(page.height) == length { page.height } else { 29.7cm }
  let top-bound = deixis-utils.resolve-len(p-margins.top)
  let bottom-bound = deixis-utils.resolve-len(page-h) - deixis-utils.resolve-len(p-margins.bottom)

  let virtual_y_in = if goes-forward { top-bound } else { bottom-bound }
  let virtual_y_out = if goes-forward { bottom-bound } else { top-bound }
  if goes-forward {
    virtual_y_out = calc.max(virtual_y_out, m-box.bottom)
    virtual_y_in = calc.min(virtual_y_in, b-box.top)
  } else {
    virtual_y_out = calc.min(virtual_y_out, m-box.top)
    virtual_y_in = calc.max(virtual_y_in, b-box.bottom)
  }

  let virtual_id_in = if goes-forward { "top" } else { "bottom" }
  let virtual_id_out = if goes-forward { "bottom" } else { "top" }

  if is-margin {
    virtual_y_in = calc.min(top-bound, b-box.top)
    virtual_y_out = calc.max(bottom-bound, m-box.bottom)
    virtual_id_in = "top"
    virtual_id_out = "bottom"
  }

  let active_raw_wps = raw_wps
  let wps_start_x = m_cx
  let wps_start_y = m_y

  if split_idx != none {
    if is-outgoing { active_raw_wps = raw_wps.slice(0, split_idx) } else if is-incoming {
      active_raw_wps = raw_wps.slice(split_idx + 1)
      wps_start_x = split_x
      wps_start_y = virtual_y_in
    } else { active_raw_wps = raw_wps.slice(0, split_idx) + raw_wps.slice(split_idx + 1) }
  } else if is-outgoing or is-incoming {
    if is-outgoing { active_raw_wps = raw_wps } else if is-incoming {
      active_raw_wps = ()
      wps_start_x = split_x
      wps_start_y = virtual_y_in
    }
  }

  let resolved_wps = _deixis-resolve-waypoints(active_raw_wps, wps_start_x, wps_start_y, m-box, b-box)

  let safe-wps = resolved_wps.filter(x => type(x) == str or (type(x) == array and x.len() >= 2))
  let coord-wps = safe-wps.filter(x => type(x) == array)

  let S_anchor_x = S_candidates.first().x
  let S_anchor_y = S_candidates.first().y
  let E_anchor_x = D_top_x
  let E_anchor_y = D_top_y
  let source_dir = "vertical"
  let target_dir = "vertical"

  if is-outgoing {
    let virtual-D-ports = ((x: split_x, y: virtual_y_out, dir: "vertical", id: virtual_id_out),)
    if coord-wps.len() > 0 {
      virtual-D-ports = ((x: coord-wps.first().at(0), y: coord-wps.first().at(1), dir: "none", id: "none"),)
    }

    let (best-S, best-D) = _deixis-resolve-best-ports(S_candidates, virtual-D-ports)
    S_anchor_x = best-S.x
    S_anchor_y = best-S.y
    source_dir = best-S.dir
    E_anchor_x = split_x
    E_anchor_y = virtual_y_out
    target_dir = virtual_id_out
  } else if is-incoming {
    let virtual-S-ports = ((x: split_x, y: virtual_y_in, dir: "vertical", id: virtual_id_in),)
    if coord-wps.len() > 0 {
      virtual-S-ports = ((x: coord-wps.last().at(0), y: coord-wps.last().at(1), dir: "none", id: "none"),)
    }

    let (best-S, best-D) = _deixis-resolve-best-ports(virtual-S-ports, D_candidates)
    S_anchor_x = split_x
    S_anchor_y = virtual_y_in
    source_dir = virtual_id_in
    E_anchor_x = best-D.x
    E_anchor_y = best-D.y
    target_dir = best-D.dir
  } else {
    let virtual-S-ports = S_candidates
    let virtual-D-ports = D_candidates

    if coord-wps.len() > 0 {
      let first-wp = (x: coord-wps.first().at(0), y: coord-wps.first().at(1))
      virtual-D-ports = ((x: first-wp.x, y: first-wp.y, dir: "none", id: "none"),)
    }

    let (best-S, temp-D) = _deixis-resolve-best-ports(S_candidates, virtual-D-ports)

    if coord-wps.len() > 0 {
      let last-wp = (x: coord-wps.last().at(0), y: coord-wps.last().at(1))
      virtual-S-ports = ((x: last-wp.x, y: last-wp.y, dir: "none", id: "none"),)
    }

    let (temp-S, best-D) = _deixis-resolve-best-ports(virtual-S-ports, D_candidates)

    S_anchor_x = best-S.x
    S_anchor_y = best-S.y
    source_dir = best-S.dir
    E_anchor_x = best-D.x
    E_anchor_y = best-D.y
    target_dir = best-D.dir
  }

  let final_wps = safe-wps.map(wp => if type(wp) == str { wp } else { (wp.at(0) - S_anchor_x, wp.at(1) - S_anchor_y) })

  let call_extra = (dx: E_anchor_x - S_anchor_x, dy: E_anchor_y - S_anchor_y)
  for (k, v) in extra-data { call_extra.insert(k, v) }

  let direct_links = _deixis-draw-direct-link(
    S_anchor_x,
    S_anchor_y,
    E_anchor_x,
    E_anchor_y,
    waypoints: final_wps,
    link-type: c-link,
    link-stroke: c-link-stroke,
    link-radius: c-link-radius,
    link-marks: c-link-marks,
    source-dir: source_dir,
    target-dir: target_dir,
    is-incoming: is-incoming,
    is-outgoing: is-outgoing,
    extra-data: call_extra,
  )

  for el in direct_links { paths.push(el) }
  return paths
}

/// --------------------
/// Margin link
/// --------------------

#let _deixis-render-margin-links(
  all-notes,
  current-page,
  text-bounds,
  top-bound,
  bottom-bound,
) = {
  let paths = ()

  let font-asc = deixis-utils.resolve-len(0.9em)
  let font-desc = deixis-utils.resolve-len(0.1em)
  let box-h = deixis-utils.resolve-len(0.8em)
  let box-y-offset = 0pt
  let actual-box-h = box-h + 2pt

  let track-drops = (:)
  let track-verticals = (:)

  let left-body-notes = all-notes.filter(n => n.side in (left, "left") and not n.at("is-outgoing", default: false))
  let min-gap-l = 20.0
  if left-body-notes.len() > 0 {
    min-gap-l = calc.min(..left-body-notes.map(n => {
      let nx = n.at("attach-x", default: 0pt)
      return calc.max(0.0, (text-bounds.left - nx) / 1pt)
    }))
  }
  let max-v-lines-l = calc.max(1, calc.floor((min-gap-l - 4.0) / 2.5))

  let right-body-notes = all-notes.filter(n => n.side not in (left, "left") and not n.at("is-outgoing", default: false))
  let min-gap-r = 20.0
  if right-body-notes.len() > 0 {
    min-gap-r = calc.min(..right-body-notes.map(n => {
      let nx = n.at("attach-x", default: 0pt)
      return calc.max(0.0, (nx - text-bounds.right) / 1pt)
    }))
  }
  let max-v-lines-r = calc.max(1, calc.floor((min-gap-r - 4.0) / 2.5))

  for n in all-notes.sorted(key: x => x.at("mark-x", default: 0pt)) {
    let is-incoming = n.at("is-incoming", default: false)
    let is-outgoing = n.at("is-outgoing", default: false)

    if not is-incoming and n.at("mark-page", default: current-page) != current-page { continue }

    let link = n.at("link", default: "none")
    if link in (none, false, "none") { continue }

    let link-stroke = n.at("link-stroke", default: none)
    let link-radius = n.at("link-radius", default: 0pt)
    let link-marks = n.at("link-marks", default: "none")
    let link-waypoints = n.at("link-waypoints", default: auto)

    let actual-mark = link-marks
    if is-incoming {
      if actual-mark == "both" { actual-mark = "end" } else if actual-mark == "start" { actual-mark = "none" }
    } else if is-outgoing {
      if actual-mark == "both" { actual-mark = "start" } else if actual-mark == "end" { actual-mark = "none" }
    }

    let is_left = n.side in (left, "left")
    let bound_x = if is_left { text-bounds.left } else { text-bounds.right }

    let marker-width = n.at("marker-width", default: 0pt)
    let mark-x = n.at("mark-x", default: 0pt)
    let mark-y = n.at("mark-y", default: 0pt)
    let mark-center-x = mark-x + (marker-width / 2)

    let text-size = n.at("text-size", default: auto)
    let t-val = deixis-utils.resolve-len(if text-size != auto and type(text-size) == length { text-size } else { 11pt })

    let has-inline-box = n.at("has-inline-box", default: false)

    let box_top = mark-y - (t-val * if has-inline-box { 0.9 } else { 0.8 })
    let box_bottom = mark-y + (t-val * if has-inline-box { 0.2 } else { 0.05 })

    let box-y = mark-y - (t-val * 0.8)
    let box-x = mark-x - 1.5pt
    let actual-box-h = t-val * 0.85

    let n_top = n.at("final-y", default: 0pt)
    let n_h = n.at("h", default: 0pt)
    let n_w = n.at("w", default: 0pt)
    let n_bottom = n_top + n_h
    let n_x = n.at("attach-x", default: 0pt)

    let safe_pad = calc.min(4.0, (n_h / 1pt) / 2.0)
    let clamp-min = (n_top + (safe_pad * 1pt)) / 1pt
    let clamp-max = (n_bottom - (safe_pad * 1pt)) / 1pt

    clamp-max = calc.max(clamp-min, clamp-max)

    let safe-wps = if link-waypoints != none and type(link-waypoints) == array {
      link-waypoints.filter(x => type(x) == array and x.len() >= 2)
    } else { () }

    let m_y_attach = 0pt
    let n_attach_y = 0pt
    let ideal_y = calc.clamp(mark-y / 1pt, clamp-min, clamp-max) * 1pt

    if is-incoming {
      n_attach_y = clamp-min * 1pt
      m_y_attach = top-bound
    } else if is-outgoing {
      m_y_attach = box_bottom
      n_attach_y = bottom-bound
    } else {
      let goes_up = if safe-wps.len() > 0 { safe-wps.first().at(1) < 0pt } else { ideal_y < mark-y }
      m_y_attach = if goes_up { box_top } else { box_bottom }

      let last_source_y = if safe-wps.len() > 0 { m_y_attach + safe-wps.last().at(1) } else { m_y_attach }
      n_attach_y = calc.clamp(last_source_y / 1pt, clamp-min, clamp-max) * 1pt
    }

    // --- HORIZONTAL ANTI-OVERLAP ---

    let route_down = false
    if is-outgoing {
      route_down = true
    } else if is-incoming {
      route_down = false
    } else {
      route_down = (m_y_attach > mark-y)
    }

    let dir-str = if route_down { "d" } else { "u" }
    let line-key = str(calc.round(mark-y / 1pt)) + "-" + dir-str
    let h-count = track-drops.at(line-key, default: 0)
    track-drops.insert(line-key, h-count + 1)

    let h-cycle = calc.rem(h-count, 4)
    let step-size = t-val * 0.04
    let drop_mag = 0pt

    let base-drop = t-val * 0.05
    let max-drop = t-val * 0.25
    drop_mag = base-drop + (h-cycle * step-size)
    drop_mag = calc.min(drop_mag / 1pt, max-drop / 1pt) * 1pt

    let drop_y = m_y_attach + (if route_down { drop_mag } else { -drop_mag })

    // --- VERTICAL ANTI-OVERLAP ---
    let side-key = if is_left { "l" } else { "r" }
    let v-count = track-verticals.at(side-key, default: 0)
    track-verticals.insert(side-key, v-count + 1)

    let max-v = if is_left { max-v-lines-l } else { max-v-lines-r }
    let v-cycle = calc.rem(v-count, max-v)
    let turn-shift = 2.0 + (v-cycle * 2.5)

    let turn_x = if is_left {
      bound_x - turn-shift * 1pt
    } else {
      bound_x + turn-shift * 1pt
    }

    // draw rectangles
    let highlight = _deixis-draw-marker-highlight(
      mark-x,
      mark-y,
      marker-width,
      n.marker-str,
      stroke: link-stroke,
      text-size: t-val,
      has-inline-box: has-inline-box,
      mark-type: n.at("mark-type", default: "inline"),
    )

    if not is-incoming and highlight != none { paths.push(highlight) }

    // anchors & synthetic waypoints
    let mark-type = n.at("mark-type", default: "inline")
    let S_candidates = ()
    let synth_wps = ()

    let c-ports = n.at("link-ports", default: auto)
    let override-mark = if type(c-ports) == dictionary and "mark" in c-ports { c-ports.mark } else { auto }

    if mark-type == "region" and n.r-pins.len() > 0 {
      let r-pins = n.r-pins
      let reg = n.reg
      let min-x = 1e10pt
      let max-x = -1e10pt
      let min-y = 1e10pt
      let max-y = -1e10pt
      let page-pins = r-pins.filter(p => p.location().page() == current-page)

      if page-pins.len() > 0 {
        for p in page-pins {
          let px = deixis-utils.resolve-signed-len(p.location().position().x)
          let py = deixis-utils.resolve-signed-len(p.location().position().y)
          let p-pad = p.value.at("padding", default: (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt))

          let px-l = px - deixis-utils.resolve-signed-len(p-pad.left)
          let px-r = px + deixis-utils.resolve-signed-len(p-pad.right)
          let py-t = py - deixis-utils.resolve-signed-len(p-pad.top)
          let py-b = py + deixis-utils.resolve-signed-len(p-pad.bottom)

          if px-l < min-x { min-x = px-l }
          if px-r > max-x { max-x = px-r }
          if py-t < min-y { min-y = py-t }
          if py-b > max-y { max-y = py-b }
        }
      } else {
        min-x = mark-center-x
        max-x = mark-center-x
        min-y = m_y_attach
        max-y = m_y_attach
      }

      let reg-pad = deixis-utils.get-margins(reg.styles.at("padding", default: 0pt))
      min-x -= deixis-utils.resolve-signed-len(reg-pad.left)
      max-x += deixis-utils.resolve-signed-len(reg-pad.right)
      min-y -= deixis-utils.resolve-signed-len(reg-pad.top)
      max-y += deixis-utils.resolve-signed-len(reg-pad.bottom)

      let sliding_y = calc.clamp(n_attach_y / 1pt, min-y / 1pt, max-y / 1pt) * 1pt
      if sliding_y < min-y { sliding_y = (min-y + max-y) / 2.0 }

      let r_cx = (min-x + max-x) / 2.0
      let r_cy = (min-y + max-y) / 2.0

      // user-provided ports
      if override-mark == "top" {
        S_candidates = ((x: r_cx, y: min-y, dir: "vertical", id: "top"),)
      } else if override-mark == "bottom" {
        S_candidates = ((x: r_cx, y: max-y, dir: "vertical", id: "bottom"),)
      } else if override-mark == "left" {
        S_candidates = ((x: min-x, y: r_cy, dir: "horizontal", id: "left"),)
      } else if override-mark == "right" {
        S_candidates = ((x: max-x, y: r_cy, dir: "horizontal", id: "right"),)
      } else {
        // Fallback to distance-minimizing sliding port
        let out_x = if is_left { min-x } else { max-x }
        let out_id = if is_left { "left" } else { "right" }
        S_candidates = ((x: out_x, y: sliding_y, dir: "horizontal", id: out_id),)
      }

      let S_pt = S_candidates.first()
      let out_x = S_pt.x
      let out_y = S_pt.y

      // prevent backwards folding if user forces a port that points across the text bounds
      if S_pt.id == "left" and min-x < turn_x {
        turn_x = min-x - turn-shift * 1pt
      } else if S_pt.id == "right" and max-x > turn_x {
        turn_x = max-x + turn-shift * 1pt
      }

      if link-waypoints == auto and link in ("straight-line", "right-angle", "chamfer", "curve", "ccr", "ucr") {
        if S_pt.dir == "vertical" {
          // if port is top/bottom, it must exit vertically into the drop channel first
          if is-outgoing {
            synth_wps = (
              (0pt, drop_y - out_y),
              (turn_x - out_x, 0pt),
              (0pt, bottom-bound - drop_y),
              deixis-waypoint-split,
            )
          } else if is-incoming {
            synth_wps = (deixis-waypoint-split, (0pt, n_attach_y - top-bound))
          } else {
            synth_wps = ((0pt, drop_y - out_y), (turn_x - out_x, 0pt), (0pt, n_attach_y - drop_y))
          }
        } else {
          // horizontal exit
          synth_wps = (
            (turn_x - out_x, 0pt),
            (0pt, n_attach_y - out_y),
          )
        }
      } else {
        if is-outgoing or is-incoming { synth_wps = (deixis-waypoint-split,) }
      }
    } else {
      // inline & phantom mark
      let use_bottom = if override-mark == "bottom" { true } else if override-mark == "top" { false } else {
        route_down
      }
      let out_id = if use_bottom { "bottom" } else { "top" }
      let out_y = if use_bottom { box_bottom } else { box_top }

      S_candidates = (
        (x: mark-center-x, y: out_y, dir: "vertical", id: out_id),
      )

      if link-waypoints == auto and link in ("straight-line", "right-angle", "chamfer", "curve", "ccr", "ucr") {
        if is-outgoing {
          synth_wps = (
            (0pt, drop_y - out_y),
            (turn_x - mark-center-x, 0pt),
            (0pt, bottom-bound - drop_y),
            deixis-waypoint-split,
          )
        } else if is-incoming {
          synth_wps = (deixis-waypoint-split, (0pt, n_attach_y - top-bound))
        } else {
          synth_wps = ((0pt, drop_y - out_y), (turn_x - mark-center-x, 0pt), (0pt, n_attach_y - drop_y))
        }
      } else {
        if is-outgoing or is-incoming { synth_wps = (deixis-waypoint-split,) }
      }
    }

    let D_candidates = (
      (x: n_x, y: n_attach_y, dir: "horizontal", id: if is_left { "right" } else { "left" }),
    )

    let S_page = current-page
    let E_page = current-page
    if is-outgoing { E_page = current-page + 1 } else if is-incoming { S_page = current-page - 1 }

    let extra = (
      bound-dx: bound_x - mark-center-x,
      turn-dx: turn_x - mark-center-x,
      drop-y: drop_y - m_y_attach,
      side: n.side,
    )

    let link-paths = _deixis-route-link(
      n,
      n.at("id", default: "margin"),
      current-page,
      S_page,
      E_page,
      S_candidates,
      D_candidates,
      c-link: link,
      c-link-stroke: link-stroke,
      c-link-radius: link-radius,
      c-link-marks: actual-mark,
      split-default: "target",
      turn-x: turn_x,
      synthetic-waypoints: synth_wps,
      is-margin: true,
      extra-data: extra,
    )

    for el in link-paths { paths.push(el) }
  }
  return paths.join()
}

/// --------------------
/// Inset link
/// --------------------

#let _deixis-render-inset-link(
  data,
  current-page,
  S_page,
  E_page,
  S,
  D_top,
  reg: none,
  r-pins: (),
  c-link: auto,
  c-link-stroke: auto,
  c-link-radius: auto,
  c-link-marks: auto,
) = {
  let internal-id = data.internal-id
  let mark-type = data.at("mark-type", default: "inline")

  let paths = ()
  let is-cross-page = (S_page != E_page)
  let is-outgoing = (is-cross-page and current-page == S_page)
  let is-incoming = (is-cross-page and current-page == E_page)

  let source-candidates = ()
  let m-cx = S.x
  let mark-y = S.y

  // cross-page bounding boxes
  if mark-type == "region" and r-pins.len() > 0 {
    let sorted-pins = r-pins.sorted(key: p => (p.location().page(), p.location().position().y))
    let first_region_page = sorted-pins.first().location().page()
    let last_region_page = sorted-pins.last().location().page()

    let min-x = 1e10pt
    let max-x = -1e10pt
    for p in r-pins {
      let px = deixis-utils.resolve-signed-len(p.location().position().x)
      let p-pad = p.value.at("padding", default: (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt))
      let px-l = px - deixis-utils.resolve-signed-len(p-pad.left)
      let px-r = px + deixis-utils.resolve-signed-len(p-pad.right)
      if px-l < min-x { min-x = px-l }
      if px-r > max-x { max-x = px-r }
    }

    let p-margins = deixis-utils.get-page-margins(S_page)
    let page-h = deixis-utils.resolve-len(if type(page.height) == length { page.height } else { 29.7cm })
    let min-y = deixis-utils.resolve-len(p-margins.top)
    let max-y = page-h - deixis-utils.resolve-len(p-margins.bottom)

    let page-pins = r-pins.filter(p => p.location().page() == S_page)
    if page-pins.len() > 0 {
      let local-min-y = 1e10pt
      let local-max-y = -1e10pt
      for p in page-pins {
        let py = deixis-utils.resolve-signed-len(p.location().position().y)
        let p-pad = p.value.at("padding", default: (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt))
        let py-t = py - deixis-utils.resolve-signed-len(p-pad.top)
        let py-b = py + deixis-utils.resolve-signed-len(p-pad.bottom)
        if py-t < local-min-y { local-min-y = py-t }
        if py-b > local-max-y { local-max-y = py-b }
      }
      if S_page == first_region_page { min-y = local-min-y }
      if S_page == last_region_page { max-y = local-max-y }
    }

    let reg-pad = deixis-utils.get-margins(reg.styles.at("padding", default: 0pt))
    min-x -= deixis-utils.resolve-signed-len(reg-pad.left)
    max-x += deixis-utils.resolve-signed-len(reg-pad.right)
    if S_page == first_region_page { min-y -= deixis-utils.resolve-signed-len(reg-pad.top) }
    if S_page == last_region_page { max-y += deixis-utils.resolve-signed-len(reg-pad.bottom) }

    m-cx = (min-x + max-x) / 2.0
    mark-y = min-y

    source-candidates = (
      (x: m-cx, y: min-y, dir: "vertical", id: "top"),
      (x: m-cx, y: max-y, dir: "vertical", id: "bottom"),
      (x: min-x, y: (min-y + max-y) / 2.0, dir: "horizontal", id: "left"),
      (x: max-x, y: (min-y + max-y) / 2.0, dir: "horizontal", id: "right"),
    )
  }

  // inline marker fallback
  if source-candidates.len() == 0 {
    let mm-elems = query(selector(metadata).and(selector(<deixis-inline-mark>).or(<deixis-phantom-mark>))).filter(m => (
      type(m.value) == dictionary
        and m.value.at("internal-id", default: none) != none
        and str(m.value.internal-id) == str(internal-id)
    ))

    let marker-width = data.at("marker-width", default: 0pt)
    let text-size = data.at("text-size", default: 11pt)

    if mm-elems.len() > 0 {
      let mm-val = mm-elems.first().value
      marker-width = mm-val.at("marker-width", default: marker-width)
      text-size = mm-val.at("text-size", default: text-size)
    }

    let t-val = if type(text-size) == length { text-size } else { 11pt }
    let has-inline-box = data.at("has-inline-box", default: false)

    let mark-x = S.x
    mark-y = S.y
    m-cx = S.x + (marker-width / 2)

    if not is-incoming and mark-type != "region" {
      let highlight = _deixis-draw-marker-highlight(
        mark-x,
        mark-y,
        marker-width,
        data.marker-str,
        stroke: c-link-stroke,
        text-size: t-val,
        has-inline-box: has-inline-box,
        mark-type: mark-type,
      )
      if highlight != none { paths.push(highlight) }
    }

    let box_top = mark-y - (t-val * if has-inline-box { 0.9 } else { 0.8 })
    let box_bottom = mark-y + (t-val * if has-inline-box { 0.2 } else { 0.05 })
    let box_horizon = mark-y - (t-val * 0.3)

    source-candidates = (
      (x: m-cx, y: box_top, dir: "vertical", id: "top"),
      (x: m-cx, y: box_bottom, dir: "vertical", id: "bottom"),
    )
    if data.at("marker-width", default: 0pt) == 0pt {
      source-candidates.push(
        (x: mark-x + marker-width + 1.5pt, y: box_horizon, dir: "horizontal", id: "right"),
      )
      source-candidates.push(
        (x: mark-x - 1.5pt, y: box_horizon, dir: "horizontal", id: "left"),
      )
    } else if data.at("marker-position", default: none) in (right, "right") {
      source-candidates.push(
        (x: mark-x + marker-width + 1.5pt, y: box_horizon, dir: "horizontal", id: "right"),
      )
    } else if data.at("marker-position", default: none) in (left, "left") {
      source-candidates.push(
        (x: mark-x - 1.5pt, y: box_horizon, dir: "horizontal", id: "left"),
      )
    }
  }

  let d-bot-elems = query(selector(data.at("dest-bot-lbl", default: data.body-lbl)))
  let d-left-elems = query(selector(data.at("dest-left-lbl", default: data.body-lbl)))
  let d-right-elems = query(selector(data.at("dest-right-lbl", default: data.body-lbl)))

  let D_bot = if d-bot-elems.len() > 0 { d-bot-elems.last().location().position() } else { D_top }
  let D_left = if d-left-elems.len() > 0 { d-left-elems.last().location().position() } else { D_top }
  let D_right = if d-right-elems.len() > 0 { d-right-elems.last().location().position() } else { D_top }

  let dest-candidates = (
    (x: D_top.x, y: D_top.y, dir: "vertical", id: "top"),
    (x: D_bot.x, y: D_bot.y, dir: "vertical", id: "bottom"),
    (x: D_left.x, y: D_left.y, dir: "horizontal", id: "left"),
    (x: D_right.x, y: D_right.y, dir: "horizontal", id: "right"),
  )

  let routed-links = _deixis-route-link(
    data,
    internal-id,
    current-page,
    S_page,
    E_page,
    source-candidates,
    dest-candidates,
    c-link: c-link,
    c-link-stroke: c-link-stroke,
    c-link-radius: c-link-radius,
    c-link-marks: c-link-marks,
    split-default: "source",
    is-margin: false,
  )

  if type(routed-links) == array {
    paths += routed-links
  } else if routed-links != none {
    paths.push(routed-links)
  }

  return paths
}
