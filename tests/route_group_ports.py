"""Independent feasibility/optimal fallback checks for collected group sockets."""
import argparse
import copy
import json
import math
from pathlib import Path

import route_group
from scene_avoidance import dense_cost, endpoint, validate
import scene_ports


def group(scene, reverse=False):
    source = copy.deepcopy(scene['from'])
    target = copy.deepcopy(scene['to'])
    choices = dict(source=copy.deepcopy(scene.get('sources', [source])),
                   target=copy.deepcopy(scene.get('targets', [target])),
                   boundary=copy.deepcopy(scene.get('boundary')), reverse=reverse)
    visits = scene.get('via', [])
    if reverse:
        source, target = target, source
        choices['source'], choices['target'] = choices['target'], choices['source']
        visits = list(reversed(visits))
    edge = dict(id='edge', **{'from': source, 'to': target}, via=visits, allocation=choices)
    return {'bend-cost': 12, 'clearance': 4, 'escape': 4} | {
        k: copy.deepcopy(v) for k, v in scene.items()
        if k not in ('from', 'to', 'via', 'sources', 'targets', 'boundary')} | dict(edges=[edge])


def accepted_scene(scene, record, reverse):
    selected = copy.deepcopy(scene)
    # Raw selection owners are numeric scene indices. Keep the original public
    # candidate records, whose owner IDs are required by the independent check.
    r = copy.deepcopy(record)
    if reverse:
        r['points'].reverse()
        if 'selection' in r:
            r['selection']['source'], r['selection']['target'] = r['selection']['target'], r['selection']['source']
    if 'selection' in r:
        for role, choices_key, chosen in (('from', 'sources', 'source'), ('to', 'targets', 'target')):
            if role == 'to' and 'boundary' in scene:
                continue
            actual = r['selection'][chosen]
            candidates = scene.get(choices_key, [scene[role]])
            match = next((e for e in candidates if endpoint(e)['point'] == actual['point']
                          and endpoint(e).get('normal') == actual['normal']), None)
            assert match is not None, (actual, candidates)
            selected[role] = match
    return selected, r


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--typst', default='typst')
    args = parser.parse_args()
    route_group.COMPILER = args.typst
    inputs = [(name, scene, False) for name, scene in scene_ports.cases()]
    inputs += [(name + '-incoming', scene, True) for name, scene in scene_ports.cases() if 'boundary' in scene]
    cases = [(name, group(scene, reverse), dict(weight=0, rounds=0, **{'max-searches': 2}))
             for name, scene, reverse in inputs]
    outputs, elapsed = route_group.evaluate(cases, 'collected-port-fallback')
    fallback_count = 0
    for (name, scene, reverse), output in zip(inputs, outputs, strict=True):
        preferred = dense_cost({k: v for k, v in scene.items() if k != 'boundary'})
        expected = preferred if preferred is not None else scene_ports.reference(scene)
        record = output['records'][0]
        assert (record['status'] == 'ok') == (expected is not None), (name, record, expected)
        assert len(output['searches']) <= 2
        assert output['expanded'] <= 50000
        assert output['expanded'] == sum(min(50000, s['record']['stats'].get('expanded', 0)) for s in output['searches'])
        assert output['baseline'] == output['records'], name
        if preferred is not None:
            assert 'selection' not in record, (name, 'moved a valid preference')
        if record['status'] != 'ok':
            continue
        selected, canonical = accepted_scene(scene, record, reverse)
        # A valid fixed preference on a boundary is not an allocation search and
        # therefore has no displacement/allocation fields.
        if 'preference' not in canonical:
            selected.pop('boundary', None)
        validate(selected, canonical)
        actual = (canonical['allocation-cost'], canonical['preference'], canonical['points'][-1][0]) if isinstance(expected, tuple) else canonical['score']
        if isinstance(expected, tuple):
            assert all(math.isclose(a, b, abs_tol=1e-7) for a, b in zip(actual, expected, strict=True)), (name, actual, expected)
        else:
            assert math.isclose(actual, expected, abs_tol=1e-7), (name, actual, expected)
        fallback_count += 'selection' in record
    print(f'{len(inputs)} group endpoint cases match independent per-pair Dijkstra; '
          f'{fallback_count} successful fallback selections; Typst batch {elapsed:.3f}s.', flush=True)
    permutations = [(name, dict(data, obstacles=list(reversed(data.get('obstacles', [])))), options)
                    for name, data, options in cases]
    other, _ = route_group.evaluate(permutations, 'collected-port-permutations')

    def semantic_owners(value, data):
        # Private sockets retain their native scene index. Compare that owner
        # semantically when the input obstacle order changes.
        if isinstance(value, list):
            return [semantic_owners(v, data) for v in value]
        if isinstance(value, dict):
            return {k: data['obstacles'][v]['id'] if k == 'owner' and isinstance(v, int)
                    else semantic_owners(v, data) for k, v in value.items()}
        return value
    for (_, original, _), (_, permuted, _), before, after in zip(cases, permutations, outputs, other, strict=True):
        assert semantic_owners(before, original) == semantic_owners(after, permuted)
    print('All obstacle permutations retain complete group histories and work accounting.', flush=True)
    independent_cases = [(name, data, options | dict(independent=True)) for name, data, options in cases]
    independent, _ = route_group.evaluate(independent_cases, 'independent-port-fallback')
    for grouped, single in zip(outputs, independent, strict=True):
        assert single['records'] == grouped['baseline']
        assert single['history'] == [] and single['rounds-run'] == 0
        assert single['metrics'] is None and single['baseline-metrics'] is None
        assert single['expanded'] <= grouped['expanded']
        assert all(s['against'] == [] and s['policy'] == 'independent' for s in single['searches'])
    print('All 140 obstacle-only plans match checked baselines without pair metrics, reservations or repair.', flush=True)
    Path('target/route-group/collected-port-verification.json').write_text(
        json.dumps(dict(cases=len(inputs), successful_fallbacks=fallback_count,
                        obstacle_permutations=len(inputs), independent_plans=len(independent), failures=[]), indent=2) + '\n')


if __name__ == '__main__':
    main()
