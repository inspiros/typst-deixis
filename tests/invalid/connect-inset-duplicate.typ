#import "../../src/lib.typ": *
#show: deixis-setup-notes
#deixis-mark(id: <n>, mark-type: "phantom")
#deixis-inset-note-body(of: <n>, connector: none, dx: 30pt, dy: 30pt,
  render-single: (data, ..args) => [#deixis-native-render-single(data)#deixis-native-render-single(data)])[Duplicated.]
#deixis-connect(from: <n>, to: <n>)
