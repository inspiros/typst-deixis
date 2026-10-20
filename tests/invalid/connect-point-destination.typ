#import "../../src/lib.typ": *
#show: deixis-setup-notes
#deixis-endnote(id: <n>)[No painted destination.]
#deixis-print-endnotes(render-group: deixis-native-render-group,
  render-single: data => deixis-generate-body-content(data))
#deixis-connect(from: <n>, to: (body: <n>, point: "end"))
