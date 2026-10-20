#!/usr/bin/env python3
"""Check page-local display numbering, convergence and actual PDF navigation."""
import argparse
import json
from pathlib import Path
import re
import subprocess
import time
import xml.etree.ElementTree as ET

from pypdf import PdfReader

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'tests/integration/page-numbering.typ'
CASES = [
    ('contracts', {}), ('contracts-overlay', {'mode': 'contracts', 'layer': 'foreground'}),
    ('decimal', {'mode': 'natural'}), ('symbols', {'mode': 'natural', 'symbols': 'true'}),
    ('anonymous', {'mode': 'natural', 'named': 'false'}),
    ('decimal-400', {'mode': 'natural', 'n': '400'}),
    ('symbols-400', {'mode': 'natural', 'n': '400', 'symbols': 'true'}),
    *((mode, {'mode': mode}) for mode in ('columns', 'long', 'nested', 'forward-body', 'phantom', 'region', 'replay', 'scopes')),
]


def layout_passes(path):
    # Official 0.15 traces use this event prefix. Scan bounded chunks: a
    # 400-note trace is hundreds of MB and need not become millions of dicts.
    prefix = re.compile(rb'\{\s*"name"\s*:\s*"layout document"\s*,\s*"cat"\s*:\s*"typst"\s*,\s*"ph"\s*:\s*"B"')
    carry, offset, last_end, count = b'', 0, 0, 0
    with path.open('rb') as source:
        while chunk := source.read(1024 * 1024):
            data = carry + chunk
            base = offset - len(carry)
            for match in prefix.finditer(data):
                end = base + match.end()
                if end > last_end:
                    count += 1
                    last_end = end
            offset += len(chunk)
            carry = data[-512:]
    assert count > 0, 'No document layout events found in trace.'
    return count


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--typst', default='typst')
    parser.add_argument('--output', type=Path, default=ROOT / 'target/page-numbering')
    parser.add_argument('--case', action='append', default=[], choices=[name for name, _ in CASES],
                        help='Run selected cases only.')
    args = parser.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    version = subprocess.check_output([args.typst, '--version'], text=True).strip()
    records = []

    def run(command):
        result = subprocess.run(list(map(str, command)), capture_output=True, text=True, timeout=120)
        assert result.returncode == 0 and not result.stderr, result.stderr or result.stdout
        return result.stdout

    for name, inputs in CASES:
        if args.case and name not in args.case:
            continue
        flags = [a for k, v in inputs.items() for a in ('--input', f'{k}={v}')]
        trace, pdf = out / (name + '.trace.json'), out / (name + '.pdf')
        start = time.perf_counter()
        result = subprocess.run([args.typst, 'compile', '--root', str(ROOT), '--jobs', '1',
                                 '--timings', str(trace), *flags, str(SOURCE), str(pdf)],
                                capture_output=True, text=True, timeout=120)
        (out / (name + '.log')).write_text(result.stderr or result.stdout)
        assert result.returncode == 0 and not result.stderr, (name, result.stderr)
        elapsed = time.perf_counter() - start
        passes = layout_passes(trace)
        data = json.loads(run([args.typst, 'eval', '--root', ROOT, '--in', SOURCE, *flags,
                              '--format', 'json', 'query(<page-numbering-result>).first().value']))
        reader = PdfReader(pdf)
        page_ids = {p.indirect_reference.idnum for p in reader.pages}
        links = 0
        for page in reader.pages:
            for ref in page.get('/Annots', []):
                item = ref.get_object()
                dest = item.get('/Dest', item.get('/A', {}).get('/D'))
                if hasattr(dest, 'get_object'):
                    dest = dest.get_object()
                if isinstance(dest, list):
                    assert dest[0].idnum in page_ids, (name, dest)
                    links += 1
        assert links > 0, name
        if inputs.get('mode') == 'natural':
            assert links >= 2 * data['notes'] and data['original_pages'] > 1, name
        text = ''.join(''.join(p.extract_text().split()) for p in reader.pages)
        if name == 'contracts':
            assert '3UPDATED_BODY' in text and '5AFTER_FORCED_BODY' in text
            assert 'XFORCED_BODY' in text and 'OMITTED_BODY' not in text
            assert 'References:3,1,1.' in text, text
            # Hidden originals keep catalogue entries, but no live footer.
            assert 'HIDDEN_ONLY_BODY' not in ''.join(p.extract_text() for p in reader.pages[:2])
        bounds = out / (name + '-bounds.xml')
        run(['pdftotext', '-bbox', pdf, bounds])
        ns = {'x': 'http://www.w3.org/1999/xhtml'}
        for page in ET.parse(bounds).findall('.//x:page', ns):
            width, height = float(page.attrib['width']), float(page.attrib['height'])
            for word in page.findall('.//x:word', ns):
                x0, y0, x1, y1 = (float(word.attrib[k]) for k in ('xMin', 'yMin', 'xMax', 'yMax'))
                assert 0 <= x0 <= x1 <= width and 0 <= y0 <= y1 <= height, (name, word.text)
        records.append(dict(case=name, inputs=inputs, compiler=version, layout_passes=passes,
                            pages=len(reader.pages), links=links, seconds=elapsed, evidence=data, warnings=''))
        print(name, 'passed;', len(reader.pages), 'pages;', passes, 'layout passes', flush=True)
    # Settings scoping and host-owned overlays exercise the same public policy.
    run([args.typst, 'compile', '--root', ROOT, '--jobs', '1',
         ROOT / 'tests/integration/page-numbering-settings.typ', out / 'settings.pdf'])
    settings_text = ''.join(''.join(p.extract_text().split()) for p in PdfReader(out / 'settings.pdf').pages)
    assert 'References:3,1,2,1.' in settings_text, settings_text
    assert 'Nestedrecord1' in settings_text and 'Nestedrecorda' not in settings_text, settings_text
    for host in ('0.6.3', '0.8.0'):
        run([args.typst, 'compile', '--root', ROOT, '--jobs', '1', '--input', 'touying-version=' + host,
             ROOT / 'tests/integration/page-numbering-touying.typ', out / ('touying-' + host + '.pdf')])
    for mode in ('restart', 'pattern', 'unknown', 'mixed'):
        result = subprocess.run([args.typst, 'compile', '--root', str(ROOT), '--input', 'mode=' + mode,
                                 str(ROOT / 'tests/invalid/numbering-record.typ'), str(out / 'invalid.pdf')],
                                capture_output=True, text=True, timeout=120)
        (out / ('invalid-' + mode + '.log')).write_text(result.stderr)
        assert result.returncode != 0 and 'numbering record must be' in result.stderr, result.stderr
    (out / 'results.json').write_text(json.dumps(dict(compiler=version, cases=records,
        invalid_cases=4, failures=0, timing_note='Instrumented builds; not a performance comparison.'), indent=2) + '\n')


if __name__ == '__main__':
    main()
