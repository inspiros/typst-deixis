#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let option = sys.inputs.at("option", default: "id")
#let value = (empty: "", number: 1, boolean: false, array: (), dictionary: (:),
  content: [name], "none": none, reserved: "page", reserved-label: <page>).at(sys.inputs.at("value", default: "empty"))
#{
  if option == "thread" { deixis-block(thread: value)[Invalid thread.] }
  else if option == "filter" { context deixis-query-notes(thread: value) }
  else { deixis-minipage(id: value)[Invalid block ID.] }
}
