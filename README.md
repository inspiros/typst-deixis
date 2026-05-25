deixis [![Typst Universe](https://img.shields.io/badge/dynamic/xml?url=https%3A%2F%2Ftypst.app%2Funiverse%2Fpackage%2Fdeixis&query=%2Fhtml%2Fbody%2Fdiv%2Fmain%2Fdiv%5B2%5D%2Faside%2Fsection%5B2%5D%2Fdl%2Fdd%5B3%5D&logo=typst&label=Universe&color=%23239DAE)](https://typst.app/universe/package/deixis) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE) [![User Manual](https://img.shields.io/badge/manual-.pdf-purple)][manual]
------

Decoupled annotations for [Typst](https://typst.app/).

`deixis` is a unified layout engine for footnotes, endnotes, margin notes, inset notes, inline highlights, and spatial annotations.

## Examples

<table>
<tr>
  <td>
  <sub>

```typst
#lorem(10)
#deixis-inline-mark(id: <note1>, marker: lorem(2))
#lorem(10)
#deixis-inline-mark(id: <note2>)[This is a marked text].
#lorem(10)

// link marks to bodies using unique ids
#deixis-footnote-body(id: <note1>)[Note 1.]
#deixis-footnote-body(id: <note2>)[Note 2.]
```

  </sub>
  </td>
  <td>
  <img src="assets/gallery/footnote.svg" width="300px" alt="Inline mark and footnote">
  </td>
</tr>
<tr>
  <td colspan="2" style='text-align:center; vertical-align:middle'>Inline mark + Footnote</td>
</tr>
</table>

## Installation

### From Typst Universe

This package is yet available in the Typst Universe.
When it is officially released, you will be able to download and use it by simply adding the following line to your document.

```typst
#import "@preview/deixis:0.1.0": *
```

### Local Use

For local use, first you need to clone the repo and run the install script:

```bash
git clone https://github.com/inspiros/deixis
python scripts/install.py
 ```

This Python script stores the package files in the right location following the instructions [here](https://github.com/typst/packages?tab=readme-ov-file#local-packages).
Once installed, you can import the package with:

```typst
#import "@local/deixis:0.1.0": *
```

## Usage

For detailed information, please see the [manual (PDF)][manual].

### Setup

No `deixis` functionality can be used before applying this setup show rule:

```typst
#show: deixis-setup-notes
```

## Acknowledgements

This package has some similar functionalities inspired by existing packages:
- [drafting](https://github.com/ntjess/typst-drafting): Margin note, but without numbering.
- [marge](https://github.com/EpicEricEE/typst-marge): Margin note, but without links.
- [pinit](https://github.com/OrangeX4/typst-pinit): Region annotation and inset note.

## License

MIT licensed, see [LICENSE](LICENSE).

[manual]: docs/manual.pdf
