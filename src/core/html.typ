// HTML export links marks and bodies through their internal label spellings.
// Typst-assigned anchors would need another layout pass after a destination
// settles, which deep scope chains cannot afford. Only these helpers target
// the deixis-mark-*/deixis-body-* names, so the ids stay unique.
#let _deixis-html-anchor(lbl) = if lbl != none and std.target() == "html" {
  html.elem("span", attrs: (id: str(lbl)))
}

#let _deixis-html-link(lbl, body) = if std.target() == "html" {
  html.elem("a", attrs: (href: "#" + str(lbl)), body)
} else { std.link(lbl, body) }
