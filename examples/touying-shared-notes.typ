#import "@preview/touying:0.8.0": *
#import themes.simple: simple-theme, slide
#import "@preview/deixis:0.2.0": *

#show: simple-theme.with(aspect-ratio: "16-9", config-colors(primary: rgb("235c70")), config-page(
  background: deixis-page-overlay(layer: "background"), foreground: deixis-page-overlay(),
))
#let annotations(body) = deixis-setup-notes(page-overlays: false, [
  #deixis-update-note-counter(0)
  #body
])

// Use a unique key for each logical slide. A callback receives subslide before
// layout; every declaration and consumer uses the same ordinary native label.
#let frame-id(name, frame) = label(repr(("shared-slide", frame, str(name))))
#let shared-note(self: none) = {
  let shared = frame-id(<idea>, self.subslide)
  [
    Consider a #deixis-inset-note(
      id: shared, mark-type: "region", inline: true,
      layer: (mark: "background", body: "foreground"),
      width: 175pt, dx: 300pt, dy: 40pt,
      fill: rgb("e8f3f6"), stroke: rgb("235c70"),
      connector: (route: "curve", ports: (mark: "right", body: "left"), heads: "triangle"),
    )[new idea][One explanation serves both passages on this frame.]

    #v(1em)
    // Touying callbacks control their own visibility.
    #if self.subslide >= 2 [
      A #deixis-mark(of: shared, occurrence: <again>)[related idea]
      #deixis-connect(from: (mark: shared, occurrence: <again>), to: shared,
        connector: (route: "curve", ports: (mark: "right", body: "left"),
          stroke: rgb("235c70"), heads: "triangle"))

      Read #link(shared)[the explanation] or refer to it: #deixis-ref(shared).
    ]
  ]
}

#slide(setting: annotations)[
  #text(size: 25pt, weight: "bold", fill: rgb("235c70"))[One Explanation, Several Passages]
  #v(0.7em)
  #touying-fn-wrapper(shared-note)
  #pause
  #v(1em)
  Both passages keep the same number and body.
]
