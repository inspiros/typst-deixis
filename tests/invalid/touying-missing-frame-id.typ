#import ("@preview/touying:" + sys.inputs.at("touying-version", default: "0.8.0")): *
#import themes.simple: simple-theme, slide
#import "../../src/lib.typ": *
#show: simple-theme
#let note(self: none) = {
  let id = label("test/frame/" + str(self.subslide) + "/shared")
  deixis-endnote-body(of: id)[Body]
  // The second frame's original cannot satisfy the first frame's attachment.
  if self.subslide >= 2 { deixis-mark(id: id)[Original] }
}
#slide(setting: body => deixis-setup-notes(page-overlays: false, body))[
  #touying-fn-wrapper(note)
  #pause
  Second frame.
]
