#import "../../src/lib.typ": *
#set page(width: 260pt, height: auto, margin: 12pt)
#set text(size: 13pt)
#let teal = rgb("32736D")
#show: deixis-setup-notes

// BEGIN EXAMPLE
#for mode in ("box", "highlight",
  "underline", "parentheses",
  "text-fill", "none") {
  deixis-mark(inline-mode: mode,
    stroke: teal)[A marked passage]
  linebreak()
}
// END EXAMPLE
