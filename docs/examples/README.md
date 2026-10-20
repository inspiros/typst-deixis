# Manual Worked Examples

These compact documents produce the source/output pairs in the manual. Each
`.typ` source has complete imports, setup and page geometry. Compile from the
repository root, for example:

```sh
typst compile --root . docs/examples/inset.typ target/manual-inset.pdf
```

The code between `// BEGIN EXAMPLE` and `// END EXAMPLE` is printed verbatim in
the manual. Shared setup/page geometry is explained once in its introduction.
The two numeric drawing examples require no note setup. The full Touying source
in `examples/touying-reveals.typ` supplies the slide comparison instead of a
second copy here.

`catalog.json` controls titles, captions, setup badges and expected output pages.
After changing a source, its catalogue or package code, rebuild the previews:

```sh
python3 scripts/render-manual-examples.py
python3 scripts/render-manual-examples.py --check
python3 scripts/render-manual.py
```

PDFs and isolated package copies go to `target/manual-examples/`; maintained SVG
assets and their digest index go to `docs/assets/examples/`. The manual embeds
those images instead of evaluating live annotations inside a code sandbox.
For working PDF navigation, open the standalone specimen PDF.

`python3 tests/run.py --manual` includes the compact specimens in its compilation
sweep; the regular example sweep covers Touying. `tests/manual.py` checks exact
example coverage and current preview hashes. Keep headings in Camel Case With
Spaces, explanations concise and source/output large enough to read. There is
no fixed manual page limit.
