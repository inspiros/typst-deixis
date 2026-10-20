"""Exact lane-index queries, full-history parity and bounded fallback controls."""
import argparse
import json
import math
from pathlib import Path
import random
import subprocess

root = Path(__file__).resolve().parents[1]
import route_group as ref
out = ref.OUT


def direct():
    rng = random.Random(70431)
    cases = []
    for scale, offset in ((1, 0), (1/1024, 3.25), (0.1, -0.3), (1, 1e9), (1e-200, 0)):
        for count in (0, 1, 8, 32, 128):
            lanes = []
            for _ in range(count):
                low = rng.randrange(-8, 8)*scale + offset
                lanes.append(dict(axis=rng.randrange(2), fixed=rng.randrange(-8, 8)*scale+offset,
                    low=low, high=low+rng.randrange(1, 9)*scale,
                    exempt=[dict(low=low, high=low+scale)] if rng.random()<0.4 else []))
            spacing = 3*scale
            coordinates = {offset, offset+scale, offset+spacing}
            for s in lanes[:8]:
                for c in (s['fixed'], s['fixed']-spacing, s['fixed']+spacing):
                    coordinates.update((c, math.nextafter(c, -math.inf), math.nextafter(c, math.inf)))
            coordinates = sorted(coordinates)
            queries = []
            for axis in (0, 1):
                for fixed in coordinates:
                    a, b = [offset-9*scale, fixed], [offset+9*scale, fixed]
                    if axis: a.reverse(); b.reverse()
                    queries.extend(((a, b), (b, a), (a, a)))
            # A fixed coordinate not present in the prepared lattice must scan.
            queries.append(([offset, offset+0.375*scale], [offset+scale, offset+0.375*scale]))
            cases.append(dict(lanes=lanes, spacing=spacing, xs=coordinates, ys=coordinates, queries=queries))
    data = out/'index-queries.json'; data.write_text(json.dumps(cases))
    source = out/'index-queries.typ'
    source.write_text('''#import "/src/routing/lane-cost.typ": exposure
#import "/src/routing/lane-index.typ": prepare-costs, indexed-exposure
#let results = json("index-queries.json").map(c => {
  let index = prepare-costs(c.lanes,c.spacing,c.xs,c.ys,min-lanes: 0,max-checks: 100000,max-entries: 100000)
  assert.eq(index.kind,"index")
  for (a,b) in c.queries {
    assert.eq(indexed-exposure(a,b,index),exposure(a,b,c.lanes,c.spacing))
  }
  (input: c, queries: c.queries.len(), checks: index.checks, entries: index.entries,
    values: c.queries.map(((a,b)) => indexed-exposure(a,b,index)))
})
#let c = json("index-queries.json").at(3)
#let small = prepare-costs(c.lanes,c.spacing,c.xs,c.ys,min-lanes: 999)
#let rows = prepare-costs(c.lanes,c.spacing,c.xs,c.ys,max-rows: 1)
#let checks = prepare-costs(c.lanes,c.spacing,c.xs,c.ys,max-checks: 1)
#let entries = prepare-costs(c.lanes,c.spacing,c.xs,c.ys,max-entries: 1)
#assert.eq((small.reason,rows.reason,checks.reason,entries.reason),("small","rows","checks","entries"))
#for (a,b) in c.queries {
  for i in (small,rows,checks,entries) { assert.eq(indexed-exposure(a,b,i),exposure(a,b,c.lanes,c.spacing)) }
}
// Build adjacent floats natively: the JSON decoder can round decimal neighbours
// to the same binary float before the library ever sees them.
#let adjacent = (3 - calc.pow(2,-51),3,3 + calc.pow(2,-51))
#let lane = ((axis: 0,fixed: 0,low: 0,high: 10),)
#let index = prepare-costs(lane,3,(0,10),adjacent,min-lanes: 0)
#assert.eq(adjacent.map(y => indexed-exposure((0,y),(10,y),index)),(10,0,0))
''')
    p = subprocess.run([ref.COMPILER,'eval','--root',str(root),'--in',str(source),
        '{import "/target/route-group/index-queries.typ": results; results}'],text=True,capture_output=True,timeout=120)
    assert not p.returncode and not p.stderr, p.stderr
    results = json.loads(p.stdout)
    for r in results:
        # Audit the exact native-decoded input, not Python's independently
        # rounded interpretation of JSON decimal neighbours.
        c = r.pop('input')
        for (a,b),actual in zip(c['queries'],r['values'],strict=True):
            expected = 0
            if a != b:
                axis = 0 if a[1] == b[1] else 1
                low,high = sorted((a[axis],b[axis])); fixed = a[1-axis]
                for s in c['lanes']:
                    if s['axis'] != axis or abs(s['fixed']-fixed) >= c['spacing']: continue
                    l,h = max(low,s['low']),min(high,s['high'])
                    shared = sum(max(0,min(h,e['high'])-max(l,e['low'])) for e in s['exempt']) if fixed == s['fixed'] else 0
                    expected += max(0,h-l-shared)
            assert math.isclose(actual,expected,rel_tol=1e-14,abs_tol=0), (c,a,b,actual,expected)
    (out/'index-query-results.json').write_text(json.dumps(results,indent=2))
    print(f'{len(cases)} lane sets / {sum(r["queries"] for r in results)} exact scanner/index queries; '
          'strict spacing/adjacent floats, reverse/zero/off-lattice queries, masks, tiny coordinates, '
          'independent Python costs and all caps pass.',flush=True)


def parity():
    cases = [(n,s,dict(rounds=1,**{'max-searches':24})) for n,s in ref.named()]
    margin = json.loads((root/'tests/fixtures/route-group-margin.json').read_text())
    cases.append(('measured-margin',margin,{}))
    for count in (4,8,16):
        scene=dict(bounds=dict(left=0,top=0,right=160,bottom=100),escape=1,clearance=0,
            **{'bend-cost':5},edges=[dict(id=str(i),**{
                'from':dict(point=[4,12+2*i],normal=[1,0]),
                'to':dict(point=[156,12+2*i],normal=[-1,0])}) for i in range(count)])
        cases.append((f'dense-{count}',scene,dict(rounds=1,**{'max-searches':32})))
    baseline,_=ref.evaluate([(n,s,o|{'cost-options':{'cost-backend':'scan'}}) for n,s,o in cases],'index-scan')
    for backend in ('index','auto'):
        records,_=ref.evaluate([(n,s,o|{'cost-options':{'cost-backend':backend}}) for n,s,o in cases],'index-'+backend)
        assert records==baseline,backend
    for (_,s,o),r in zip(cases,baseline,strict=True):ref.verify(s,o,r,oracle=False)
    caps=[(k,margin,{'cost-options':{'cost-backend':'index',k:0}})
          for k in ('cost-max-rows','cost-max-checks','cost-max-entries')]
    records,_=ref.evaluate(caps,'index-cap-histories')
    assert all(r==baseline[len(ref.named())] for r in records)
    print(f'{len(cases)} groups preserve exact full scanner/index/adaptive histories; all index caps retain checked repair.',flush=True)


if __name__ == '__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--typst',default='typst')
    args=parser.parse_args();ref.COMPILER=args.typst
    direct()
    parity()
