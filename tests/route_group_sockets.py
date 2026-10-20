"""Independent fixed-search and commit audit for bounded automatic socket repair."""
import argparse
import copy
import itertools
import json
import math

import route_group as group
import route_group_reference as reference
from scene_avoidance import endpoint, validate


def port(point, normal=None, junction=None, owner=None):
    return dict(point=point, normal=normal, junction=junction, owner=owner)


def cases():
    base = dict(bounds=dict(left=0, top=0, right=48, bottom=32), escape=3, clearance=0,
                **{'bend-cost': 3})
    a, b = port([4, 10], [1, 0]), port([44, 10], [-1, 0])
    c, d = port([4, 22], [1, 0]), port([44, 22], [-1, 0])
    edge = dict(id=None, **{'from': a, 'to': b},
                allocation=dict(source=[a, c], target=[b, d], boundary=None, reverse=False))
    def item(name, edges, **data):
        return name, base | dict(edges=[copy.deepcopy(e) for e in edges]) | data
    result = [item('both', [edge, edge])]
    for role in ('source', 'target'):
        e = copy.deepcopy(edge)
        e['allocation'][role] = [e['from' if role == 'source' else 'to']]
        result.append(item('fixed-' + role, [e, e]))
    named = copy.deepcopy(edge)
    for role in ('from', 'to'):
        named[role]['junction'] = [role, named[role]['point']]
    for role in ('source', 'target'):
        for p in named['allocation'][role]:
            p['junction'] = ['from' if role == 'source' else 'to', p['point']]
    result.append(item('shared-stubs', [named, named]))
    # Owned alternatives must retain the exact socket/normal exemption. A
    # foreign box near an alternative is never ignored along the owner's stub.
    owned = copy.deepcopy(edge)
    for role in ('from', 'to'):
        owned[role]['owner'] = role
    for role in ('source', 'target'):
        for p in owned['allocation'][role]:
            p['owner'] = 'from' if role == 'source' else 'to'
    boxes = [dict(id='from', left=1, right=4, top=6, bottom=26),
             dict(id='to', left=44, right=47, top=6, bottom=26)]
    result.append(item('owners', [owned, owned], obstacles=boxes))
    result.append(item('foreign', [owned, owned], obstacles=boxes + [dict(id='foreign', left=5, right=8, top=19, bottom=25)]))
    result.append(item('hard-visits', [edge | dict(via=[[20, 10], [28, 10]]), edge]))
    result.append(item('tight-detour', [edge | dict(via=[[22, 14]]), edge]))
    for count in (3, 4):
        result.append(item(f'many-{count}', [edge] * count))
    for index, e in enumerate((edge, named, owned)):
        e = copy.deepcopy(e)
        e['from'], e['to'] = e['to'], e['from']
        e['allocation']['source'], e['allocation']['target'] = e['allocation']['target'], e['allocation']['source']
        result.append(item(f'reversed-{index}', [e, e], **({'obstacles': boxes} if index == 2 else {})))
    fixed = copy.deepcopy(edge)
    fixed['allocation']['source'] = [a]
    fixed['allocation']['target'] = [b]
    result.append(item('fixed', [fixed, fixed]))
    result.append(item('remote-ineligible', [edge | dict(reselect=False)] * 2))
    page_data = dict(pages=[dict(page=1, bounds=base['bounds']), dict(page=2, bounds=base['bounds'])])
    result.append(item('pages', [edge | dict(page=1)] * 2 + [edge | dict(page=2)] * 2, **page_data))
    # Different lengths/costs/visits, fixed counterpart sockets and nearby ports.
    for gap, target_y, bend in itertools.product((1, 3, 7), (10, 16), (0, 4)):
        e = copy.deepcopy(edge)
        e['allocation']['source'][1]['point'] = [4, 10 + gap]
        e['allocation']['target'][1]['point'] = [44, target_y]
        result.append(item(f'grid-{gap}-{target_y}-{bend}', [e, edge], **{'bend-cost': bend}))
    return result


def public_port(value, data):
    p = copy.deepcopy(value)
    if isinstance(p.get('owner'), int):
        p['owner'] = data['obstacles'][p['owner']]['id']
    return p


def effective(data, records):
    data = copy.deepcopy(data)
    for r in records:
        if 'selection' in r:
            for role, choice in (('from', 'source'), ('to', 'target')):
                data['edges'][r['edge-index']][role] = public_port(r['selection'][choice], data)
    return data


def audited(data, options, output, oracle=True, relays=False):
    prior = {}
    charged = 0
    counts = {}
    for entry in output['searches']:
        r = entry['record']
        i = r['edge-index']
        assert r['search-id'] == len(prior)
        against = [prior[sid] for sid in entry['against']]
        search_data = effective(data, against)
        if 'sockets' in entry:
            for role, choice in (('from', 'source'), ('to', 'target')):
                search_data['edges'][i][role] = public_port(entry['sockets'][choice], data)
        elif 'selection' in r:
            # Ordinary path repair after a committed socket change.
            search_data = effective(search_data, [r])
        scene = reference.scene_for(search_data, search_data['edges'][i])
        validate(scene, r)
        if oracle and r['status'] != 'budget':
            def unit_charge(p, axis):
                total = 0
                for old in against:
                    _, shared = group.zones(search_data, search_data['edges'][i], search_data['edges'][old['edge-index']])
                    for ax, fixed, low, high in reference.reservations(old['points']):
                        if ax == axis and abs(fixed - p[1-axis]) < options.get('spacing', 3) and low < p[axis] < high:
                            if not (fixed == p[1-axis] and any(s[0] == axis and s[1] == fixed and s[2] < p[axis] < s[3] for s in shared)):
                                total += 1
                return total
            optimum = reference.dense(scene, [], options | dict(policy=entry['policy']), unit_charge=unit_charge)
            assert (r['status'] == 'ok') == (optimum is not None), (r, optimum)
            if optimum is not None:
                assert math.isclose(r['weighted-score'], optimum, abs_tol=1e-7), (r, optimum)
        remaining = min(data.get('max-expansions', 50000), options.get('max-expansions', 50000) - charged)
        charged += min(remaining, r['stats'].get('expanded', 0))
        assert remaining > 0
        prior[r['search-id']] = r
    assert len(prior) <= options.get('max-searches', 64)
    assert charged == output['expanded'] <= options.get('max-expansions', 50000)
    baseline = output['baseline']
    incumbent = baseline
    base_data = effective(data, baseline)
    group.equal(group.metrics(base_data, baseline, options), output['baseline-metrics'])
    for proposal in output['history']:
        assert len({data['edges'][i].get('page') for i in proposal['indices']}) == 1
        before = group.metrics(effective(data, incumbent), incumbent, options)
        group.equal(before, proposal['before'])
        if proposal['candidate'] is None:
            assert proposal['decision'] == 'search-failure'
            continue
        candidate = copy.deepcopy(incumbent)
        for r in proposal['changes']:
            assert r == (prior[r['search-id']] if r['search-id'] is not None else baseline[r['edge-index']])
            candidate[r['edge-index']] = r
        after = group.metrics(effective(data, candidate), candidate, options)
        group.equal(after, proposal['candidate'])
        expected = group.decision(baseline, incumbent, candidate, before, after, options)
        if proposal['kind'] == 'socket' and expected == 'accept' and after['exposure'] >= before['exposure']:
            expected = 'no-separation'
        assert proposal['decision'] == expected, (proposal, expected)
        counts[expected] = counts.get(expected, 0) + 1
        if expected == 'accept':
            incumbent = candidate
    assert incumbent == output['records']
    group.equal(group.metrics(effective(data, incumbent), incumbent, options), output['metrics'])
    assert output['metrics']['energy'] <= output['baseline-metrics']['energy'] + 1e-7
    # A retained selection must be one of the declaration's literal candidates.
    for r in output['records']:
        if 'selection' not in r:
            continue
        for role in ('source', 'target'):
            p = public_port(r['selection'][role], data)
            edge = data['edges'][r['edge-index']]
            allocation = edge['allocation']
            boundary = allocation['boundary']
            relay_role = 'source' if allocation['reverse'] else 'target'
            if not relays or boundary is None or role != relay_role:
                assert p in allocation[role]
                continue
            original = edge['from' if role == 'source' else 'to']
            assert p | {'point': original['point']} == original
            bounds = reference.scene_for(data, edge)['bounds']
            low, high = boundary['left'], boundary['right']
            if bounds is not None:
                low, high = max(low, bounds['left']), min(high, bounds['right'])
            assert low <= p['point'][0] <= high
            assert p['point'][1] == original['point'][1]
    return counts


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--typst', default='typst')
    args = parser.parse_args()
    group.COMPILER = args.typst
    inputs = cases()
    options = dict(reselect=True, rounds=2, **{'max-searches': 64})
    batch = [(name, data, options) for name, data in inputs]
    outputs, elapsed = group.evaluate(batch, 'socket-repair')
    decisions = {}
    for (name, data, opts), output in zip(batch, outputs, strict=True):
        for key, count in audited(data, opts, output).items():
            decisions[key] = decisions.get(key, 0) + count
    assert outputs[0]['metrics']['exposure'] == 0
    assert outputs[0]['metrics']['length'] == outputs[0]['baseline-metrics']['length']
    print(f'{len(batch)} socket groups / {sum(len(o["searches"]) for o in outputs)} fixed searches pass dense Dijkstra and full commit audits; batch {elapsed:.3f}s.', flush=True)
    controls = []
    for n in (4, 5, 6, 8, 12, 24):
        controls.append((f'budget-{n}', inputs[0][1], options | {'max-searches': n}))
    for n in (1, 2, 4, 12, 30):
        controls.append((f'expansions-{n}', inputs[0][1], options | {'max-expansions': n}))
    for ratio in (1, 1.1):
        controls.append((f'detour-{ratio}', inputs[0][1], options | {'length-ratio': ratio}))
    bounded, _ = group.evaluate(controls, 'socket-budget-controls')
    for (_, data, opts), output in zip(controls, bounded, strict=True):
        audited(data, opts, output)
    permutations = [(n, data | dict(obstacles=list(reversed(data.get('obstacles', [])))), opts) for n, data, opts in batch]
    permuted, _ = group.evaluate(permutations, 'socket-permutations')
    def semantic(value, data):
        if isinstance(value, list):
            return [semantic(v, data) for v in value]
        if isinstance(value, dict):
            return {k: data['obstacles'][v]['id'] if k == 'owner' and isinstance(v, int) else semantic(v, data) for k, v in value.items()}
        return value
    for (_, original, _), (_, perm, _), before, after in zip(batch, permutations, outputs, permuted, strict=True):
        assert semantic(before, original) == semantic(after, perm)
    def transform(data, factor, offset):
        data = copy.deepcopy(data)
        point = lambda p: [p[i] * factor + offset[i] for i in range(2)]
        seen = set()
        rectangles = [data['bounds'], *data.get('obstacles', []), *(p['bounds'] for p in data.get('pages', []))]
        for rect in rectangles:
            if id(rect) in seen:
                continue
            seen.add(id(rect))
            for k in ('left', 'right'):
                rect[k] = rect[k] * factor + offset[0]
            for k in ('top', 'bottom'):
                rect[k] = rect[k] * factor + offset[1]
        for e in data['edges']:
            values = [e['from'], e['to'], *e['allocation']['source'], *e['allocation']['target']]
            for p in values:
                if id(p) in seen:
                    continue
                seen.add(id(p))
                p['point'] = point(p['point'])
                if isinstance(p.get('junction'), list):
                    p['junction'][1] = point(p['junction'][1])
            e['via'] = [point(p) for p in e.get('via', [])]
        for key in ('clearance', 'escape', 'bend-cost'):
            data[key] *= factor
        return data
    transformed = []
    controls_affine = []
    for item, output in zip(batch[:8], outputs[:8], strict=True):
        name, data, opts = item
        for factor in (1 / 1024, 8):
            transformed.append((name + str(factor), transform(data, factor, (3.25, -4.5)), opts | dict(spacing=3 * factor)))
            controls_affine.append((output, factor))
    affine, _ = group.evaluate(transformed, 'socket-affine')
    for (_, data, opts), after, (before, factor) in zip(transformed, affine, controls_affine, strict=True):
        audited(data, opts, after, oracle=False)
        assert before['expanded'] == after['expanded'] and before['limits-hit'] == after['limits-hit']
        assert [h['decision'] for h in before['history']] == [h['decision'] for h in after['history']]
        for a, b in zip(before['records'], after['records'], strict=True):
            assert a['status'] == b['status'] and a['stats'] == b['stats'] and a['search-id'] == b['search-id']
            assert [[p[i] * factor + (3.25, -4.5)[i] for i in range(2)] for p in a['points']] == b['points']
    print(f'{len(controls)} budget/detour controls and {len(permutations)} obstacle permutations pass; decisions {decisions}.', flush=True)
    print(f'{len(transformed)} scaled/translated groups retain geometry, decisions, search IDs and work.', flush=True)
    out = group.ROOT / 'target/group-sockets'
    out.mkdir(parents=True, exist_ok=True)
    (out / 'oracle.json').write_text(json.dumps(dict(groups=len(batch), searches=sum(len(o['searches']) for o in outputs),
        controls=len(controls), permutations=len(permutations), affine=len(transformed), decisions=decisions, failures=[]), indent=2) + '\n')


if __name__ == '__main__':
    main()
