"""Independent fixed-search and page-isolation audit for automatic relay repair."""
import argparse
import copy
import json
from pathlib import Path

import route_group as group
from route_group_sockets import audited, port


def cases():
    bounds = dict(left=0, top=0, right=48, bottom=36)
    base = dict(pages=[dict(page=1, bounds=bounds)], escape=2, clearance=0,
                **{'bend-cost': 3})

    def edge(x, y, page=1, incoming=False, fixed=False):
        a, b = port([x, y], [0, 1]), port([24, 36], [0, -1])
        e = dict(id=None, page=page, reselect=not fixed, **{'from': a, 'to': b},
                 allocation=dict(source=[a], target=[b], reverse=False,
                                 boundary=None if fixed else bounds | dict(preferred=24)))
        if incoming:
            e['from'], e['to'] = b, a
            e['allocation']['source'], e['allocation']['target'] = [b], [a]
            e['allocation']['reverse'] = True
        return e

    result = []
    for incoming in (False, True):
        for count in (2, 3):
            for spacing in (2, 4):
                edges = [edge(x, y, incoming=incoming) for x, y in ((6, 8), (40, 14), (12, 20))[:count]]
                result.append((f'halves-{incoming}-{count}-{spacing}', base | dict(edges=edges), dict(spacing=spacing)))
    original = result[0][1]
    for kind in ('fixed', 'mixed-fixed', 'hard-visits', 'obstacles', 'owned', 'narrow'):
        data = copy.deepcopy(original)
        if kind in ('fixed', 'mixed-fixed'):
            data['edges'] = [edge(6, 8, fixed=True), edge(40, 14, fixed=kind == 'fixed')]
        elif kind == 'hard-visits':
            data['edges'][0]['via'] = [[16, 22]]
        elif kind == 'obstacles':
            data['obstacles'] = [dict(id='foreign', page=1, left=26, right=30, top=27, bottom=36),
                                 dict(id='other', page=1, left=34, right=36, top=4, bottom=9)]
        elif kind == 'owned':
            data['obstacles'] = [dict(id='real', page=1, left=3, right=9, top=4, bottom=8)]
            data['edges'][0]['from']['owner'] = 'real'
            data['edges'][0]['allocation']['source'][0]['owner'] = 'real'
        elif kind == 'narrow':
            data['pages'][0]['bounds']['right'] = 42
        result.append((kind, data, {}))
    # Terminal intervals constrain relay sockets, not the route's search plane.
    # Both real endpoints intentionally lie outside this narrow channel.
    for incoming in (False, True):
        data = copy.deepcopy(original)
        for e in data['edges']:
            e['allocation']['boundary'] = dict(left=20, right=28, top=0, bottom=36, preferred=24)
            if incoming:
                e['from'], e['to'] = e['to'], e['from']
                e['allocation']['source'], e['allocation']['target'] = e['allocation']['target'], e['allocation']['source']
                e['allocation']['reverse'] = True
        result.append((f'interval-{incoming}', data, {}))
    # The other half of each logical connection has its own literal page plane.
    for interleave in (False, True):
        data = copy.deepcopy(original)
        remote = [edge(8, 10, page=3, incoming=True), edge(36, 18, page=3, incoming=True)]
        data['pages'].append(dict(page=3, bounds=dict(left=0, top=0, right=44, bottom=40)))
        for e in remote:
            e['from']['point'][1] = 0
            e['from']['normal'] = [0, 1]
            e['to']['normal'] = [0, -1]
            e['allocation']['boundary'] = dict(left=0, right=44, top=0, bottom=40, preferred=24)
        if interleave:
            data['edges'] = [data['edges'][0], remote[0], data['edges'][1], remote[1]]
        else:
            data['edges'] += remote
        result.append((f'pages-{interleave}', data, {}))
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--typst', default='typst')
    group.COMPILER = parser.parse_args().typst
    options = dict(reselect=True, rounds=2, **{'max-searches': 64})
    batch = [(n, d, options | o) for n, d, o in cases()]
    outputs, elapsed = group.evaluate(batch, 'relay-repair')
    decisions = {}
    for (name, data, opts), output in zip(batch, outputs, strict=True):
        counts = audited(data, opts, output, relays=True)
        # All accepted and attempted repair paths retain the hard interval,
        # including fixed searches after an earlier automatic socket change.
        for record in output['records'] + [entry['record'] for entry in output['searches']]:
            if record['status'] != 'ok':
                continue
            allocation = data['edges'][record['edge-index']]['allocation']
            boundary = allocation['boundary']
            if boundary is not None:
                point = record['points'][0 if allocation['reverse'] else -1]
                assert boundary['left'] <= point[0] <= boundary['right'], (name, point, boundary)
        for key, count in counts.items():
            decisions[key] = decisions.get(key, 0) + count
        for h in output['history']:
            if h['decision'] == 'accept':
                # Only one physical page changes, so page-local collision and
                # energy guards cannot be offset by a remote improvement.
                assert len({data['edges'][i]['page'] for i in h['indices']}) == 1
    assert outputs[0]['metrics']['overlap'] == 0
    assert outputs[0]['metrics']['exposure'] == 0
    controls = []
    data = batch[0][1]
    for n in (4, 5, 6, 8, 12, 24):
        controls.append((f'searches-{n}', data, options | {'max-searches': n}))
    for n in (1, 2, 8, 30):
        controls.append((f'expansions-{n}', data, options | {'max-expansions': n}))
    for ratio in (1, 1.1):
        controls.append((f'detour-{ratio}', data, options | {'length-ratio': ratio}))
    bounded, _ = group.evaluate(controls, 'relay-repair-controls')
    for (_, data, opts), output in zip(controls, bounded, strict=True):
        audited(data, opts, output, relays=True)
    # Frozen unrelated pages do not affect geometry when the work cap suffices.
    a, b = outputs[-2:]
    def by_page(output):
        return {page: [r['points'] for r in output['records'] if r['page'] == page] for page in (1, 3)}
    assert by_page(a) == by_page(b)
    permutations = [(n, d | dict(obstacles=list(reversed(d.get('obstacles', [])))), o) for n, d, o in batch]
    permuted, _ = group.evaluate(permutations, 'relay-repair-permutations')
    assert outputs == permuted

    def transform(data, factor, offset):
        data = copy.deepcopy(data)
        seen = set()
        point = lambda p: [p[i] * factor + offset[i] for i in range(2)]
        rectangles = [p['bounds'] for p in data['pages']] + data.get('obstacles', [])
        rectangles += [e['allocation']['boundary'] for e in data['edges'] if e['allocation']['boundary']]
        for r in rectangles:
            if id(r) in seen:
                continue
            seen.add(id(r))
            for k in ('left', 'right', 'preferred'):
                if k in r:
                    r[k] = r[k] * factor + offset[0]
            for k in ('top', 'bottom'):
                r[k] = r[k] * factor + offset[1]
        for e in data['edges']:
            for p in [e['from'], e['to'], *e['allocation']['source'], *e['allocation']['target']]:
                if id(p) not in seen:
                    seen.add(id(p))
                    p['point'] = point(p['point'])
            e['via'] = [point(p) for p in e.get('via', [])]
        for k in ('escape', 'clearance', 'bend-cost'):
            data[k] *= factor
        return data

    affine_inputs = []
    references = []
    for (name, data, opts), output in zip(batch[:8], outputs[:8], strict=True):
        for factor in (1 / 1024, 8):
            affine_inputs.append((name + str(factor), transform(data, factor, (3.25, -4.5)),
                                  opts | dict(spacing=opts.get('spacing', 3) * factor)))
            references.append((output, factor))
    affine, _ = group.evaluate(affine_inputs, 'relay-repair-affine')
    for (_, data, opts), output, (before, factor) in zip(affine_inputs, affine, references, strict=True):
        audited(data, opts, output, oracle=False, relays=True)
        assert before['expanded'] == output['expanded']
        assert [h['decision'] for h in before['history']] == [h['decision'] for h in output['history']]
        for a, b in zip(before['records'], output['records'], strict=True):
            assert a['status'] == b['status'] and a['search-id'] == b['search-id'] and a['stats'] == b['stats']
            assert [[p[i] * factor + (3.25, -4.5)[i] for i in range(2)] for p in a['points']] == b['points']
    summary = dict(groups=len(batch), searches=sum(len(p['searches']) for p in outputs),
                   controls=len(controls), permutations=len(permutations), affine=len(affine_inputs),
                   decisions=decisions, failures=[])
    out = Path('target/relay-repair')
    out.mkdir(parents=True, exist_ok=True)
    (out / 'oracle.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(f'{len(batch)} relay groups / {summary["searches"]} fixed searches pass dense Dijkstra and commit audits; {elapsed:.3f}s.', flush=True)
    print(f'{len(controls)} work/detour controls and page-order isolation pass.', flush=True)
    print(f'{len(permutations)} obstacle permutations and {len(affine_inputs)} affine copies retain geometry, history and work.', flush=True)


if __name__ == '__main__':
    main()
