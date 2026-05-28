#set page(width: 300pt, height: 240pt, margin: (x: 1cm, rest: 1cm))

#import "../src/lib.typ": *
#show: deixis-setup-notes
#show raw: set text(size: 0.85em)

The Sigmoid function
#deixis-region-mark(
  stroke: yellow,
  fill: yellow.transparentize(95%),
  inline: true,
  layer: "background",
)[$sigma(dot)$]
maps any value into a probability in $[0, 1]$:

#align(center,  // wrapped equations cannot auto align center
  deixis-region-mark(
  stroke: blue,
  fill: blue.transparentize(95%),
  padding: "text",
  layer: "background",
)[
$ sigma(z) = frac(1, 1 + #deixis-pin("e-left")e#deixis-pin("e-right")^(-#deixis-pin("z-left")z#deixis-pin("z-right"))) $
])
#deixis-set(
  body-style: it => text(size: 0.6em, it),
  side-strategy: "strict",
  container-func: (margin-note: rect),
)
#deixis-inset-note(
  pins: ("z-left", "z-right"),
  marker-style: it => text(fill: green, super(it)),
  stroke: (rest: green, link: stroke(paint: green, thickness: 0.5pt, dash: "dashed")),
  fill: green.transparentize(95%),
  link: "curve",
  link-ports: (body: bottom),
  link-marks: "body",
  dx: 1em,
  dy: -2em,
)[
  $z$: input value (the "logit").
]
#deixis-inset-note(
  pins: ("e-left", "e-right"),
  marker-style: it => text(fill: red, super(it)),
  stroke: (rest: red, link: stroke(paint: red, thickness: 0.5pt, dash: "dashed")),
  fill: red.transparentize(95%),
  link: "curve",
  link-ports: (mark: bottom, body: left),
  link-marks: "body",
  dx: 2em,
  dy: 2em,
)[
  $e$: Euler's constant.
]
Python code:

#deixis-set-pin-pattern(
  prefix: "deixispin",
  postfix: "deixis",
)
#deixis-attach(
```python
z = np.array([-np.inf, -1.5, 0, 1.5, np.inf])
# this computes 1 / (1 + exp(-z))
probability = deixispine0deixisexpitdeixispine1deixis(z)
print(f"Logit:\n{z}")
print(f"Probability:\n{probability}")
```
)
#deixis-footnote(
  pins: ("e0", "e1"),
  marker-style: it => text(fill: teal, super(it)),
  stroke: teal,
  fill: teal.transparentize(95%),
)[```python from scipy.special import expit```]
