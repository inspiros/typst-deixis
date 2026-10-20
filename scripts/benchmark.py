#!/usr/bin/env python3
"""Time fixed Deixis workloads in fresh serial compiler processes, locally only."""

import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import platform
import shutil
import statistics
import subprocess
import time

ROOT = Path(__file__).resolve().parents[1]
FIXTURE = ROOT / 'tests/benchmarks/notes.typ'


def run(command, timeout):
    start = time.perf_counter()
    result = subprocess.run(list(map(str, command)), capture_output=True, text=True, timeout=timeout)
    elapsed = time.perf_counter() - start
    if result.returncode or result.stderr:
        raise RuntimeError(result.stderr or result.stdout or f'Command failed: {command[0]}')
    return elapsed, result.stdout


def compare_pdfs(before, after, output, timeout):
    """Compare actual page pixels and internal PDF link geometry/destinations."""
    from pypdf import PdfReader
    output.mkdir()
    digests = []
    links = []
    for label, pdf in [('before', before), ('after', after)]:
        run(['pdftoppm', '-r', '96', '-png', pdf, output / label], timeout)
        images = sorted(output.glob(f'{label}-*.png'))
        digests.append([hashlib.sha256(p.read_bytes()).hexdigest() for p in images])
        reader = PdfReader(pdf)
        pages = {p.indirect_reference.idnum: i + 1 for i, p in enumerate(reader.pages)}
        destinations = []
        for page_number, page in enumerate(reader.pages, 1):
            for item in page.get('/Annots', []):
                annotation = item.get_object()
                dest = annotation.get('/Dest', annotation.get('/A', {}).get('/D'))
                if hasattr(dest, 'get_object'):
                    dest = dest.get_object()
                if isinstance(dest, list):
                    destinations.append((page_number, tuple(float(x) for x in annotation['/Rect']),
                                         pages[dest[0].idnum], tuple(None if x is None else float(x) for x in dest[2:])))
        links.append(sorted(destinations))
    if not digests[0] or digests[0] != digests[1] or links[0] != links[1]:
        raise AssertionError(f'Rendered pages or PDF links changed: {output}')
    return dict(pages=len(digests[0]), internal_links=len(links[0]), identical_pixels=True,
                identical_links=True, page_sha256=digests[1])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--typst', default='typst')
    parser.add_argument('--source-root', type=Path, default=ROOT, help='Checkout/runtime snapshot containing src/.')
    parser.add_argument('--output', type=Path, help='New output directory; defaults to target/benchmarks/<UTC timestamp>.')
    parser.add_argument('--counts', type=int, nargs='+', default=[100, 200, 400])
    parser.add_argument('--kinds', nargs='+', choices=['footnote', 'margin', 'references', 'native'],
                        default=['footnote', 'margin', 'references'])
    parser.add_argument('--repeat', type=int, default=3)
    parser.add_argument('--jobs', type=int, default=1, help='Compiler threads; fresh processes run serially.')
    parser.add_argument('--timeout', type=int, default=180)
    parser.add_argument('--baseline', type=Path, help='Compatible earlier results.json; report before/after ratios.')
    parser.add_argument('--trace', action='store_true', help='Extra unmeasured compile with a timings trace per case.')
    parser.add_argument('--compare-rendering', action='store_true',
                        help='After timing, compare every page and PDF link with --baseline (requires Poppler/pypdf).')
    args = parser.parse_args()
    if min([*args.counts, args.repeat, args.jobs, args.timeout]) < 1:
        parser.error('Counts, repeats, jobs and timeout must be positive.')
    if args.compare_rendering and not args.baseline:
        parser.error('--compare-rendering requires --baseline.')
    output = (args.output or ROOT / 'target/benchmarks' / datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')).resolve()
    if output.exists():
        parser.error('Use a new output directory to preserve previous measurements.')
    compiler = shutil.which(args.typst)
    if compiler is None:
        parser.error(f'Compiler not found: {args.typst}')
    compiler = str(Path(compiler).resolve())
    _, version = run([compiler, '--version'], args.timeout)
    fixture = FIXTURE.read_text()
    workload_hash = hashlib.sha256(fixture.encode()).hexdigest()
    contract = dict(schema=1, compiler=version.strip(), workload_sha256=workload_hash,
                    jobs=args.jobs, system=platform.platform(), machine=platform.machine())
    baseline = json.loads(args.baseline.read_text()) if args.baseline else None
    if baseline and baseline['contract'] != contract:
        parser.error('Baseline compiler/workload/jobs/machine differs; compare only matching contracts.')
    output.mkdir(parents=True)
    inputs = output / 'input'
    shutil.copytree(args.source_root.resolve() / 'src', inputs / 'src')
    (inputs / 'notes.typ').write_text(fixture.replace('../../src/', 'src/'))
    digest = hashlib.sha256()
    for path in sorted((inputs / 'src').rglob('*')):
        if path.is_file():
            digest.update(path.relative_to(inputs).as_posix().encode() + b'\0' + path.read_bytes())
    record = dict(contract=contract, runtime_sha256=digest.hexdigest(), source_root=str(args.source_root.resolve()),
                  baseline=str(args.baseline.resolve()) if args.baseline else None,
                  created_utc=datetime.now(timezone.utc).isoformat(), cases=[])
    result_path = output / 'results.json'

    def save():
        result_path.write_text(json.dumps(record, indent=2) + '\n')

    save()
    for kind in dict.fromkeys(args.kinds):
        for count in dict.fromkeys(args.counts):
            name = f'{kind}-{count}'
            base = [compiler, 'compile', '--root', inputs, '--jobs', str(args.jobs),
                    '--input', f'kind={kind}', '--input', f'n={count}', inputs / 'notes.typ']
            samples = []
            for trial in range(args.repeat):
                seconds, _ = run([*base, output / f'{name}.pdf'], args.timeout)
                samples.append(seconds)
                print(f'{name} ({trial+1}/{args.repeat}): {seconds:.3f}s', flush=True)
            case = dict(kind=kind, count=count, samples_seconds=samples, median_seconds=statistics.median(samples),
                        pdf=f'{name}.pdf')
            if baseline:
                previous = next((c for c in baseline['cases'] if (c['kind'], c['count']) == (kind, count)), None)
                if previous is None:
                    raise ValueError(f'Baseline has no {name} case.')
                case['baseline_seconds'] = previous['median_seconds']
                case['speedup'] = previous['median_seconds'] / case['median_seconds']
                print(f'{name}: {case["speedup"]:.2f}x baseline/now', flush=True)
            record['cases'].append(case)
            save()
            if args.trace:
                run([*base, '--timings', output / f'{name}.trace.json', output / f'{name}.pdf'], args.timeout)
    # Keep rasterization and parsing outside every timed sample.
    if args.compare_rendering:
        for case in record['cases']:
            previous = next(c for c in baseline['cases'] if (c['kind'], c['count']) == (case['kind'], case['count']))
            case['rendering'] = compare_pdfs(args.baseline.resolve().parent / previous['pdf'], output / case['pdf'],
                                            output / f'{case["kind"]}-{case["count"]}-comparison', args.timeout)
            save()
    print(result_path, flush=True)


if __name__ == '__main__':
    main()
