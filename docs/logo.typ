#import "@preview/cetz:0.5.2"

// It looks horrible, I know.
#let deixis-logo = cetz.canvas(length: 1.2cm, {
  import cetz.draw: *

  let mark-color = rgb("FF5A5F")
  let body-color = rgb("007A87")
  let link-color = luma(140)

  // the link
  hobby(
    (1.7, 0.15),
    (2.2, 0.2),
    (3.6, 1.0),
    (3.0, 1.5),
    (2.4, 1.0),
    (3.0, 0.3),
    (3.8, 0.15),
    (4.4, 0.1),
    stroke: (paint: link-color, thickness: 2.5pt, dash: "dashed"),
    name: "knot"
  )

  // the mark
  group(name: "mark", {
    circle((0, 0), radius: 0.9, fill: mark-color, stroke: none)
    
    // arm
    line((0.4, 0.0), (1.2, 0.0), stroke: (paint: mark-color, thickness: 14pt, cap: "round"))
    line((1.2, 0.15), (1.7, 0.15), stroke: (paint: mark-color, thickness: 4pt, cap: "round"))

    // eyes
    circle((0.3, 0.3), radius: 0.25, fill: white, stroke: none)
    circle((0.8, 0.3), radius: 0.25, fill: white, stroke: none)
    circle((0.45, 0.3), radius: 0.08, fill: black, stroke: none) 
    circle((0.95, 0.3), radius: 0.08, fill: black, stroke: none) 
  })

  // the body
  group(name: "body", {
    rect((4.4, -0.8), (6.4, 0.8), radius: 0.2, fill: body-color, stroke: none)
    
    // bored eyes
    line((4.7, 0.3), (5.3, 0.3), stroke: (paint: white, thickness: 5pt, cap: "round"))
    line((5.7, 0.3), (6.2, 0.3), stroke: (paint: white, thickness: 5pt, cap: "round"))
    circle((4.8, 0.25), radius: 0.08, fill: black, stroke: none)
    circle((5.8, 0.25), radius: 0.08, fill: black, stroke: none)
    
    // unamused mouth
    line((5.1, -0.2), (5.6, -0.2), stroke: (paint: white, thickness: 2pt, cap: "round"))
  })
  
  // typography
  content((2.75, -0.5), text(
    size: 24pt, 
    weight: "bold", 
    font: "Linux Libertine O", 
    fill: rgb("2C363F"), 
    tracking: 0.03em
  )[deixis])
})
