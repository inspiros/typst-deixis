#!/usr/bin/env python3
"""Check README artwork in actual PDFs: page bounds, live notes and navigation."""
import argparse
from collections import defaultdict
import json
from pathlib import Path
import subprocess
import sys
import struct
import zlib
import xml.etree.ElementTree as ET

from pypdf import PdfReader

ROOT = Path(__file__).resolve().parents[1]
FRAGMENTS = ('text', 'equation', 'shared', 'diagram', 'editorial', 'footnote', 'outline', 'local')
NAMES = ('reading', 'equation', 'review-draft', 'review-final', 'hero', 'review',
         'slide-1', 'slide-2', 'slides') + tuple('hero-' + kind for kind in FRAGMENTS)


def corner_alpha(path):
    data = path.read_bytes()
    assert data[:8] == b'\x89PNG\r\n\x1a\n', path
    offset, compressed = 8, bytearray()
    while offset < len(data):
        size = struct.unpack('>I', data[offset:offset + 4])[0]
        kind = data[offset + 4:offset + 8]
        payload = data[offset + 8:offset + 8 + size]
        if kind == b'IHDR':
            _, _, depth, color, _, _, interlace = struct.unpack('>IIBBBBB', payload)
            assert depth == 8 and color in (2, 6) and interlace == 0, path
        if kind == b'IDAT':
            compressed.extend(payload)
        offset += 12 + size
    if color == 2:
        return 255
    # All PNG predictors are zero for the first pixel on the first scanline.
    return zlib.decompressobj().decompress(compressed, 5)[4]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--typst', default='typst')
    parser.add_argument('--output', type=Path, default=ROOT / 'target/readme-check')
    args = parser.parse_args()
    out = args.output.resolve()
    subprocess.run([sys.executable, ROOT / 'scripts/render-readme.py', '--typst', args.typst,
                    '--output-dir', out], check=True)
    base = [args.typst, 'eval', '--root', str(ROOT), '--package-path',
            str(out / 'package-data/typst/packages'), '--format', 'json']

    def evaluate(source, expression, *inputs):
        flags = [arg for value in inputs for arg in ('--input', value)]
        result = subprocess.run([*base, '--in', str(ROOT / source), *flags, expression],
                                capture_output=True, text=True, timeout=120)
        assert result.returncode == 0 and not result.stderr, result.stderr
        return json.loads(result.stdout)

    links = {}
    for name in NAMES:
        pdf = out / (name + '.pdf')
        reader = PdfReader(pdf)
        assert len(reader.pages) == 1, name
        page = reader.pages[0]
        links[name] = 0
        for ref in page.get('/Annots', []):
            annotation = ref.get_object()
            target = annotation.get('/Dest', annotation.get('/A', {}).get('/D'))
            if hasattr(target, 'get_object'):
                target = target.get_object()
            if isinstance(target, list):
                assert target[0].idnum == page.indirect_reference.idnum, name
                links[name] += 1
        bbox = out / (name + '-bounds.xml')
        subprocess.run(['pdftotext', '-bbox', pdf, bbox], check=True, capture_output=True)
        ns = {'x': 'http://www.w3.org/1999/xhtml'}
        p = ET.parse(bbox).find('.//x:page', ns)
        for word in p.findall('.//x:word', ns):
            x0, x1, y0, y1 = [float(word.attrib[k]) for k in ('xMin', 'xMax', 'yMin', 'yMax')]
            assert 0 <= x0 <= x1 <= float(p.attrib['width']), (name, word.text)
            assert 0 <= y0 <= y1 <= float(p.attrib['height']), (name, word.text)
    assert links['reading'] >= 6 and links['equation'] >= 6
    outline_text = PdfReader(out / 'hero-outline.pdf').pages[0].extract_text()
    assert links['hero-outline'] >= 9
    for excerpt in ('Every Note, In One Place', 'Clarify the central claim.',
                    'Keep the useful details.', 'Return to the evidence.'):
        assert excerpt in outline_text, excerpt
    for kind in FRAGMENTS:
        assert corner_alpha(out / ('hero-' + kind + '.png')) == 0, kind
    assert corner_alpha(out / 'hero.png') == 255

    evidence = '''(bodies: query(<deixis-body-destination>).len(),
      margin_series: query(<deixis-margin-note>).map(m => m.value.series),
      reused: query(<deixis-mark-occurrence>).map(m => m.value.targets))'''
    reading = evaluate('examples/annotated-reading.typ', evidence)
    assert reading['bodies'] == 3 and reading['reused'] == [['assumption']]
    shared = evaluate('docs/maintainers/artwork/hero-fragments.typ', evidence, 'kind=shared')
    assert shared['bodies'] == 1 and shared['reused'] == [['idea']]
    local = evaluate('docs/maintainers/artwork/hero-fragments.typ',
                     'query(<hero-local-evidence>).first().value', 'kind=local')
    assert len(local['owners']) == 1 and len(local['notes']) == 2
    assert all(n['owner'] == local['owners'][0] and n['layer'] == 'flow' for n in local['notes'])
    assert local['native'] == [0] and local['bodies'] == 2
    assert links['hero-local'] >= 4
    local_text = PdfReader(out / 'hero-local.pdf').pages[0].extract_text()
    assert 'Excludes one damaged sample.' in local_text and 'One calibration for this table.' in local_text
    draft = evaluate('examples/editorial-review.typ', evidence, 'final=false')
    final = evaluate('examples/editorial-review.typ', evidence, 'final=true')
    assert draft['bodies'] == 2 and draft['margin_series'] == ['review']
    assert final['bodies'] == 1 and final['margin_series'] == []
    for name in ('review-draft', 'review-final'):
        text = PdfReader(out / (name + '.pdf')).pages[0].extract_text()
        assert 'proposed method' in text and 'cited source remains in both builds' in text

    # Reveal frames: the callout and second footnote appear only after the pause.
    first, second = (PdfReader(out / f'slide-{page}.pdf').pages[0].extract_text() for page in (1, 2))
    assert 'present in both frames' in first and 'present in both frames' in second
    assert 'appear together' not in first and 'appears only in the second frame' not in first
    assert 'appear together' in second and 'appears only in the second frame' in second

    corners = evaluate('examples/annotated-equation.typ', '''query(<deixis-body-corner>).map(m =>
      (id: m.value.identity, x: m.location().position().x.pt(), y: m.location().position().y.pt()))''')
    groups = defaultdict(list)
    for corner in corners:
        groups[corner['id']].append(corner)
    assert len(groups) == 3 and all(len(c) == 4 for c in groups.values())
    frames = [(min(p['x'] for p in c), min(p['y'] for p in c),
               max(p['x'] for p in c), max(p['y'] for p in c)) for c in groups.values()]
    for i, (x0, y0, x1, y1) in enumerate(frames):
        assert 0 <= x0 < x1 <= 850 and 0 <= y0 < y1 <= 330
        for a0, b0, a1, b1 in frames[i + 1:]:
            assert x1 <= a0 or a1 <= x0 or y1 <= b0 or b1 <= y0, 'Equation callouts overlap.'
    result = dict(pages=len(NAMES), transparent_fragments=len(FRAGMENTS), internal_links=links,
                  note_outline=True, local_notes=True, shared_note=True, final_omission=True,
                  equation_frames=frames, failures=0)
    (out / 'results.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))


if __name__ == '__main__':
    main()
