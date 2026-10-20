#import ("@preview/touying:" + sys.inputs.at("touying-version", default: "0.8.0")): *
#import themes.simple: simple-theme, slide
#import "../../src/lib.typ": *
#show: simple-theme
#slide(setting: body => deixis-setup-notes(page-overlays: false, body))[
  Literal IDs remain document-wide, even in different rendered frames.
  #deixis-mark(id: <shared>)[Original]
  #pause
  Second frame.
]
