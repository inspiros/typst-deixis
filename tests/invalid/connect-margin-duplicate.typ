#import "../../src/lib.typ": *
#set page(margin: (x: 100pt, y: 40pt))
#show: deixis-setup-notes
#deixis-mark(id: <n>, mark-type: "phantom")
#deixis-margin-note-body(of: <n>, connector: none,
  render-single: (data, ..args) => [#deixis-native-render-single(data)#deixis-native-render-single(data)])[Duplicated.]
#deixis-connect(from: <n>, to: <n>)
