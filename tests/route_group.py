"""Independent search, junction, whole-group metric and commit audit."""
from pathlib import Path
import collections
import copy
import json
import math
import subprocess
import time

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'target/route-group'; OUT.mkdir(parents=True,exist_ok=True)
import route_group_reference as reference
from scene_avoidance import endpoint, stub, validate


COMPILER = "typst"

def evaluate(cases,name):
    data=OUT/f'{name}.json'
    data.write_text(json.dumps([dict(name=n,input=s,options=o) for n,s,o in cases]))
    source=OUT/f'{name}.typ'
    source.write_text('#import "/tests/helpers/route-group.typ": prepare\n'
        '#import "/tests/helpers/route-group.typ": repair, sequence\n'
        f'#let cases = json("{data.name}")\n'
        '#let results = cases.map(c => {\n'
        '  let options = c.options\n'
        '  let mode = options.remove("mode", default: "repair")\n'
        '  if mode == "sequence" { sequence(prepare(c.input),c.input.edges,..options) }\n'
        '  else { repair(prepare(c.input),c.input.edges,..options) }\n'
        '})\n')
    start=time.perf_counter()
    p=subprocess.run([COMPILER,'eval','--root',str(ROOT),'--in',str(source),
        '{import "/'+str(source.relative_to(ROOT))+'": results; results}'],capture_output=True,text=True,timeout=180)
    assert not p.returncode and not p.stderr,p.stderr
    result=json.loads(p.stdout)
    (OUT/f'{name}-results.json').write_text(json.dumps(result,indent=2))
    return result,time.perf_counter()-start


def interval(a,b):
    if a==b:return None
    axis=0 if a[1]==b[1] else 1
    assert a[1-axis]==b[1-axis]
    return (axis,a[1-axis],min(a[axis],b[axis]),max(a[axis],b[axis]))


def zones(input,a,b):
    if a.get('page')!=b.get('page'):return [],[]
    shared_points=[]; spans=[]
    for role in ('from','to'):
        p=endpoint(a[role])
        for other_role in ('from','to'):
            q=endpoint(b[other_role])
            if not p.get('junction') or p.get('junction')!=q.get('junction'):continue
            assert p['point']==q['point']
            shared_points.append(tuple(p['point']))
            x=interval(p['point'],stub(p,reference.scene_for(input,a)))
            y=interval(q['point'],stub(q,reference.scene_for(input,b)))
            if x and y and x[:2]==y[:2] and min(x[3],y[3])>max(x[2],y[2]):
                spans.append((x[0],x[1],max(x[2],y[2]),min(x[3],y[3])))
    # One junction can occur at both ends of a returning edge: union all spans.
    grouped=collections.defaultdict(list)
    for axis,fixed,low,high in spans:grouped[axis,fixed].append((low,high))
    merged=[]
    for (axis,fixed),ranges in sorted(grouped.items()):
        union=[]
        for low,high in sorted(ranges):
            if union and low<=union[-1][1]:union[-1][1]=max(high,union[-1][1])
            else:union.append([low,high])
        merged.extend((axis,fixed,low,high) for low,high in union)
    return shared_points,merged


def on(p,s):
    axis,fixed,low,high=s
    return p[1-axis]==fixed and low<=p[axis]<=high


def pair_metrics(input,a,ar,b,br,spacing):
    left=reference.reservations(ar['points']); right=reference.reservations(br['points'])
    points,shared=zones(input,a,b)
    raw=accidental=near=0
    contacts=set(); proper=set(); benign=set()
    def contact(p,is_proper):
        p=tuple(p)
        if p in points or any(on(p,s) for s in shared):benign.add(p)
        else:
            contacts.add(p)
            if is_proper:proper.add(p)
    if left and right:
        for p in (ar['points'][0],ar['points'][-1]):
            if any(on(p,s) for s in right):contact(p,False)
        for p in (br['points'][0],br['points'][-1]):
            if any(on(p,s) for s in left):contact(p,False)
    for x in left:
        for y in right:
            axis,fixed,low,high=x
            if axis==y[0]:
                l,h=max(low,y[2]),min(high,y[3])
                size=max(0,h-l)
                exempt=sum(max(0,min(h,s[3])-max(l,s[2])) for s in shared
                           if s[0]==axis and fixed==y[1]==s[1])
                if fixed==y[1]:
                    raw+=size;accidental+=max(0,size-exempt)
                    if l==h:contact((l,fixed) if axis==0 else (fixed,l),False)
                if abs(fixed-y[1])<spacing:near+=max(0,size-exempt)
            else:
                p=(y[1],fixed) if axis==0 else (fixed,y[1])
                if on(p,x) and on(p,y):contact(p,low<p[axis]<high and y[2]<p[y[0]]<y[3])
    return dict(overlap=accidental,**{'raw-overlap':raw,'shared':max(0,raw-accidental),'exposure':near,
        'contacts':len(contacts),'crossings':len(proper),'touches':len(contacts)-len(proper),'junction-contacts':len(benign)})


def metrics(input,records,options):
    m=dict(missing=0,overlap=0,**{'raw-overlap':0,'shared':0,'exposure':0,'length':0,'score':0,
                                'contacts':0,'crossings':0,'touches':0,'junction-contacts':0})
    for i,r in enumerate(records):
        if r['status']!='ok':m['missing']+=1;continue
        m['length']+=r['length'];m['score']+=r['score']
        for j in range(i):
            other=records[j]
            if other['status']=='ok' and r['page']==other['page']:
                for key,value in pair_metrics(input,input['edges'][i],r,input['edges'][j],other,options.get('spacing',3)).items():m[key]+=value
    m['energy']=m['score']+options.get('weight',4)*m['exposure']
    return m


def equal(a,b):
    assert a.keys()==b.keys(),(a.keys(),b.keys())
    for k in a:assert math.isclose(a[k],b[k],rel_tol=1e-9,abs_tol=1e-8),(k,a,b)


def decision(base,incumbent,candidate,before,after,options):
    for i,old in enumerate(incumbent):
        if old['status']=='ok' and candidate[i]['status']!='ok':return 'lost-route'
        if candidate[i]['status']=='ok':
            if base[i]['status']!='ok':return 'no-reference'
            if candidate[i]['length']>base[i]['length']*options.get('length-ratio',1.25)+options.get('length-extra',0):return 'detour'
    if after['contacts']>before['contacts'] or after['crossings']>before['crossings']:return 'contacts'
    if after['overlap']>before['overlap']:return 'overlap'
    tolerance=max(abs(before['energy']),abs(after['energy']))*1e-10
    if after['energy']>=before['energy']-tolerance:return 'no-improvement'
    return 'accept'


def verify_searches(input,options,output,oracle=True):
    prior={};charged=0
    for entry in output['searches']:
        r=entry['record']; index=r['edge-index']; edge=input['edges'][index]
        assert r['search-id']==len(prior)
        remaining=min(input.get('max-expansions',50000),options.get('max-expansions',50000)-charged)
        assert remaining>0
        charged+=min(remaining,r['stats'].get('expanded',0))
        scene=reference.scene_for(input,edge)
        against=[prior[sid] for sid in entry['against']]
        assert all(x['status']=='ok' and x['page']==r['page'] and x['edge-index']!=index for x in against)
        validate(scene,r)
        if oracle and r['status']!='budget':
            def unit_charge(p,axis):
                count=0
                for old in against:
                    _,shared=zones(input,edge,input['edges'][old['edge-index']])
                    for ax,fixed,low,high in reference.reservations(old['points']):
                        if ax==axis and abs(fixed-p[1-axis])<options.get('spacing',3) and low<p[axis]<high:
                            if not (fixed==p[1-axis] and any(s[0]==axis and s[1]==fixed and s[2]<p[axis]<s[3] for s in shared)):
                                count+=1
                return count
            optimum=reference.dense(scene,[],options|dict(policy=entry['policy']),unit_charge=unit_charge)
            assert (r['status']=='ok')==(optimum is not None),(index,r,optimum,entry)
            if optimum is not None:assert math.isclose(r['weighted-score'],optimum,abs_tol=1e-7),(index,r,optimum)
        prior[r['search-id']]=r
    assert len(output['searches'])<=options.get('max-searches',64)
    assert output['expanded']<=options.get('max-expansions',50000)
    assert output['expanded']==charged


def verify(input,options,output,oracle=True):
    verify_searches(input,options,output,oracle)
    equal(metrics(input,output['records'],options),output['metrics'])
    if options.get('mode')=='sequence':return
    base=output['baseline'];incumbent=base
    equal(metrics(input,base,options),output['baseline-metrics'])
    counts=collections.Counter()
    for proposal in output['history']:
        assert len({input['edges'][i].get('page') for i in proposal['indices']})==1
        before=metrics(input,incumbent,options)
        equal(before,proposal['before'])
        if proposal['candidate'] is None:
            assert proposal['decision']=='search-failure';continue
        candidate=copy.deepcopy(incumbent)
        for r in proposal['changes']:candidate[r['edge-index']]=r
        after=metrics(input,candidate,options)
        equal(after,proposal['candidate'])
        expected=decision(base,incumbent,candidate,before,after,options)
        assert expected==proposal['decision'],(expected,proposal)
        counts[expected]+=1
        if expected=='accept':incumbent=candidate
    assert incumbent==output['records']
    assert output['metrics']['energy']<=output['baseline-metrics']['energy']+1e-7
    return counts


def named():
    groups=reference.named()
    shared=copy.deepcopy(next(s for n,s in groups if n=='shared-stub'))
    for e in shared['edges']:e['from']['junction']='hub'
    groups += [('named-source-junction',shared)]
    shared_target=copy.deepcopy(shared)
    for e in shared_target['edges']:e['from'],e['to']=e['to'],e['from']
    groups += [('named-target-junction',shared_target)]
    mixed=copy.deepcopy(shared)
    mixed['edges'][0]['from'],mixed['edges'][0]['to']=mixed['edges'][0]['to'],mixed['edges'][0]['from']
    groups += [('named-mixed-junction',mixed)]
    pages=copy.deepcopy(next(s for n,s in groups if n=='page-fragments'))
    for e in pages['edges']:
        role='to' if e['page']==1 else 'from'
        e[role]['junction']='relay'
    groups += [('named-page-junctions',pages)]
    opposite=copy.deepcopy(shared)
    opposite['edges'][1]['from']['normal']=[-1,0]
    groups += [('opposite-junction-normals',opposite)]
    point=copy.deepcopy(shared)
    for e in point['edges']:del e['from']['normal']
    groups += [('zero-stub-junction',point)]
    owned=copy.deepcopy(shared)
    for e in owned['edges']:e['from']['point']=[8,10]
    owned['edges'][0]['from']['owner']='card'
    owned['clearance']=1
    owned['obstacles']=[dict(id='card',left=1,right=8,top=6,bottom=14)]
    groups += [('junction-does-not-own-foreign-node',owned)]
    return groups


def main():
    cases=[(n,s,dict(rounds=1,**{'max-searches':32})) for n,s in named()+reference.random_groups(15)]
    cases += [(n+'-strict',s,dict(mode='sequence',policy='reserved',spacing=2)) for n,s in named() if 'junction' in n or n=='shared-stub']
    results,elapsed=evaluate(cases,'checks')
    counts=collections.Counter();solves=0
    for (name,input,options),output in zip(cases,results,strict=True):
        counts.update(verify(input,options,output));solves+=len(output['searches'])
        print('PASS',name,output['metrics'],flush=True)
    print(f'{len(cases)} groups / {solves} independently checked searches; native batch {elapsed:.3f}s; decisions {dict(counts)}.',flush=True)
    public_adapter(cases,results)


def public_adapter(cases,checked):
    selected=[(c,r) for c,r in zip(cases,checked,strict=True)
        if c[2].get('mode','repair')=='repair'
        and all(not endpoint(e[role]).get('junction') for e in c[1]['edges'] for role in ('from','to'))]
    data=OUT/'public-adapter.json'
    data.write_text(json.dumps([dict(input=c[1],options=c[2]) for c,_ in selected]))
    source=OUT/'public-adapter.typ'
    source.write_text('#import "/tests/helpers/route-group.typ": public-plan\n'
        '#let results = json("public-adapter.json").map(c => public-plan(c.input,c.options))\n')
    p=subprocess.run([COMPILER,'eval','--root',str(ROOT),'--in',str(source),
        '{import "/target/route-group/public-adapter.typ": results; results}'],capture_output=True,text=True,timeout=180)
    assert not p.returncode and not p.stderr,p.stderr
    values=json.loads(p.stdout)
    (OUT/'public-adapter-results.json').write_text(json.dumps(values,indent=2))
    for ((name,scene,options),expected),actual in zip(selected,values,strict=True):
        for public,raw in zip(actual['records'],expected['records'],strict=True):
            for key in public:
                if key=='points':
                    assert len(public[key])==len(raw[key]),(name,public,raw)
                    assert all(math.isclose(a,b,abs_tol=1e-7) for p,q in zip(public[key],raw[key],strict=True)
                        for a,b in zip(p,q,strict=True)),(name,public,raw)
                else: assert public[key]==raw[key],(name,key,public,raw)
        for label,key in (('before','baseline-metrics'),('after','metrics')):
            equal(actual[label],{k:expected[key][k] for k in actual[label]})
        assert actual['stats']==dict(searches=len(expected['searches']),expanded=expected['expanded'],
            rounds=expected['rounds-run'],**{'limits-hit':expected['limits-hit']}),name
    print(f'{len(selected)} public adapter groups match checked geometry, quality, failures and work accounting.',flush=True)

if __name__=='__main__':
    import argparse
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--typst',default='typst')
    args=parser.parse_args(); COMPILER=args.typst
    main()
