"""Independent per-pair dense oracle for the private multi-port scene search."""
import copy
import math
import random
from scene_avoidance import DIRECTIONS, dense_cost, endpoint, evaluate, transform, validate


def cases():
    rng = random.Random(20261020)
    result = []
    for i in range(110):
        scene = dict(bounds=dict(left=0, top=0, right=24, bottom=20), clearance=i % 2,
                     escape=1, **{'bend-cost': (0, 2, 5, 12)[i % 4]})
        for role, key in (('from', 'sources'), ('to', 'targets')):
            ports = [dict(point=[rng.randrange(25), rng.randrange(21)]) for _ in range(2 + i % 3)]
            for port in ports:
                if rng.randrange(4):
                    port['normal'] = list(rng.choice(DIRECTIONS))
            scene[role], scene[key] = ports[0], ports
        scene['obstacles'] = []
        for j in range(i % 6):
            x, y = rng.randrange(2, 19), rng.randrange(2, 15)
            scene['obstacles'].append(dict(id=str(j), left=x, top=y, right=x+rng.randrange(1, 5), bottom=y+rng.randrange(1, 5)))
        if i % 4 == 0:
            scene['via'] = [[rng.randrange(25), rng.randrange(21)] for _ in range(1 + i % 3)]
        if i % 5 == 0:
            # Real-port alternatives combined with an allocated continuation.
            scene['boundary'] = dict(left=0, right=24, preferred=12)
            scene['to'] = dict(point=[12, 20], normal=[0, -1])
            del scene['targets']
        result.append((f'ports-{i}', scene))
    # Different normals/endpoints can share a terminal stub. The goal index must
    # keep every choice, and only the feasible final direction may be selected.
    base = dict(bounds=dict(left=0, top=0, right=24, bottom=20), clearance=1, escape=1)
    result += [
        ('shared-stubs', dict(base, **{'from': [4, 8], 'to': dict(point=[12, 9], normal=[0, -1]),
          'sources': [[4, 8], dict(point=[3, 8], normal=[1, 0])],
          'targets': [dict(point=[12, 9], normal=[0, -1]), dict(point=[13, 8], normal=[-1, 0])],
          'via': [[12, 9], [13, 8]]})),
        ('owned-ports', dict(base, obstacles=[dict(id='a', left=2, top=4, right=6, bottom=12),
             dict(id='foreign', left=5, top=6, right=9, bottom=10)],
          **{'from': dict(point=[6, 8], normal=[1, 0], owner='a'), 'to': [20, 8],
             'sources': [dict(point=[6, 8], normal=[1, 0], owner='a'),
                         dict(point=[4, 12], normal=[0, 1], owner='a')]})),
        ('closed-corridor', dict(base, obstacles=[dict(id='wall', left=10, right=12, top=-2, bottom=22)],
          **{'from': [4, 8], 'to': [20, 8], 'sources': [[4, 8], [5, 10]], 'targets': [[20, 8], [19, 10]]})),
        ('blocked-source-set', dict(base, obstacles=[dict(id='box', left=1, right=8, top=2, bottom=15)],
          **{'from': [4, 8], 'to': [20, 8], 'sources': [[4, 8], [5, 10]]})),
        ('blocked-target-set', dict(base, obstacles=[dict(id='box', left=17, right=23, top=2, bottom=15)],
          **{'from': [4, 8], 'to': [20, 8], 'targets': [[20, 8], [19, 10]]})),
        ('final-stub-visits', dict(base, escape=4, **{'from': [4, 8], 'to': dict(point=[20, 8], normal=[-1, 0]),
          'sources': [[4, 8], [3, 8]], 'targets': [dict(point=[20, 8], normal=[-1, 0]), [21, 10]], 'via': [[18, 8]]})),
        ('initial-stub-visits', dict(base, escape=4, **{'from': dict(point=[4, 8], normal=[1, 0]), 'to': [20, 8],
          'sources': [dict(point=[4, 8], normal=[1, 0]), [3, 8]], 'targets': [[20, 8], [21, 10]], 'via': [[6, 8]]})),
        ('coincident', dict(base, **{'from': [4, 8], 'to': [4, 8],
                                    'sources': [[4, 8], [4, 9]], 'targets': [[4, 8], [3, 8]]})),
    ]
    return result


def selected_scene(scene, record):
    scene = copy.deepcopy(scene)
    for role, key, selected in (('from', 'sources', 'source'), ('to', 'targets', 'target')):
        actual = record['selection'][selected]
        def matches(value):
            value = endpoint(value)
            return value['point'] == actual['point'] and value.get('normal', [0, 0]) == actual['normal']
        if role == 'to' and 'boundary' in scene:
            continue
        candidates = scene.get(key, [scene[role]])
        assert any(matches(e) for e in candidates), (scene, actual)
        scene[role] = next(e for e in candidates if matches(e))
    return scene


def reference(scene):
    # Separate dense searches deliberately avoid sharing the production graph,
    # endpoint filtering, seeds, goal indexes or A* lower bounds.
    costs = []
    for source in scene.get('sources', [scene['from']]):
        for target in scene.get('targets', [scene['to']]):
            one = dict(scene, **{'from': source, 'to': target})
            cost = dense_cost(one, choice='boundary' in one)
            if cost is not None:
                costs.append(cost)
    return min(costs) if costs else None


def main():
    inputs = cases()
    records, elapsed = evaluate(inputs, 'port-checks')
    counts = {}
    for (name, scene), record in zip(inputs, records, strict=True):
        expected = reference(scene)
        assert (record['status'] == 'ok') == (expected is not None), (name, record, expected)
        counts[record['status']] = counts.get(record['status'], 0) + 1
        if expected is not None:
            validate(selected_scene(scene, record), record)
            actual = (record['allocation-cost'], record['preference'], record['points'][-1][0]) if 'boundary' in scene else record['score']
            if isinstance(actual, tuple):
                assert all(math.isclose(a, b, abs_tol=1e-7) for a, b in zip(actual, expected, strict=True)), (name, actual, expected)
            else:
                assert math.isclose(actual, expected, abs_tol=1e-7), (name, actual, expected)
    print(f'{len(inputs)} multi-port scenes match independent per-pair dense Dijkstra; {counts}; Typst batch {elapsed:.3f}s.', flush=True)
    permutations = [(name, dict(scene, obstacles=list(reversed(scene.get('obstacles', []))))) for name, scene in inputs]
    other, _ = evaluate(permutations, 'port-permutations')
    assert records == other
    print(f'{len(inputs)} multi-port obstacle permutations preserve exact geometry and statistics.', flush=True)
    transformed = []
    for name, scene in inputs[-3:]:
        for factor in (0.125, 10):
            new = transform(scene, factor, (17.25, -11.5))
            for key in ('sources', 'targets'):
                if key in scene:
                    new[key] = [transform(dict(scene, **{'from': port}), factor, (17.25, -11.5))['from'] for port in scene[key]]
            transformed.append((name, new))
    other, _ = evaluate(transformed, 'port-transforms')
    for i, ((_, scene), record) in enumerate(zip(transformed, other, strict=True)):
        original = records[-3 + i // 2]
        assert original['status'] == record['status']
        if record['status'] == 'ok':
            validate(selected_scene(scene, record), record)
            assert math.isclose(record['score'], original['score'] * (0.125, 10)[i % 2], abs_tol=1e-7)
    print(f'{len(transformed)} multi-port transforms preserve outcomes and costs.', flush=True)


if __name__ == '__main__':
    main()
