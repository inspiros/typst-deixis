#import "../../src/lib.typ": *
#show: deixis-setup-notes
#deixis-mark(id: <n>)[Source]
#deixis-inline-note-body(of: <n>, breakable: false,
  render-single: data => [#deixis-native-render-single(data)#deixis-native-render-single(data)])[Repeated body.]
#deixis-connect(from: <n>, to: <n>)
