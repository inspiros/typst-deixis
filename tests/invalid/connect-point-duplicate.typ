#import "../../src/lib.typ": *
#show: deixis-setup-notes
#deixis-endnote(id: <n>)[Duplicated.]
#deixis-print-endnotes(render-group: deixis-native-render-group,
  render-single: data => [#deixis-native-render-single(data)#deixis-native-render-single(data)])
#deixis-connect(from: <n>, to: (body: <n>, point: "end"))
