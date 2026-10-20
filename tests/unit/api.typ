#import "../../src/lib.typ" as deixis
#let names = dictionary(deixis).keys()
#assert(names.all(name => (name.starts-with("deixis-") or name == "short") and not name.starts-with("_")))
#assert("deixis-page-notes" not in names)
#assert("deixis-query-notes" in names)
#assert("deixis-system" not in names)
#assert("deixis-factory-defaults" not in names)
#for name in ("deixis-inline-mark", "deixis-footnote", "deixis-endnote",
  "deixis-margin-note", "deixis-inset-note", "deixis-native-render-single",
  "deixis-margin-note-exact-layout", "deixis-generate-body-meta", "deixis-generate-body-content",
  "deixis-arrowhead", "deixis-render-head", "deixis-mark", "deixis-route", "deixis-prepare-connector") {
  assert(name in names)
}

#assert.eq(type(deixis.short), module)
#assert.eq(deixis.deixis-configure, deixis.deixis-set)
#let aliases = dictionary(deixis.short)
#let expected = (:)
#for (name, value) in dictionary(deixis) {
  if name in ("short", "deixis-configure") { continue }
  let alias = if name == "deixis-set" { "configure" }
    else if name == "deixis-block" { "note-block" }
    else { name.slice("deixis-".len()) }
  expected.insert(alias, value)
}
#assert.eq(aliases.keys().sorted(), expected.keys().sorted())
#for (name, value) in expected { assert.eq(aliases.at(name), value) }
#assert("block" not in aliases and "set" not in aliases)
#assert("deixis-system" not in aliases)
// Native collisions are documented in getting-started and the short docstring.
#assert.eq(aliases.keys().filter(n => n in dictionary(std)).sorted(), ("footnote", "ref"))
#assert.eq(aliases.keys().filter(n => n in dictionary(math)).sorted(), ("arrowhead", "attach"))
