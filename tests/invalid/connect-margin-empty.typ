#import "../../src/lib.typ": *
#set page(margin: (x: 100pt, y: 40pt))
#show: deixis-setup-notes
#deixis-margin-note(id: <n>, layer: "background", connector: none,
  render-single: (_, ..args) => [])[Source][Suppressed.]
#deixis-connect(from: <n>, to: <n>)
