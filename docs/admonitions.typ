#import "@preview/gentle-clues:1.3.1": *

#let show-admonitions(body) = {
  show raw.where(block: true): it => {
    let langs = ("info", "notify", "warning", "danger", "success", "error", "tip", "experiment", "conclusion", "memo", "code")
    
    if it.lang in langs {
      let preamble = "#import \"../src/lib.typ\": *\n"
      let content = eval(preamble + it.text, mode: "markup")
      
      if it.lang == "info" { info(content) }
      else if it.lang == "notify" { notify(content) }
      else if it.lang == "warning" { warning(content) }
      else if it.lang == "danger" { danger(content) }
      else if it.lang == "success" { success(content) }
      else if it.lang == "error" { error(content) }
      else if it.lang == "tip" { tip(content) }
      else if it.lang == "experiment" { experiment(content) }
      else if it.lang == "conclusion" { conclusion(content) }
      else if it.lang == "memo" { memo(content) }
      else if it.lang == "code" { code(content) }
    } else {
      it
    }
  }
  
  body
}

#let apply-admonitions(body, style-args) = {
  let eval-scope = style-args.at("scope", default: (:))
  
  show raw.where(block: true): it => {
    if it.lang in ("info", "notify", "warning", "danger", "success", "error", "tip", "experiment", "conclusion") {
      // Evaluate the raw string back into Typst markup!
      let content = eval(it.text, mode: "markup", scope: eval-scope)
      // break out of raw styling
      set text(font: "Linux Libertine", size: 11pt)

      if it.lang == "info" { info(content) }
      else if it.lang == "notify" { notify(content) }
      else if it.lang == "warning" { warning(content) }
      else if it.lang == "danger" { danger(content) }
      else if it.lang == "success" { success(content) }
      else if it.lang == "error" { error(content) }
      else if it.lang == "tip" { tip(content) }
      else if it.lang == "experiment" { experiment(content) }
      else if it.lang == "conclusion" { conclusion(content) }
      else if it.lang == "memo" { memo(content) }
      else if it.lang == "code" { code(content) }
    } else {
      it
    }
  }

  body
}

// Safely transforms markdown code blocks into native Typst admonitions 
// BEFORE Tidy evaluates the docstring. Supports infinite nesting!
#let inject-admonitions(doc-text) = {
  if doc-text == none or doc-text == "" { return "" }
  
  let lines = doc-text.split("\n")
  let out = ()
  
  // Our memory stack to track nested blocks
  let stack = ()

  for line in lines {
    let trimmed = line.trim()
    
    let open-match = trimmed.match(regex("^(`{3,})(info|notify|warning|danger|success|error|tip|experiment|conclusion|memo|code)$"))
    
    if open-match != none {
      let b-count = open-match.captures.at(0).len()
      let ad-name = open-match.captures.at(1)
      
      stack.push((count: b-count, name: ad-name))
      out.push("#" + ad-name + "[")
      continue
    }
    
    let close-match = trimmed.match(regex("^(`{3,})$"))
    if close-match != none and stack.len() > 0 {
      let b-count = close-match.captures.at(0).len()
      
      if b-count == stack.last().count {
        let _ = stack.pop() // Remove from stack
        out.push("]")
        continue
      }
    }
    
    out.push(line)
  }
  
  return out.join("\n")
}
