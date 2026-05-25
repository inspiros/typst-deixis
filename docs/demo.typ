#let _get-src(source) = if type(source) != str { source.text } else { source }

#let example-box(body,
  fill: rgb("#f8f9fa"),
  stroke: 1pt + rgb("#e9ecef"),
  inset: 0.8em,
  radius: 0.5em,
  width: 100%,
  height: auto,
  ..args,
) = block(
  fill: fill,
  stroke: stroke,
  inset: inset,
  radius: radius,
  width: width,
  height: height,
  ..args,
  body
)

#let source-box(source, ..args) = example-box(..args)[
  #let source = _get-src(source)
  // #show: codly-init
  // #codly(
  //   display-icon: false,
  //   display-name: false,
  //   stroke: none,
  //   fill: none,
  //   zebra-fill: none,
  // )
  #raw(source, lang: "typst", block: true)
]

#let _parse-config(text) = {
  if text == none or text.trim() == "" {
    return (text: "", overrides: (:))
  }

  let overrides = (:)
  let clean-lines = ()
  let parsing-config = true

  for line in text.split("\n") {
    let trimmed = line.trim()
    
    if parsing-config {
      if trimmed == "" {
        continue
      } else if trimmed.starts-with("//|") {
        let content = trimmed.slice(3).trim()
        let parsed = eval("(" + content + ")")
        for (k, v) in parsed {
          overrides.insert(k, v)
        }
        continue
      } else {
        parsing-config = false
      }
    }
    
    clean-lines.push(line)
  }
  
  let final-text = if clean-lines.len() == 0 { 
    "" 
  } else { 
    clean-lines.join("\n").trim() 
  }
  
  return (text: final-text, overrides: overrides)
}

/// Evaluates Typst code and renders it side-by-side (or top-to-bottom) with the source.
///
/// - code (raw, str)
/// - actual-code (raw, str)
/// - sandbox (str): If true, isolates heading counters and traps deixis notes inside a local block. Choices: `"inline"` | `"page"` | `"minipage"`.
///
/// -> content
#let demo(
  code,
  actual-code: none,
  inherited-scope: (:),
  layout: "horizontal",
  mode: "markup",
  preamble: "",
  scope: (:),
  // custom parameters
  sandbox-mode: "inline",
  sandbox: true,
  margin: 0.05in,
  height: auto,
  ..options,
) = {
  let raw-source = _get-src(code)
  let parsed-source = _parse-config(raw-source)
  let source = parsed-source.text

  let raw-actual = if actual-code in (auto, none) { raw-source } else { _get-src(actual-code) }
  let parsed-actual = _parse-config(raw-actual)
  let actual-source = parsed-actual.text

  let merged-overrides = parsed-source.overrides
  for (k, v) in parsed-actual.overrides {
    merged-overrides.insert(k, v)
  }

  // apply overrides
  let layout = merged-overrides.at("layout", default: layout)
  let sandbox-mode = merged-overrides.at("sandbox-mode", default: sandbox-mode)
  let sandbox = merged-overrides.at("sandbox", default: sandbox)
  let margin = merged-overrides.at("margin", default: margin)
  let height = merged-overrides.at("height", default: height)

  set text(font: "Linux Libertine", size: 10pt)

  let preamble = preamble + "
  #import \"../src/lib.typ\": *
  "

  if sandbox {
    preamble += "
    #set heading(numbering: none, outlined: false)
    #counter(\"example-heading\").update(0)

    #show heading: it => {
      counter(\"example-heading\").step(level: it.level)
      block[
        #text(size: 1.2em, weight: \"bold\")[
          #if it.numbering != none {
            counter(\"example-heading\").display(it.numbering)
            h(0.5em)
          }
          #it.body
        ]
      ]
    }

    #show pagebreak: block(
      width: 100%,
      inset: (y: 1em),
      line(length: 100%, stroke: (dash: \"dashed\", paint: luma(200)))
    )
    "
  }

  let wrapped-code = ""
  if sandbox-mode == "minipage" {
    wrapped-code = (
      preamble
        + "
    #deixis-block(
      width: 100%,
      height: " + repr(if height != auto {100%} else {auto}) + ",
      inset: " + repr(margin) + ",
      fill: none,
      stroke: none,
      radius: 0pt,
      breakable: false,
    )[
      "
        + actual-source
        + "
    ]"
    )
  } else if sandbox-mode == "inline" {
    wrapped-code = (
      preamble
        + "
    #deixis-block(
      width: 100%,
      height: " + repr(if height != auto {100%} else {auto}) + ",
      inset: " + repr(margin) + ",
      fill: none,
      stroke: none,
      radius: 0pt,
      breakable: true,
    )[
      "
        + actual-source
        + "
    ]"
    )
  } else if sandbox-mode == "page" {
    wrapped-code = (
      preamble
        + "
    #block(
      width: 100%,
      height: " + repr(if height != auto {100%} else {auto}) + ",
      inset: " + repr(margin) + ",
      fill: none,
      stroke: none,
      radius: 0pt,
      breakable: true,
    )[
      "
        + actual-source
        + "
    ]"
    )
  } else {
    wrapped-code = preamble + actual-source
  }

  let preview-content = eval(wrapped-code, mode: mode, scope: inherited-scope + scope)

  let make-paper(body, h: auto) = {
    if sandbox-mode in ("minipage", "inline") {
      block(
        fill: white,
        stroke: 0.5pt + luma(200),
        radius: 4pt,
        width: 100%,
        height: h,
        body
      )
    } else if sandbox-mode == "page" {
      block(
        fill: white,
        stroke: none,
        radius: 4pt,
        width: 100%,
        height: h,
        body
      )
    } else {
      if h == 100% {
        block(width: 100%, height: 100%, body)
      } else {
        body
      }
    }
  }

  let source-ui = source-box(source, height: height)
  let preview-ui = if height != auto {
    example-box(make-paper(preview-content, h: 100%), height: height, breakable: false)
  } else {
    example-box(make-paper(preview-content), breakable: false)
  }
  // let preview-ui = example-box(make-paper(preview-content), breakable: false)

  if layout == "horizontal" {
    std.layout(bounds => {
      context {
        let col-width = (bounds.width - 5pt) / 2

        // Measure natural heights
        let s-height = measure(block(width: col-width, source-ui)).height
        let p-height = measure(block(width: col-width, preview-ui)).height
        let max-h = calc.max(s-height, p-height)

        grid(
          columns: (1fr, 1fr),
          gutter: 5pt,
          source-box(source, height: max-h),
          example-box(make-paper(preview-content, h: 100%), height: max-h, breakable: false),
        )
      }
    })
  } else if layout == "vertical" {
    grid(columns: 1fr, gutter: 5pt, source-ui, preview-ui)
  } else {
    preview-ui
  }
}

#let show-demo(body) = {
  show raw.where(lang: "source"): it => source-box(it.text)
  show raw.where(lang: "preview"): it => demo(it.text, layout: "preview", sandbox-mode: "inline")

  show raw.where(lang: "demo"): it => demo(it.text, layout: "horizontal", sandbox-mode: "inline")
  show raw.where(lang: "vdemo"): it => demo(it.text, layout: "vertical", sandbox-mode: "inline")
  show raw.where(lang: "demo-minipage"): it => demo(it.text, layout: "horizontal", sandbox-mode: "minipage")
  show raw.where(lang: "vdemo-minipage"): it => demo(it.text, layout: "vertical", sandbox-mode: "minipage")
  show raw.where(lang: "demo-page"): it => demo(it.text, layout: "horizontal", sandbox-mode: "page")
  show raw.where(lang: "vdemo-page"): it => demo(it.text, layout: "vertical", sandbox-mode: "page")

  body
}
