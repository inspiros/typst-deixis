"""Independent dense reference and deterministic group input cases."""
from pathlib import Path
import heapq
import math
import random
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT/'tests'))
from scene_avoidance import DIRECTIONS, endpoint, inflated, interior, on, stub, validate, visit


def segments(points):
    result = []
    for a, b in zip(points, points[1:]):
        if a == b:
            continue
        axis = 0 if a[1] == b[1] else 1
        assert a[1-axis] == b[1-axis]
        result.append((axis, a[1-axis], min(a[axis], b[axis]), max(a[axis], b[axis])))
    return result


def reservations(points):
    # Union intervals per fixed coordinate, including backtracking/subdivision.
    groups = {}
    for axis, fixed, low, high in segments(points):
        groups.setdefault((axis, fixed), []).append([low, high])
    result = []
    for (axis, fixed), intervals in sorted(groups.items()):
        merged = []
        for low, high in sorted(intervals):
            if merged and low <= merged[-1][1]:
                merged[-1][1] = max(merged[-1][1], high)
            else:
                merged.append([low, high])
        result += [(axis, fixed, low, high) for low, high in merged]
    return result


def scene_for(input, edge):
    page = edge.get('page')
    result = {k: v for k, v in input.items() if k not in ('pages', 'edges', 'obstacles')}
    for key, value in (('clearance', 0), ('escape', 1), ('bend-cost', 5)):
        result.setdefault(key, value)
    result['obstacles'] = [r for r in input.get('obstacles', []) if r.get('page') == page]
    if page is not None:
        result['bounds'] = next(p['bounds'] for p in input['pages'] if p['page'] == page)
    return result | {k: v for k, v in edge.items() if k in ('from', 'to', 'via')}


def dense(scene, lanes, options, unit_charge=None):
    """Unit-grid Dijkstra; cost samples unit midpoints rather than lane intervals."""
    bounds = scene['bounds']
    rectangles = inflated(scene)
    source, target = endpoint(scene['from']), endpoint(scene['to'])
    start, end = stub(source, scene), stub(target, scene)
    via = scene.get('via', [])
    policy = options.get('policy', 'soft')
    weight = options.get('weight', 4) if policy == 'soft' else 0
    spacing = options.get('spacing', 3)
    penalty = scene.get('bend-cost', 5)

    def allowed(p):
        return (bounds['left'] <= p[0] <= bounds['right'] and bounds['top'] <= p[1] <= bounds['bottom']
                and not any(interior(p, r) for r in rectangles))

    def units(a, b):
        assert a[0] == b[0] or a[1] == b[1]
        n = int(sum(abs(a[i]-b[i]) for i in range(2)))
        assert math.isclose(n, sum(abs(a[i]-b[i]) for i in range(2)))
        return [tuple(a[i]+(b[i]-a[i])*(k+0.5)/n for i in range(2)) for k in range(n)]

    def unit_occupancy(a, b):
        if a == b or policy == 'independent':
            return 0
        axis = 0 if a[1] == b[1] else 1
        if unit_charge is not None:
            return sum(unit_charge(p, axis) for p in units(a, b))
        # Integer-valued input ensures each midpoint belongs to a whole unit.
        return sum(1 for p in units(a, b) for axis2, fixed, low, high in lanes
                   if axis == axis2 and abs(p[1-axis]-fixed) < spacing and low < p[axis] < high)

    def stub_ok(e, q):
        if not allowed(q):
            return False
        p = e['point']
        if not (bounds['left'] <= p[0] <= bounds['right'] and bounds['top'] <= p[1] <= bounds['bottom']):
            return False
        for r in rectangles:
            if r.get('id') != e.get('owner') and any(interior(m, r) for m in [tuple(p), *units(p, q), q]):
                return False
        return policy != 'reserved' or unit_occupancy(p, q) == 0

    if not stub_ok(source, start) or not stub_ok(target, end) or any(not allowed(p) for p in via):
        return None
    initial_dir = DIRECTIONS.index(tuple(source['normal'])) if source.get('normal') else 4
    final_dir = (DIRECTIONS.index(tuple(target['normal']))+2) % 4 if target.get('normal') else 4
    prefix = sum(abs(start[i]-source['point'][i]) for i in range(2)) + weight*unit_occupancy(source['point'], start)
    initial = (*start, initial_dir, visit(0, source['point'], start, via))
    costs = {initial: prefix}
    heap = [(prefix, initial)]
    best = math.inf
    while heap:
        cost, state = heapq.heappop(heap)
        if cost >= best:
            break
        if cost != costs[state]:
            continue
        x, y, direction, stage = state
        if (x, y) == end and visit(stage, end, target['point'], via) == len(via):
            if final_dir == 4 or direction == 4 or (direction+2) % 4 != final_dir:
                suffix = sum(abs(end[i]-target['point'][i]) for i in range(2))
                best = min(best, cost+suffix+weight*unit_occupancy(end, target['point'])
                           +(penalty if final_dir != 4 and direction != 4 and direction != final_dir else 0))
        for heading, delta in enumerate(DIRECTIONS):
            if direction != 4 and (direction+2) % 4 == heading:
                continue
            q = (x+delta[0], y+delta[1])
            mid = ((x+q[0])/2, (y+q[1])/2)
            if not allowed(q) or any(interior(mid, r) for r in rectangles):
                continue
            occupied = unit_occupancy((x, y), q)
            if policy == 'reserved' and occupied:
                continue
            next_state = (*q, heading, visit(stage, (x, y), q, via))
            next_cost = cost+1+weight*occupied+(penalty if direction != 4 and direction != heading else 0)
            if next_cost < costs.get(next_state, math.inf):
                costs[next_state] = next_cost
                heapq.heappush(heap, (next_cost, next_state))
    return None if math.isinf(best) else best


def named():
    base = dict(bounds=dict(left=0, top=0, right=40, bottom=32), escape=1, **{'bend-cost': 5})
    edge = lambda id, a, b, **kw: dict(id=id, **{'from': a, 'to': b}, **kw)
    groups = [
        ('parallel', base | dict(edges=[edge('a',[2,10],[38,10]), edge('b',[2,14],[38,14]), edge('c',[2,10],[38,10])])),
        ('crossing', base | dict(edges=[edge('a',[2,16],[38,16]), edge('b',[20,2],[20,30])])),
        ('shared-stub', base | dict(edges=[edge('a',dict(point=[2,10],normal=[1,0]),[38,10]),
                                                    edge('b',dict(point=[2,10],normal=[1,0]),[38,20])])),
        ('order-trap', base | dict(edges=[edge('a',[2,10],[38,10]), edge('b',dict(point=[8,10],normal=[1,0]),[30,20])])),
        ('waypoint', base | dict(edges=[edge('a',[2,16],[38,16]), edge('b',[2,24],[38,24],via=[[12,16],[28,16]])])),
        ('thin-channel', base | dict(obstacles=[dict(id='top',left=10,right=30,top=-1,bottom=16),
             dict(id='bottom',left=10,right=30,top=16,bottom=33)],
             edges=[edge('a',[2,16],[38,16]), edge('b',[2,16],[38,16])])),
        ('failure-isolation', base | dict(obstacles=[dict(id='box',left=14,right=26,top=10,bottom=22)],
             edges=[edge('invalid',[20,16],[38,16]), edge('valid',[2,4],[38,4]), edge('next',[2,4],[38,4])])),
        ('return', base | dict(edges=[edge('a',[2,10],[38,10]), edge('b',[6,6],[6,6],via=[[32,10],[32,24]])])),
    ]
    groups.append(('order-trap-reversed', groups[3][1] | dict(edges=groups[3][1]['edges'][::-1])))
    page_bounds = [dict(page=1,bounds=base['bounds']),dict(page=2,bounds=dict(left=0,top=0,right=30,bottom=24))]
    fragments = [edge('a',[3,6],dict(point=[18,32],normal=[0,-1]),page=1,via=[[12,12]]),
                 edge('a',dict(point=[18,0],normal=[0,1]),[27,18],page=2),
                 edge('b',[3,14],dict(point=[18,32],normal=[0,-1]),page=1),
                 edge('b',dict(point=[18,0],normal=[0,1]),[27,10],page=2)]
    groups.append(('page-fragments', {k:v for k,v in base.items() if k!='bounds'} | dict(pages=page_bounds,edges=fragments)))
    # Same geometry on two pages must route as two independent first edges.
    groups.append(('page-isolation', base | dict(pages=page_bounds,edges=[edge('a',[2,10],[28,10],page=1),edge('b',[2,10],[28,10],page=2)])))
    reversed_fragments=[e|{'from':e['to'],'to':e['from'],'via':e.get('via',[])[::-1]} for e in fragments]
    groups.append(('reverse-fragments',groups[-2][1]|dict(edges=reversed_fragments)))
    cards=[dict(id='a',left=1,right=8,top=6,bottom=14),dict(id='b',left=32,right=39,top=12,bottom=22),
           dict(id='middle',left=16,right=24,top=8,bottom=24)]
    groups.append(('owned-cards',base|dict(obstacles=cards,clearance=1,edges=[
        edge('one',dict(point=[8,10],normal=[1,0],owner='a'),dict(point=[32,17],normal=[-1,0],owner='b')),
        edge('two',dict(point=[8,12],normal=[1,0],owner='a'),dict(point=[32,20],normal=[-1,0],owner='b'))])))
    for y,name in ((8,'moving-port-clear'),(9,'moving-port-close')):
        groups.append((name,base|dict(edges=[edge('a',[2,10],[38,10]),edge('b',dict(point=[8,y],normal=[1,0]),[30,20])])) )
    return groups


def random_groups(count=60):
    rng = random.Random(20261019)
    result = []
    for i in range(count):
        input = dict(bounds=dict(left=0,top=0,right=20,bottom=16), escape=1, clearance=i%2,
                     **{'bend-cost': (0,2,5)[i%3]}, obstacles=[], edges=[])
        for j in range(i%4):
            x,y = rng.randrange(4,14),rng.randrange(3,10)
            input['obstacles'].append(dict(id=str(j),left=x,top=y,right=x+rng.randrange(1,4),bottom=y+rng.randrange(1,4)))
        for j in range(2+i%2):
            edge = dict(id=str(j))
            for role in ('from','to'):
                p = dict(point=[rng.randrange(21),rng.randrange(17)])
                if rng.randrange(3)==0:
                    p['normal'] = list(rng.choice(DIRECTIONS))
                edge[role]=p
            if (i+j)%5==0:
                edge['via']=[[rng.randrange(21),rng.randrange(17)]]
            input['edges'].append(edge)
        result.append((f'random-{i}',input))
    return result


