"""Visibility projections checked against dense routing at every integer socket."""
import copy
import math
import random
from scene_avoidance import DIRECTIONS, evaluate, transform, validate
from scene_ports import reference


def expanded(scene):
    result=copy.deepcopy(scene)
    for role,key,field in (('source','sources','from'), ('target','targets','to')):
        if role not in scene['sliding']:continue
        s=scene['sliding'][role]
        result[key]=[]
        for coordinate in range(s['min'],s['max']+1):
            e=copy.deepcopy(scene[field])
            e['point'][s['axis']]=coordinate
            result[key].append(e)
    return result


def cases():
    rng=random.Random(20261021)
    result=[]
    for i in range(64):
        scene=dict(bounds=dict(left=0,top=0,right=24,bottom=20),clearance=i%2,escape=(1,2,4)[i%3],
                   **{'bend-cost':(0,2,5,12)[i%4]})
        scene['sliding']={}
        for key,role in (('from','source'),('to','target')):
            normal=list(rng.choice(DIRECTIONS))
            axis=1 if normal[0] else 0
            maximum=(24,20)[axis]
            lo=rng.randrange(3,maximum-7); hi=lo+rng.randrange(2,7)
            point=[rng.randrange(5,20),rng.randrange(5,16)]
            point[axis]=(lo+hi)//2
            scene[key]=dict(point=point,normal=normal)
            if (role=='source') or i%3==0:
                scene['sliding'][role]=dict(axis=axis,min=lo,max=hi)
        scene['obstacles']=[]
        for j in range(i%5):
            x,y=rng.randrange(3,20),rng.randrange(2,16)
            scene['obstacles'].append(dict(id=str(j),left=x,top=y,right=x+rng.randrange(1,4),bottom=y+rng.randrange(1,4)))
        if i%4==0:scene['via']=[[rng.randrange(25),rng.randrange(21)] for _ in range(1+i%2)]
        if i%5==0:
            scene['sliding'].pop('target',None)
            scene['boundary']=dict(left=0,right=24,preferred=12)
            scene['to']=dict(point=[12,20],normal=[0,-1])
        result.append((f'slide-{i}',scene))
    base=dict(bounds=dict(left=0,top=0,right=24,bottom=20),clearance=1,escape=1,**{'bend-cost':5})
    result += [
        ('owned-clearance',dict(base,clearance=3,escape=1,
          obstacles=[dict(id='own',left=1,top=4,right=5,bottom=15),dict(id='foreign',left=4,top=7,right=8,bottom=10)],
          **{'from':dict(point=[5,9],normal=[1,0],owner='own'),'to':dict(point=[20,9],normal=[-1,0]),
             'sliding':dict(source=dict(axis=1,min=4,max=15))})),
        ('closed-side',dict(base,obstacles=[dict(id='wall',left=3,top=1,right=7,bottom=19)],
          **{'from':dict(point=[5,10],normal=[1,0]),'to':dict(point=[20,10],normal=[-1,0]),
             'sliding':dict(source=dict(axis=1,min=4,max=15))})),
        ('clipped-side',dict(base,**{'from':dict(point=[5,10],normal=[1,0]),'to':dict(point=[20,10],normal=[-1,0]),
             'sliding':dict(source=dict(axis=1,min=-3,max=23))})),
        ('final-stub',dict(base,escape=4,**{'from':dict(point=[5,10],normal=[1,0]),'to':dict(point=[20,10],normal=[-1,0]),
             'sliding':dict(target=dict(axis=1,min=5,max=15)),'via':[[18,10]]})),
    ]
    return result


def main():
    inputs=cases()
    records,elapsed=evaluate(inputs,'sliding-checks')
    counts={}; gaps=[]; exact=0
    for (name,scene),record in zip(inputs,records,strict=True):
        choices=expanded(scene)
        expected=reference(choices)
        counts[record['status']]=counts.get(record['status'],0)+1
        # Exhaust every integer socket independently. Every feasible dense case
        # must be reachable. Fractional visibility bands can additionally offer
        # a safe socket when no integer socket exists.
        if expected is not None:
            assert record['status']=='ok',(name,record,expected)
        if record['status']!='ok':continue
        chosen=copy.deepcopy(scene)
        for role,key in (('source','from'),('target','to')):
            actual=record['selection'][role]
            if key=='to' and 'boundary' in scene:continue
            original=scene[key]
            assert actual['normal']==original['normal']
            if role in scene['sliding']:
                span=scene['sliding'][role]; axis=span['axis']
                assert span['min']<=actual['point'][axis]<=span['max']
                assert actual['point'][1-axis]==original['point'][1-axis]
            else:assert actual['point']==original['point']
            chosen[key]=dict(original,point=actual['point'])
        validate(chosen,record)
        if expected is not None:
            actual=record.get('allocation-cost',record['score'])
            score=expected[0] if isinstance(expected,tuple) else expected
            gaps.append(actual-score)
            exact+=math.isclose(actual,score,abs_tol=1e-7)
    print(f'{len(inputs)} sliding scenes retain dense per-socket reachability and valid geometry; {counts}; Typst batch {elapsed:.3f}s.',flush=True)
    print(f'{exact}/{len(gaps)} costs equal the integer-socket dense optimum; cost difference range {min(gaps):.3f}..{max(gaps):.3f}pt (finite visibility graph, no continuous optimum promise).',flush=True)
    other,_=evaluate([(n,dict(s,obstacles=list(reversed(s.get('obstacles',[]))))) for n,s in inputs],'sliding-permutations')
    assert records==other
    print(f'{len(inputs)} sliding obstacle permutations preserve exact output/statistics.',flush=True)
    changed=[]
    for name,scene in inputs[-4:]:
        for factor in (0.125,10):
            s=transform(scene,factor,(17.25,-11.5))
            s['sliding']={role:dict(span,min=span['min']*factor+(17.25,-11.5)[span['axis']],
                                       max=span['max']*factor+(17.25,-11.5)[span['axis']]) for role,span in scene['sliding'].items()}
            changed.append((name,s))
    other,_=evaluate(changed,'sliding-transforms')
    for i,((name,scene),record) in enumerate(zip(changed,other,strict=True)):
        original=records[-4+i//2]
        assert record['status']==original['status'],(name,record)
        if record['status']=='ok':
            assert math.isclose(record['score'],original['score']*(0.125,10)[i%2],abs_tol=1e-7)
    print(f'{len(changed)} sliding transforms preserve outcomes and costs.',flush=True)


if __name__=='__main__':main()
