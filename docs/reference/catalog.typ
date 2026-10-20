// Public API inventory for the compact manual and future website. Signatures
// and argument defaults are parsed from the live runtime sources, never copied.
#import "@preview/tidy:0.4.3"
#import "../../src/lib.typ" as lib
#let groups = json("catalog.json")
#let exports = dictionary(lib).keys()
#let modules = read("../../src/lib.typ").matches(regex("(?m)^#import \"([^\"]+)\""))
#let parsed = ("lib.typ", ..modules.map(m => m.captures.first())).map(m => tidy.parse-module(read("../../src/" + m), scope: dictionary(lib)))
#let functions = parsed.map(m => m.functions + m.variables).flatten().filter(f => f.name in exports)
#let function(name) = functions.find(f => f.name == name)
#let listed = groups.map(g => g.entries.map(e => e.names).flatten()).flatten()
#assert.eq(listed.sorted(), exports.sorted(), message: "The manual inventory must cover every public export exactly once.")
#for name in exports {
  let fn = function(name)
  assert(fn != none, message: name + ": missing parsed source documentation")
  assert(fn.description.trim() != "", message: name + ": empty source documentation")
}
#for group in groups {
  for entry in group.entries {
    assert(entry.setup in ("setup", "free", "conditional", "installs"))
    let fn = function(entry.names.first())
    assert(fn != none, message: entry.names.first())
    for name in entry.args {
      assert(name in fn.at("args", default: (:)), message: fn.name + ": unknown selected parameter " + name)
    }
  }
}
#let default(name, parameter) = function(name).args.at(parameter).at("default", default: none)
#let argument-name(name) = name.trim(".")
