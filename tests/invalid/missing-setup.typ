#import "../../src/lib.typ": *
#let feature = sys.inputs.at("feature", default: "pin")
#if feature == "pin" { deixis-pin(<anchor>) }
#if feature == "attach" { deixis-attach(rect(width: 10pt, height: 10pt)) }
#if feature == "mark" { deixis-mark(id: <note>)[Mark] }
#if feature == "body" { deixis-inset-note-body(id: <note>)[Body] }
#if feature == "wrapper" { deixis-margin-note[Mark][Body] }
#if feature == "printer" { deixis-print-endnotes() }
#if feature == "repeat" { deixis-mark(of: <note>)[Again] }
#if feature == "scope" { deixis-block[Content] }
#if feature == "counter" { context deixis-note-counter() }
#if feature == "query" { context deixis-query-notes() }
#if feature == "connect" { deixis-connect(from: (pin: <a>), to: (pin: <b>)) }
#if feature == "scene" { context deixis-routing-scene(nodes: ((pin: <anchor>),)) }

