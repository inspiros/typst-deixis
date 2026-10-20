"""Independent dense-grid reference and invariants for prepared scene avoidance."""
from pathlib import Path
import copy
import heapq
import json
import math
import random
import subprocess
import time

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "target/stage5-scene"
OUT.mkdir(parents=True, exist_ok=True)
DIRECTIONS = ((1, 0), (0, 1), (-1, 0), (0, -1))


def endpoint(value):
    return value if isinstance(value, dict) else {"point": value}


def inflated(scene):
    pad = scene.get("clearance", 4)
    return [dict(r, left=r["left"]-pad, top=r["top"]-pad,
                 right=r["right"]+pad, bottom=r["bottom"]+pad)
            for r in scene.get("obstacles", [])]


def interior(p, r):
    return r["left"] < p[0] < r["right"] and r["top"] < p[1] < r["bottom"]


def on(p, a, b):
    return ((a[0] == b[0] == p[0] and min(a[1], b[1]) <= p[1] <= max(a[1], b[1]))
            or (a[1] == b[1] == p[1] and min(a[0], b[0]) <= p[0] <= max(a[0], b[0])))


def stub(e, scene):
    p = e["point"]
    normal = e.get("normal")
    length = max(scene.get("clearance", 4), scene.get("escape", 4)) if e.get("owner") is not None else scene.get("escape", 4)
    return tuple(p[i] + (normal[i] * length if normal else 0) for i in range(2))


def visit(stage, a, b, via):
    previous = 0
    while stage < len(via) and on(via[stage], a, b):
        d = sum(abs(via[stage][i]-a[i]) for i in range(2))
        if d < previous:
            break
        previous = d
        stage += 1
    return stage


def validate(scene, result):
    if result["status"] != "ok":
        assert result["points"] == []
        return
    if "boundary" in scene:
        original = endpoint(scene["to"])
        actual = result["points"][-1]
        b = scene["boundary"]
        assert b["left"] <= actual[0] <= b["right"] and actual[1] == original["point"][1]
        preference = abs(actual[0] - b["preferred"])
        assert math.isclose(result["preference"], preference, abs_tol=1e-8)
        assert math.isclose(result["allocation-cost"], result["score"] + preference, abs_tol=1e-8)
        scene = copy.deepcopy(scene)
        scene["to"] = dict(original, point=actual)
    points = result["points"]
    source, target = endpoint(scene["from"]), endpoint(scene["to"])
    assert points[0] == source["point"] and points[-1] == target["point"]
    rects = inflated(scene)
    length = 0
    headings = []
    stage = 0
    via = scene.get("via", [])
    for a, b in zip(points, points[1:]):
        assert a != b and (a[0] == b[0] or a[1] == b[1]), (a, b)
        stage = visit(stage, a, b, via)
        length += sum(abs(b[i]-a[i]) for i in range(2))
        headings.append(DIRECTIONS.index(tuple(0 if a[i] == b[i] else (1 if a[i] < b[i] else -1) for i in range(2))))
        # Split at every relevant boundary, then check open intervals, not samples
        # of arbitrary spacing or the prototype's own intersection predicate.
        axis = 0 if a[1] == b[1] else 1
        lo, hi = sorted((a[axis], b[axis]))
        cuts = {lo, hi}
        for r in rects:
            cuts.update(v for v in (r["left" if axis == 0 else "top"], r["right" if axis == 0 else "bottom"])
                        if lo <= v <= hi)
        for e in (source, target):
            cuts.update(v for v in (e["point"][axis], stub(e, scene)[axis]) if lo <= v <= hi)
        for x, y in zip(sorted(cuts), sorted(cuts)[1:]):
            p = list(a); p[axis] = (x+y)/2
            for r in rects:
                if not interior(p, r):
                    continue
                assert any(e.get("owner") == r.get("id") and on(p, e["point"], stub(e, scene))
                           for e in (source, target)), ("collision", scene, a, b, r)
    if len(points) == 1:
        stage = visit(stage, points[0], points[0], via)
    assert stage == len(via), ("missed ordered via", scene, points)
    if headings and source.get("normal"):
        assert headings[0] == DIRECTIONS.index(tuple(source["normal"]))
    if headings and target.get("normal"):
        assert (headings[-1]+2) % 4 == DIRECTIONS.index(tuple(target["normal"]))
    bends = sum(a != b for a, b in zip(headings, headings[1:]))
    assert math.isclose(length, result["length"], abs_tol=1e-8)
    assert bends == result["bends"]
    assert math.isclose(length + bends*scene.get("bend-cost", 12), result["score"], abs_tol=1e-8)


def dense_cost(scene, choice=False):
    """Unit-lattice Dijkstra, independent of the Hanan graph and A* heuristic."""
    source, target = endpoint(scene["from"]), endpoint(scene["to"])
    start = stub(source, scene)
    rects = inflated(scene)
    bounds = scene["bounds"]
    via = scene.get("via", [])
    penalty = scene.get("bend-cost", 12)

    def allowed(p):
        return (bounds["left"] <= p[0] <= bounds["right"] and bounds["top"] <= p[1] <= bounds["bottom"]
                and not any(interior(p, r) for r in rects))

    def edge(a, b):
        # All rectangle boundaries are integers. A unit edge is clear precisely
        # when its two endpoints and midpoint avoid open rectangle interiors.
        mid = tuple((x+y)/2 for x, y in zip(a, b))
        return allowed(b) and not any(interior(mid, r) for r in rects)

    def valid_endpoint(e, end):
        p = e["point"]
        if not (bounds["left"] <= p[0] <= bounds["right"] and bounds["top"] <= p[1] <= bounds["bottom"]):
            return False
        if not allowed(end):
            return False
        for r in rects:
            if r.get("id") == e.get("owner"):
                continue
            # Integer endpoint stubs: independently enumerate all half steps.
            n = int(sum(abs(end[i]-p[i]) for i in range(2)))
            samples = [tuple(p[i] + (end[i]-p[i])*k/max(1, 2*n) for i in range(2)) for k in range(2*n+1)]
            if any(interior(q, r) for q in samples):
                return False
        return True
    if not valid_endpoint(source, start):
        return None
    if "boundary" in scene:
        b = scene["boundary"]
        terminals = [dict(target, point=[x, target["point"][1]])
                     for x in range(max(b["left"], bounds["left"]), min(b["right"], bounds["right"])+1)]
    else:
        terminals = [target]
    goals = {stub(e, scene): (e["point"], abs(e["point"][0]-scene["boundary"]["preferred"]) if "boundary" in scene else 0)
             for e in terminals if valid_endpoint(e, stub(e, scene))}
    if not goals:
        return None
    if any(not allowed(tuple(p)) for p in via):
        return None
    initial_dir = DIRECTIONS.index(tuple(source["normal"])) if source.get("normal") else 4
    final_dir = (DIRECTIONS.index(tuple(target["normal"]))+2) % 4 if target.get("normal") else 4
    prefix = sum(abs(start[i]-source["point"][i]) for i in range(2))
    initial = (*start, initial_dir, visit(0, source["point"], start, via))
    distances = {initial: prefix}
    heap = [(prefix, initial)]
    best = (math.inf, math.inf, math.inf)
    while heap:
        cost, state = heapq.heappop(heap)
        if cost > best[0]:
            break
        if cost != distances[state]:
            continue
        x, y, direction, stage = state
        if (x, y) in goals:
            point, preference = goals[(x, y)]
            if visit(stage, (x, y), point, via) == len(via) and (final_dir == 4 or direction == 4 or (direction+2) % 4 != final_dir):
                suffix = sum(abs(point[i]-(x, y)[i]) for i in range(2))
                total = cost + suffix + preference + (penalty if final_dir != 4 and direction != 4 and direction != final_dir else 0)
                best = min(best, (total, preference, point[0]))
        for new_direction, delta in enumerate(DIRECTIONS):
            if direction != 4 and (direction+2) % 4 == new_direction:
                continue
            p = (x+delta[0], y+delta[1])
            if not edge((x, y), p):
                continue
            new_stage = visit(stage, (x, y), p, via)
            next_state = (*p, new_direction, new_stage)
            new_cost = cost + 1 + (penalty if direction != 4 and direction != new_direction else 0)
            if new_cost < distances.get(next_state, math.inf):
                distances[next_state] = new_cost
                heapq.heappush(heap, (new_cost, next_state))
    return None if math.isinf(best[0]) else best if choice else best[0]


def named_cases():
    def rect(id, l, t, r, b):
        return dict(id=id, left=l, top=t, right=r, bottom=b)
    bounds = dict(left=0, top=0, right=40, bottom=32)
    base = dict(bounds=bounds, clearance=1, escape=1, **{"bend-cost": 5})
    cards = [rect("a", 1, 8, 6, 14), rect("b", 34, 17, 39, 23), rect("middle", 14, 7, 25, 25)]
    return [
        ("direct", dict(base, **{"from": [2, 2], "to": [37, 28]})),
        ("blocked-line", dict(base, **{"from": [2, 16], "to": [38, 16], "obstacles": [rect("middle", 12, 10, 28, 22)]})),
        ("owned-cards", dict(base, **{"from": dict(point=[6, 11], normal=[1, 0], owner="a"), "to": dict(point=[34, 20], normal=[-1, 0], owner="b"), "obstacles": cards})),
        ("foreign-port-block", dict(base, **{"from": dict(point=[6, 11], normal=[1, 0], owner="a"), "to": [37, 28], "obstacles": cards+[rect("foreign", 6, 10, 9, 13)]})),
        ("overlap", dict(base, **{"from": [2, 16], "to": [38, 16], "obstacles": [rect("a", 10, 6, 22, 19), rect("b", 18, 15, 29, 27)]})),
        ("nested", dict(base, **{"from": [2, 16], "to": [38, 16], "obstacles": [rect("outer", 10, 5, 29, 27), rect("inner", 15, 10, 23, 22)]})),
        ("thin-gutter", dict(base, clearance=0, **{"from": [2, 16], "to": [38, 16], "obstacles": [rect("top", 10, 2, 29, 16), rect("bottom", 10, 16, 29, 30)]})),
        ("bounded-wall", dict(base, **{"from": [2, 16], "to": [38, 16], "obstacles": [rect("wall", 18, -2, 22, 34)]})),
        ("inside", dict(base, **{"from": [16, 16], "to": [38, 16], "obstacles": [rect("middle", 10, 10, 22, 22)]})),
        ("bad-waypoint", dict(base, **{"from": [2, 16], "to": [38, 16], "via": [[16, 16]], "obstacles": [rect("middle", 10, 10, 22, 22)]})),
        ("ordered-vias", dict(base, **{"from": [2, 16], "to": [38, 16], "via": [[9, 26], [30, 4]], "obstacles": [rect("middle", 13, 9, 25, 23)]})),
        ("return", dict(base, **{"from": [3, 4], "to": [3, 4], "via": [[30, 4], [30, 27]]})),
        ("zero", dict(base, **{"from": [3, 4], "to": [3, 4]})),
        ("same-direction-ports", dict(base, **{"from": dict(point=[8, 12], normal=[1, 0]), "to": dict(point=[30, 12], normal=[1, 0])})),
        ("opposed-ports", dict(base, **{"from": dict(point=[8, 12], normal=[-1, 0]), "to": dict(point=[30, 12], normal=[1, 0])})),
        ("cell-budget", dict(base, **{"from": [2, 2], "to": [38, 28], "max-cells": 1})),
        ("search-budget", dict(base, **{"from": [2, 2], "to": [38, 28], "max-expansions": 1})),
        ("stub-bounds", dict(base, **{"from": dict(point=[0, 12], normal=[-1, 0]), "to": [30, 12]})),
    ]


def random_cases(count=240):
    rng = random.Random(20261018)
    cases = []
    for i in range(count):
        scene = dict(bounds=dict(left=0, top=0, right=24, bottom=20), clearance=i % 2, escape=1, **{"bend-cost": [0, 2, 5, 12][i % 4]})
        scene["from"] = dict(point=[rng.randrange(25), rng.randrange(21)])
        scene["to"] = dict(point=[rng.randrange(25), rng.randrange(21)])
        for name in ("from", "to"):
            if rng.randrange(3) == 0:
                scene[name]["normal"] = list(rng.choice(DIRECTIONS))
        obstacles = []
        for j in range(i % 6):
            x, y = rng.randrange(2, 19), rng.randrange(2, 15)
            obstacles.append(dict(id=str(j), left=x, top=y, right=x+rng.randrange(1, 5), bottom=y+rng.randrange(1, 5)))
        scene["obstacles"] = obstacles
        if i % 4 == 0:
            scene["via"] = [[rng.randrange(25), rng.randrange(21)] for _ in range(i % 3+1)]
        cases.append((f"random-{i}", scene))
    return cases


def boundary_cases():
    rng = random.Random(20261019)
    bounds = dict(left=0, top=0, right=24, bottom=20)
    base = dict(bounds=bounds, clearance=1, escape=1, **{"bend-cost": 5},
                boundary=dict(left=0, right=24, preferred=12),
                **{"from": [3, 5], "to": dict(point=[12, 20], normal=[0, -1])})
    def obstacle(l, t, r, b):
        return dict(id="box", left=l, top=t, right=r, bottom=b)
    cases = [
        ("boundary-blocked", dict(base, obstacles=[obstacle(8, 16, 16, 22)])),
        ("boundary-disconnected", dict(base, obstacles=[obstacle(8, -2, 10, 22)])),
        ("boundary-closed", dict(base, obstacles=[obstacle(-2, 16, 26, 22)])),
        ("boundary-final-visit", dict(base, escape=4, via=[[12, 19]])),
        ("boundary-clip", dict(base, boundary=dict(left=10, right=14, preferred=30))),
        ("boundary-owned", dict(base, obstacles=[obstacle(1, 2, 4, 7)],
                                **{"from": dict(point=[4, 5], normal=[1, 0], owner="box")})),
    ]
    for i in range(150):
        scene = dict(base, **{"bend-cost": (0, 2, 5, 12)[i % 4]}, clearance=i % 2)
        y, normal = (20, [0, -1]) if i % 2 else (0, [0, 1])
        preferred = rng.randrange(-4, 29)
        scene.update(boundary=dict(left=0, right=24, preferred=preferred),
                     **{"from": dict(point=[rng.randrange(1, 24), rng.randrange(2, 19)]),
                        "to": dict(point=[preferred, y], normal=normal)})
        if i % 3 == 0:
            scene["from"]["normal"] = list(rng.choice(DIRECTIONS))
        scene["obstacles"] = []
        for j in range(i % 6):
            x, y0 = rng.randrange(2, 21), rng.randrange(-1, 19)
            scene["obstacles"].append(dict(id=str(j), left=x, top=y0, right=x+rng.randrange(1, 4), bottom=y0+rng.randrange(1, 4)))
        if i % 4 == 0:
            scene["via"] = [[rng.randrange(1, 24), rng.randrange(1, 20)] for _ in range(i % 3+1)]
        cases.append((f"boundary-random-{i}", scene))
    return cases


def evaluate(cases, stem="checks"):
    source = OUT / f"{stem}.typ"
    data = OUT / f"{stem}.json"
    data.write_text(json.dumps([scene for _, scene in cases]))
    source.write_text('''#import "/src/lib.typ": deixis-routing-scene, deixis-route
#import "/src/routing/scene.typ": _deixis-scene-endpoint, _deixis-scene-port
#import "/src/routing/scene-path.typ": _deixis-scene-orthogonal
#import "/src/routing/sliding.typ": _deixis-sliding-ports
#let results = json("''' + data.name + '''").map(input => {
  let lengths(r) = r.pairs().fold((:), (out, pair) => out + ((pair.first()): pair.last()*1pt))
  let scene = deixis-routing-scene(
    nodes: input.at("obstacles", default: ()).map(r => (id: r.id, bounds: lengths(r.pairs().filter(((k, v)) => k != "id").fold((:), (out, pair) => out + ((pair.first()): pair.last()))))),
    clearance: input.at("clearance", default: 4)*1pt, escape: input.at("escape", default: 4)*1pt,
    bend-cost: input.at("bend-cost", default: 12)*1pt,
    bounds: if "bounds" in input { lengths(input.bounds) } else { none },
    max-cells: input.at("max-cells", default: 4096), max-expansions: input.at("max-expansions", default: 50000))
  let endpoint(e) = if type(e) == array { e.map(v => v*1pt) } else { e + (point: e.point.map(v => v*1pt)) }
  let r = if "boundary" in input or "sources" in input or "targets" in input or "sliding" in input {
    let a = _deixis-scene-endpoint(scene, endpoint(input.from))
    let b = _deixis-scene-endpoint(scene, endpoint(input.to))
    let ports(key, peer) = if key not in input { none } else {
      input.at(key).map(e => _deixis-scene-port(_deixis-scene-endpoint(scene, endpoint(e)), peer))
    }
    let start = _deixis-scene-port(a, b.center)
    let end = _deixis-scene-port(b, a.center)
    let sources = ports("sources", b.center); let targets = ports("targets", a.center)
    if "sliding" in input {
      let attach(e, key) = {
        let span = input.sliding.at(key, default: none)
        e + (sliding: if span == none { none } else { span + (min: span.min*1pt, max: span.max*1pt) })
      }
      let expanded = _deixis-sliding-ports((attach(start, "source"),), (attach(end, "target"),),
        scene.planes.first(), input.at("via", default: ()), scene.clearance, scene.escape)
      sources = expanded.source
      targets = if "boundary" in input { none } else { expanded.target }
    }
    _deixis-scene-orthogonal(scene, scene.planes.first(), start, end, input.at("via", default: ()), none,
      boundary: input.at("boundary", default: none), sources: sources, targets: targets)
  } else {
    deixis-route(scene: scene, from: endpoint(input.from), to: endpoint(input.to),
      route: "orthogonal", via: input.at("via", default: ()).map(p => p.map(v => v*1pt)))
  }
  if r.status != "ok" { return (status: r.status, points: (), stats: r.stats) }
  ((status: r.status, points: ((r.start,) + r.segments.map(s => s.end)).map(p => p.zip(r.origin).map(((v, o)) => (v+o).pt())),
    length: r.length.pt(), bends: r.search.bends, score: r.search.score.pt(), stats: r.search)
    + (if "boundary" in input { (preference: r.search.preference.pt(), allocation-cost: r.search.allocation-cost.pt()) } else { (:) })
    + if "selection" in r { (selection: r.selection.pairs().fold((:), (out, pair) =>
      out + ((pair.first()): pair.last() + (point: pair.last().point.map(v => v.pt()))))) } else { (:) })
})
''')
    begin = time.perf_counter()
    result = subprocess.run(["typst", "eval", "--root", str(ROOT), "--in", str(source), "--format", "json",
                             f'{{import "/target/stage5-scene/{stem}.typ": results; results}}'],
                            text=True, capture_output=True, timeout=180)
    assert result.returncode == 0 and not result.stderr, result.stderr
    records = json.loads(result.stdout)
    (OUT / f"{stem}-results.json").write_text(json.dumps(records, indent=2))
    return records, time.perf_counter()-begin


def transform(scene, factor, offset):
    scene = copy.deepcopy(scene)
    def p(value):
        return [value[i]*factor+offset[i] for i in range(2)]
    for key in ("from", "to"):
        if isinstance(scene[key], dict): scene[key]["point"] = p(scene[key]["point"])
        else: scene[key] = p(scene[key])
    for rect in [*scene.get("obstacles", []), *([scene["bounds"]] if scene.get("bounds") else [])]:
        for key in ("left", "right"): rect[key] = rect[key]*factor+offset[0]
        for key in ("top", "bottom"): rect[key] = rect[key]*factor+offset[1]
    if "via" in scene: scene["via"] = [p(v) for v in scene["via"]]
    if "boundary" in scene:
        scene["boundary"] = {key: value*factor+offset[0] for key, value in scene["boundary"].items()}
    for key, default in (("clearance", 4), ("escape", 4), ("bend-cost", 12)):
        scene[key] = scene.get(key, default)*factor
    return scene


if __name__ == "__main__":
    cases = named_cases()+random_cases()
    records, elapsed = evaluate(cases)
    counts = {}
    for (name, scene), result in zip(cases, records, strict=True):
        validate(scene, result)
        counts[result["status"]] = counts.get(result["status"], 0)+1
        if "max-cells" in scene or "max-expansions" in scene:
            assert result["status"] == "budget"
            continue
        reference = dense_cost(scene)
        assert (result["status"] == "ok") == (reference is not None), (name, result, reference)
        if reference is not None:
            assert abs(result["score"]-reference) < 1e-7, (name, result, reference)
    print(f'{len(cases)} production scenes match independent unit-grid Dijkstra; {counts}; Typst batch {elapsed:.3f}s.', flush=True)
    stable = [(name+"-reversed", dict(scene, obstacles=list(reversed(scene.get("obstacles", [])))))
              for name, scene in cases if scene.get("obstacles")]
    other, _ = evaluate(stable, "permutations")
    indexed = {name: record for (name, _), record in zip(cases, records, strict=True)}
    for (name, _), record in zip(stable, other, strict=True):
        assert record == indexed[name.removesuffix("-reversed")], (name, record)
    print(f'{len(stable)} rectangle-order permutations preserve exact routes and statistics.', flush=True)
    transformed = [(f'{name}-{factor}', transform(scene, factor, (17.25, -11.5)))
                   for name, scene in named_cases() for factor in (0.1, 0.125, 10)]
    other, _ = evaluate(transformed, "transformations")
    for ((name, original), original_result) in zip(named_cases(), records, strict=False):
        for factor in (0.1, 0.125, 10):
            key = f'{name}-{factor}'
            scene, record = next((s, r) for (n, s), r in zip(transformed, other, strict=True) if n == key)
            validate(scene, record)
            assert record["status"] == original_result["status"], (key, record)
            if record["status"] == "ok":
                assert math.isclose(record["score"], original_result["score"]*factor, abs_tol=1e-7), (key, record)
    print(f'{len(transformed)} translated/scaled scenes preserve outcomes and weighted optimum costs.', flush=True)

    cases = boundary_cases()
    records, elapsed = evaluate(cases, "boundary-checks")
    counts = {}
    for (name, scene), record in zip(cases, records, strict=True):
        validate(scene, record)
        reference = dense_cost(scene, choice=True)
        assert (record["status"] == "ok") == (reference is not None), (name, record, reference)
        if reference is not None:
            actual = (record["allocation-cost"], record["preference"], record["points"][-1][0])
            assert all(math.isclose(a, b, abs_tol=1e-7) for a, b in zip(actual, reference, strict=True)), (name, actual, reference)
        counts[record["status"]] = counts.get(record["status"], 0)+1
    print(f'{len(cases)} boundary scenes match independent dense Dijkstra over every integer socket; {counts}; Typst batch {elapsed:.3f}s.', flush=True)
    stable = [(name+"-reversed", dict(scene, obstacles=list(reversed(scene.get("obstacles", [])))))
              for name, scene in cases if scene.get("obstacles")]
    other, _ = evaluate(stable, "boundary-permutations")
    indexed = {name: record for (name, _), record in zip(cases, records, strict=True)}
    for (name, _), record in zip(stable, other, strict=True):
        assert record == indexed[name.removesuffix("-reversed")], (name, record)
    print(f'{len(stable)} boundary obstacle permutations preserve exact routes and statistics.', flush=True)
    transformed = [(f'{name}-{factor}', transform(scene, factor, (17.25, -11.5)))
                   for name, scene in cases[:6] for factor in (0.1, 0.125, 10)]
    other, _ = evaluate(transformed, "boundary-transformations")
    for (name, scene), record in zip(transformed, other, strict=True):
        validate(scene, record)
        original, factor = name.rsplit("-", 1)
        expected = indexed[original]
        assert record["status"] == expected["status"], (name, record)
        if record["status"] == "ok":
            assert math.isclose(record["allocation-cost"], expected["allocation-cost"]*float(factor), abs_tol=1e-7)
    print(f'{len(transformed)} boundary transformations preserve outcomes and weighted costs.', flush=True)
