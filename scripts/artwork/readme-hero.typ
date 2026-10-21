// All floating fragments are real Deixis output with transparent backgrounds.
// Bundled SVGs allow immediate IDE preview; refresh with render-readme.py.
#set page(width: 1300pt, height: 525pt, margin: 0pt, fill: rgb("F6F4FC"))
#set text(font: "DejaVu Sans", fill: rgb("24374D"))
#place(top + left, dx: -120pt, dy: -220pt,
  circle(width: 760pt, stroke: none,
    fill: gradient.radial(rgb("D9D2FF99"), rgb("D9D2FF00"))))
#place(top + right, dx: 140pt, dy: 160pt,
  circle(width: 780pt, stroke: none,
    fill: gradient.radial(rgb("BFE8DE99"), rgb("BFE8DE00"))))
#place(top + right, dx: 200pt, dy: -270pt,
  circle(width: 650pt, stroke: none,
    fill: gradient.radial(rgb("FFE0B399"), rgb("FFE0B300"))))

#let fragment(name, x, y, width, angle) = {
  let source = sys.inputs.at(name, default: "../../assets/readme/hero-" + name + ".svg")
  place(top + left, dx: x * 1pt, dy: y * 1pt,
    rotate(angle, reflow: false, image(source, width: width * 1pt)))
}
#fragment("text", 410, -18, 500, -5deg)
#fragment("diagram", 910, -27, 400, 9deg)
#fragment("equation", 440, 135, 560, 3deg)
#fragment("outline", 900, 182, 380, 7deg)
#fragment("shared", 805, 370, 505, -6deg)
#fragment("editorial", 385, 380, 410, 5deg)
#fragment("footnote", 25, -8, 310, -3deg)
#fragment("local", 28, 365, 345, -4deg)

#place(top + left, dx: 57pt, dy: 100pt,
  text(size: 11pt, tracking: 0.14em, fill: rgb("62708B"))[ANNOTATIONS FOR TYPST])
#place(top + left, dx: 43pt, dy: 125pt,
  image("../../assets/logos/deixis-logo-horizontal.svg", width: 340pt))
#place(top + left, dx: 56pt, dy: 245pt,
  text(size: 32pt, weight: "bold", tracking: -0.035em)[Point to \
    What Matters])
