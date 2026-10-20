"""Fixed measured frames: all input priorities and bounded repair outcomes."""
import itertools
import json
from pathlib import Path

root=Path(__file__).resolve().parents[1]
import route_group as ref
def main():
    input=json.loads((root/'tests/fixtures/route-group-margin.json').read_text())
    cases=[]
    for order in itertools.permutations(range(4)):
        ordered=input|dict(edges=[input['edges'][i] for i in order])
        cases.append(('order-'+''.join(map(str,order)),ordered,{}))
    cases += [('single-edge-only',input,dict(window=1)),('no-length-growth',input,{'length-ratio':1}),
              ('baseline-budget',input,{'max-searches':4}),('first-pass-only',input,dict(rounds=1))]
    records,elapsed=ref.evaluate(cases,'margin-orders')
    summary=[]
    for (name,scene,options),r in zip(cases,records,strict=True):
        ref.verify(scene,options,r,oracle=False)
        assert not r['metrics']['missing']
        summary.append(dict(name=name,metrics=r['metrics'],baseline=r['baseline-metrics'],
            searches=len(r['searches']),expanded=r['expanded'],limits=r['limits-hit'],
            accepted=[(p['kind'],p['indices']) for p in r['history'] if p['decision']=='accept']))
    (ref.OUT/'margin-summary.json').write_text(json.dumps(dict(elapsed_seconds=elapsed,results=summary),indent=2))
    print(f'{len(cases)} measured-margin groups independently validate geometry, all metrics and every commit; native batch {elapsed:.3f}s.',flush=True)
    print('All-order accidental overlap range:',min(r['metrics']['overlap'] for r in records[:24]),max(r['metrics']['overlap'] for r in records[:24]),flush=True)
    for r in summary[:1]+summary[24:]:print(r,flush=True)

if __name__ == '__main__':
    import argparse
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--typst',default='typst')
    args=parser.parse_args(); ref.COMPILER=args.typst
    main()
