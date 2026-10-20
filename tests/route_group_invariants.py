"""Bounds, junction safety, rollback, affine and ordering controls."""
import copy
import json
from pathlib import Path
import subprocess

root=Path(__file__).resolve().parents[1]
import route_group as ref
OUT=ref.OUT

def main():
    groups=ref.named()
    one=groups[0][1]
    cases=[]
    for name,input in groups:
        cases.append((name,input,dict(rounds=1,**{'max-searches':24})))
    results,_=ref.evaluate(cases,'invariant-base')
    for case,output in zip(cases,results,strict=True):ref.verify(case[1],case[2],output)

    # Zero weight retains native independent geometry: no tie-triggered churn.
    zero=[(name,input,dict(weight=0,rounds=1,**{'max-searches':24})) for name,input in groups]
    records,_=ref.evaluate(zero,'zero')
    for (name,input,options),r in zip(zero,records,strict=True):
        ref.verify(input,options,r)
        assert r['records']==r['baseline'],name
        assert not any(p['decision']=='accept' for p in r['history'])
    print(f'{len(zero)} zero-weight groups retain exact independent incumbents.',flush=True)

    permuted=[];previous=[]
    for case,record in zip(cases,results,strict=True):
        name,input,options=case
        if input.get('obstacles'):
            permuted.append((name,input|dict(obstacles=input['obstacles'][::-1]),options));previous.append(record)
    records,_=ref.evaluate(permuted,'permutations')
    assert records==previous
    print(f'{len(records)} obstacle permutations preserve full search/commit histories.',flush=True)

    def transform(input,factor,offset):
        input=copy.deepcopy(input)
        def point(p):return [p[i]*factor+offset[i] for i in range(2)]
        seen=set()
        for r in [*input.get('obstacles',[]), *([input['bounds']] if 'bounds' in input else []),
                  *(p['bounds'] for p in input.get('pages',[]))]:
            if id(r) in seen:continue
            seen.add(id(r))
            for k in ('left','right'):r[k]=r[k]*factor+offset[0]
            for k in ('top','bottom'):r[k]=r[k]*factor+offset[1]
        for e in input['edges']:
            for role in ('from','to'):
                if isinstance(e[role],dict):e[role]['point']=point(e[role]['point'])
                else:e[role]=point(e[role])
            e['via']=[point(p) for p in e.get('via',[])]
        for key,default in (('clearance',0),('escape',1),('bend-cost',5)):input[key]=input.get(key,default)*factor
        return input

    transformed=[];previous=[]
    for case,record in zip(cases,results,strict=True):
        name,input,options=case
        for factor in (1/1024,8):
            transformed.append((name+str(factor),transform(input,factor,(3.25,-4.5)),options|dict(spacing=3*factor)))
            previous.append((record,factor))
    records,_=ref.evaluate(transformed,'transformations')
    for case,new,(old,factor) in zip(transformed,records,previous,strict=True):
        ref.verify(case[1],case[2],new,oracle=False)
        assert [p['decision'] for p in new['history']]==[p['decision'] for p in old['history']],case[0]
        assert new['expanded']==old['expanded'] and new['limits-hit']==old['limits-hit']
        for a,b in zip(old['records'],new['records'],strict=True):
            assert a['status']==b['status'] and a['stats']==b['stats'] and a['search-id']==b['search-id']
            if a['status']=='ok':
                assert [[p[j]*factor+(3.25,-4.5)[j] for j in range(2)] for p in a['points']]==b['points'],case[0]
        for key in ('length','score','energy','exposure','overlap','raw-overlap','shared'):
            assert abs(old['metrics'][key]*factor-new['metrics'][key])<1e-7,(case[0],key)
    print(f'{len(records)} scaled/translated groups preserve paths, search IDs, decisions and statistics.',flush=True)

    # All speculative work consumes the common budget. Previously checked baseline
    # geometry survives when new tracks, expansions or search-count limits reject it.
    budgets=[('baseline-only',one,{'max-searches':len(one['edges'])}),
             ('partial-greedy',one,{'max-searches':len(one['edges'])+1}),
             ('expansion-limit',one,{'max-expansions':1}),
             ('empty-baseline-cell-cap',one|{'max-cells':1},{}),
             ('lane-track-cell-cap',one|{'max-cells':50},{}),
             ('per-attempt-expansions',one|{'max-expansions':1},{})]
    records,_=ref.evaluate(budgets,'budgets')
    for case,r in zip(budgets,records,strict=True):
        ref.verify(case[1],case[2],r)
        assert r['limits-hit'],case[0]
        if case[0] in ('baseline-only','partial-greedy','lane-track-cell-cap'):assert r['records']==r['baseline']
    print(f'{len(records)} count/expansion/cell budget controls retain only checked incumbents.',flush=True)

    # Single-page plans are unaffected by the placement of other page fragments in
    # the input list when the per-page priority and budgets remain the same.
    pages=next(s for n,s in groups if n=='named-page-junctions')
    major=pages|dict(edges=sorted(pages['edges'],key=lambda e:e['page']))
    records,_=ref.evaluate([('interleaved',pages,{}),('major',major,{})],'page-order')
    for input,r in zip((pages,major),records,strict=True):ref.verify(input,{},r)
    key=lambda output:{(r['id'],r['page']):r['points'] for r in output['records']}
    assert key(records[0])==key(records[1])
    print('Named relays remain page-local under interleaved/page-major input.',flush=True)

    source=OUT/'junction-units.typ'
    source.write_text('''#import "/src/routing/lane-cost.typ": exposure
    #import "/src/routing/group-geometry.typ": pair-metrics
    #let lane = ((axis: 0, fixed: 0, low: 0, high: 10, exempt: ((low: 0, high: 1),)),)
    #assert.eq(exposure((0,0),(10,0),lane,2), 9)
    #assert.eq(exposure((0,1),(10,1),lane,2), 10)
    #assert.eq(exposure((0,2),(10,2),lane,2), 0)
    #assert.eq(exposure((0,0),(1,0),lane,2), 0)
    #assert.eq(exposure((1,0),(10,0),lane,2), 9)
    #let scene = (escape: 1, clearance: 0)
    #let a = (from: (0,0), to: (10,0))
    #let b = (from: (5,-5), to: (10,5))
    #let p = pair-metrics(scene,a,(points: ((0,0),(10,0))),b,(points: ((5,-5),(5,0),(10,0),(10,5))),2)
    #assert.eq(p.contacts, 2)
    #assert.eq(p.crossings, 0)
    #assert.eq(p.overlap, 5)
    // String and native label junctions have one identity. Opposite normals share
    // only the point, never an entire lane or surrounding proximity band.
    #let a = (from: (point: (0,0), normal: (1,0), junction: <hub>), to: (10,0))
    #let b = (from: (point: (0,0), normal: (1,0), junction: "hub"), to: (10,5))
    #let p = pair-metrics(scene,a,(points: ((0,0),(10,0))),b,(points: ((0,0),(1,0),(1,5),(10,5))),2)
    #assert.eq(p.shared, 1)
    #assert.eq(p.overlap, 0)
    #assert.eq(p.contacts, 0)
    ''')
    r=subprocess.run([ref.COMPILER,'compile','--root',str(root),str(source),str(source.with_suffix('.pdf'))],capture_output=True,text=True)
    assert not r.returncode and not r.stderr,r.stderr
    print('Exact common-stub masks, nearby/unshared shafts, T-contacts and string/label junctions pass.',flush=True)

    # A malformed junction must fail before any route can be treated as shared.
    invalid=copy.deepcopy(next(s for n,s in groups if n=='named-source-junction'))
    invalid['edges'][1]['from']['point'][0]+=1
    data=OUT/'invalid-junction.json';data.write_text(json.dumps(invalid))
    source=OUT/'invalid-junction.typ'
    source.write_text('''#import "/tests/helpers/route-group.typ": prepare
    #import "/tests/helpers/route-group.typ": repair
    #let input = json("invalid-junction.json")
    #let _ = repair(prepare(input),input.edges)
    ''')
    r=subprocess.run([ref.COMPILER,'compile','--root',str(root),str(source),str(source.with_suffix('.pdf'))],capture_output=True,text=True)
    assert r.returncode and 'same point on a page' in r.stderr,r.stderr
    print('Conflicting named junction coordinates fail before planning.',flush=True)

if __name__ == '__main__':
    import argparse
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--typst',default='typst')
    args=parser.parse_args(); ref.COMPILER=args.typst
    main()
