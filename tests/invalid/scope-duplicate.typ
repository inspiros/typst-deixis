#import "../../src/lib.typ": *
#show: deixis-setup-notes
#let nested = sys.inputs.at("nested", default: "off") == "on"
#let second() = deixis-block(id: "shared", thread: "reading")[Second.]
#deixis-block(id: <shared>, thread: "reading")[First.#if nested { second() }]
#if not nested { second() }
