#import "@preview/tidy:0.4.3"
#import tidy.utilities: *

#import "admonitions.typ": inject-admonitions

// Transforms ` ```ref #deixis-something ``` ` blocks into native Typst cross-references.
#let inject-links(doc-text) = {
  if doc-text == none or doc-text == "" { return "" }
  
  let lines = doc-text.split("\n")
  let out = ()
  
  let in-ref = false
  let ref-b-count = 0
  let ref-content = ()

  for line in lines {
    let trimmed = line.trim()
    
    if not in-ref {
      let inline-pattern = regex("(`{3,})ref\\s+#([a-zA-Z0-9_-]+(?:\\.[a-zA-Z0-9_-]+)?)\\s*`{3,}")
      
      if line.match(inline-pattern) != none {
        out.push(line.replace(inline-pattern, m => "@" + m.captures.at(1)))
        continue
      }

      let open-match = trimmed.match(regex("^(`{3,})ref$"))
      if open-match != none {
        in-ref = true
        ref-b-count = open-match.captures.at(0).len()
        ref-content = ()
        continue
      }
      
      out.push(line)
      
    } else {
      let close-match = trimmed.match(regex("^(`{3,})$"))
      if close-match != none and close-match.captures.at(0).len() == ref-b-count {
        in-ref = false
        let joined = ref-content.join("").trim()
        
        let id-match = joined.match(regex("^#(deixis-[a-zA-Z0-9_-]+(?:\\.[a-zA-Z0-9_-]+)?)$"))
        
        if id-match != none {
          out.push("@" + id-match.captures.at(0))
        } else {
          out.push(joined) 
        }
        continue
      }
      
      ref-content.push(line)
    }
  }
  
  return out.join("\n")
}

#let injector(doc-text) = inject-admonitions(inject-links(doc-text))

// Color to highlight function names in
#let function-name-color = rgb("#4b69c6")
#let rainbow-map = ((rgb("#7cd5ff"), 0%), (rgb("#a6fbca"), 33%), (rgb("#fff37c"), 66%), (rgb("#ffa49d"), 100%))
#let gradient-for-color-types = gradient.linear(angle: 7deg, ..rainbow-map)
#let gradient-for-tiling = gradient.linear(angle: -45deg, rgb("#ffd2ec"), rgb("#c6feff")).sharp(2).repeat(5)

#let default-type-color = rgb("#eff0f3")

// Colors for Typst types
#let colors = (
  "default": default-type-color,
  "content": rgb("#a6ebe6"),
  "string": rgb("#d1ffe2"),
  "str": rgb("#d1ffe2"),
  "none": rgb("#ffcbc4"),
  "auto": rgb("#ffcbc4"),
  "bool": rgb("#ffedc1"),
  "boolean": rgb("#ffedc1"),
  "integer": rgb("#e7d9ff"),
  "int": rgb("#e7d9ff"),
  "float": rgb("#e7d9ff"),
  "ratio": rgb("#e7d9ff"),
  "length": rgb("#e7d9ff"),
  "angle": rgb("#e7d9ff"),
  "alignment": rgb("#94ecff"),
  "relative length": rgb("#e7d9ff"),
  "relative": rgb("#e7d9ff"),
  "fraction": rgb("#e7d9ff"),
  "label": rgb("#c4d3eb"),
  "location": rgb("#c4d3eb"),
  "symbol": default-type-color,
  "array": default-type-color,
  "dictionary": default-type-color,
  "arguments": default-type-color,
  "selector": default-type-color,
  "module": default-type-color,
  "stroke": default-type-color,
  "function": rgb("#f9dfff"),
  "color": gradient-for-color-types,
  "gradient": gradient-for-color-types,
  "tiling": gradient-for-tiling,
  "signature-func-name": rgb("#4b69c6"),
)

#let typst-doc-url(type-name) = {
  let base = "https://typst.app/docs/reference/"
  let paths = (
    "content": "foundations/content/",
    "str": "foundations/str/",
    "string": "foundations/str/",
    "none": "foundations/none/",
    "auto": "foundations/auto/",
    "int": "foundations/int/",
    "float": "foundations/float/",
    "bool": "foundations/bool/",
    "boolean": "foundations/bool/",
    "dictionary": "foundations/dictionary/",
    "array": "foundations/array/",
    "arguments": "foundations/arguments/",
    "function": "foundations/function/",
    "label": "foundations/label/",
    "length": "layout/length/",
    "relative": "layout/relative/",
    "alignment": "layout/alignment/",
    "stroke": "visualize/stroke/",
    "color": "visualize/color/",
  )
  if type-name in paths {
    base + paths.at(type-name)
  } else {
    none
  }
}

#let colors-dark = {
  let k = (:)
  let darkify(clr) = clr.darken(30%).saturate(30%)
  for (key, value) in colors {
    if type(value) == color {
      value = darkify(value)
    } else if type(value) == gradient {
      let map = value.stops().map(((clr, stop)) => (darkify(clr), calc.round(stop / 1%) * 1%))
      value = value.kind()(..map)
    }
    k.insert(key, value)
  }
  k.signature-func-name = rgb("#4b69c6").lighten(40%)
  k
}


#let beautify-types(body) = {
  show regex("([a-zA-Z0-9_.-]+)[ \t]*\(([-a-zA-Z0-9, \t]+)\):"): it => {
    let parts = it.text.split("(")
    let param-name = parts.at(0).trim()
    let types-string = parts.at(1).slice(0, -2)
    let types = types-string.split(",").map(s => s.trim())

    let badges = types.map(t => {
      let url = typst-doc-url(t)

      let badge = box(
        fill: tidy-color(t),
        inset: (x: 3pt, y: 0pt),
        outset: (y: 3pt),
        radius: 2pt,
        {
          show raw: set box(fill: none, outset: 0pt)
          raw(t)
        },
      )
      if url != none {
        link(url, badge)
      } else {
        badge
      }
    })

    raw(param-name)
    h(0.4em)
    badges.join(h(0.3em))
    text(":")
  }

  body
}


#let show-outline(module-doc, style-args: (:)) = {
  let prefix = module-doc.label-prefix
  let gen-entry(name) = {
    if "enable-cross-references" in style-args and style-args.enable-cross-references {
      link(label(prefix + name), name)
    } else {
      name
    }
  }
  if module-doc.functions.len() > 0 {
    list(..module-doc.functions.map(fn => gen-entry(fn.name + "()")))
  }

  if module-doc.variables.len() > 0 {
    text(get-local-name("variables", style-args: style-args), weight: "bold")
    list(..module-doc.variables.map(var => gen-entry(var.name)))
  }
}

// Create beautiful, colored type box
#let show-type(type-name, ..style-args) = {
  let url = typst-doc-url(type-name)
  let badge = box(
    fill: colors.at(type-name),
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
    {
      show raw: set box(fill: none, outset: 0pt)
      raw(type-name, lang: "badge")
    },
  )

  if url != none {
    link(url, badge)
  } else {
    badge
  }
}



#let show-parameter-list(fn, style-args: (:)) = {
  pad(x: 10pt, {
    set text(font: "DejaVu Sans Mono", size: 0.85em, weight: 340)
    text(fn.name, fill: style-args.colors.at("signature-func-name", default: rgb("#4b69c6")))
    "("
    let inline-args = fn.args.len() < 2
    if not inline-args { "\n  " }
    let items = ()
    let args = fn.args
    for (name, info) in fn.args {
      if style-args.omit-private-parameters and name.starts-with("_") {
        continue
      }
      let types
      if "types" in info {
        types = ": " + info.types.map(x => show-type(x, style-args: style-args)).join(" ")
      }
      if (
        style-args.enable-cross-references
          and not (info.at("description", default: "") == "" and style-args.omit-empty-param-descriptions)
      ) {
        name = link(label(style-args.label-prefix + fn.name + "." + name.trim(".")), name)
      }
      items.push(name + types)
    }
    items.join(if inline-args { ", " } else { ",\n  " })
    if not inline-args { "\n" } + ")"
    if "return-types" in fn and fn.return-types != none {
      " -> "
      fn.return-types.map(x => show-type(x, style-args: style-args)).join(" ")
    }
  })
}



// Create a parameter description block, containing name, type, description and optionally the default value.
#let show-parameter-block(
  function-name: none,
  name,
  types,
  content,
  style-args,
  show-default: false,
  default: none,
) = block(
  above: 0.5em,
  inset: 10pt,
  fill: rgb("ddd3"),
  width: 100%,
  breakable: true,
  [
    #set raw(lang: "typc")
    #box(heading(level: style-args.first-heading-level + 3, name))
    #if function-name != none and style-args.enable-cross-references { label(function-name + "." + name.trim(".")) }
    #h(1.2em)
    #types.map(x => (style-args.style.show-type)(x, style-args: style-args)).join([ #text("or", size: .6em) ])

    #[
      #show raw.where(lang: "typc"): it => {
        if it.text in colors.keys() {
          (style-args.style.show-type)(it.text, style-args: style-args)
        } else {
          it
        }
      }
      #content
    ]
    #if show-default [
      #parbreak()
      #get-local-name("default", style-args: style-args): #raw(lang: "typc", default)
    ]
  ],
)


#let show-function(
  fn,
  style-args,
) = {
  if style-args.colors == auto { style-args.colors = colors }

  align(center)[
    #set text(fill: function-name-color)
    #heading(fn.name + "()", level: style-args.first-heading-level + 1)
    #if style-args.enable-cross-references {
      label(style-args.label-prefix + fn.name + "()")
    }
  ]

  set raw(lang: "typc")
  eval-docstring(injector(fn.description), style-args)

  block(breakable: style-args.break-param-descriptions, {
    heading(
      get-local-name("parameters", style-args: style-args),
      level: style-args.first-heading-level + 2,
    )
    (style-args.style.show-parameter-list)(fn, style-args: style-args)
  })

  for (name, info) in fn.args {
    if style-args.omit-private-parameters and name.starts-with("_") {
      continue
    }
    let types = info.at("types", default: ())
    let description = info.at("description", default: "")
    if description == "" and style-args.omit-empty-param-descriptions { continue }
    (style-args.style.show-parameter-block)(
      name,
      types,
      eval-docstring(injector(description), style-args),
      style-args,
      show-default: "default" in info,
      default: info.at("default", default: none),
      function-name: style-args.label-prefix + fn.name,
    )
  }
  v(4.8em, weak: true)
}



#let show-variable(
  var,
  style-args,
) = {
  if style-args.colors == auto { style-args.colors = colors }
  let type = if "type" not in var { none } else { show-type(var.type, style-args: style-args) }

  stack(
    dir: ltr,
    spacing: 1.2em,
    if style-args.enable-cross-references [
      #heading(var.name, level: style-args.first-heading-level + 1)
      #label(style-args.label-prefix + var.name)
    ] else [
      #heading(var.name, level: style-args.first-heading-level + 1)
    ],
    type,
  )

  set raw(lang: "typc")
  eval-docstring(injector(var.description), style-args)
  v(4.8em, weak: true)
}


#let show-reference(label, name, style-args: none) = {
  link(label, raw(name, lang: none))
}


#import tidy.show-example: show-example
#import "demo.typ": demo

#let show-example(
  code,
  ..args,
) = {
  demo(
    code,
    ..args,
  )
  // example.show-example(
  //   ..args,
  //   layout: example.default-layout-example.with(
  //     code-block: block.with(radius: 3pt, stroke: .5pt + luma(200)),
  //     preview-block: block.with(radius: 3pt, fill: rgb("#e4e5ea")),
  //     col-spacing: 5pt
  //   ),
  // )
}
