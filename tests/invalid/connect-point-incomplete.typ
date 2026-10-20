#import "../../src/lib.typ": *
#show: deixis-setup-notes
#deixis-endnote(id: <n>)[Incomplete span.]
#deixis-print-endnotes(render-group: deixis-native-render-group,
  render-single: data => [#deixis-generate-body-meta(data)#metadata(data)<deixis-rendered-start>#data.body])
#deixis-connect(from: <n>, to: (body: <n>, point: "start"))
