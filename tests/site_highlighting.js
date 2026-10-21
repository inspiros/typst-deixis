/* Test the authored grammar with mdBook's real bundled engine, without a DOM
 * library. Browser checks cover layout; this checks tokens and source safety.
 */
"use strict";
const assert = require("node:assert/strict");
const fs = require("node:fs");
const vm = require("node:vm");
const bundle = fs.readFileSync(process.argv[2], "utf8");
const grammar = fs.readFileSync(process.argv[3], "utf8");
const context = { document: { querySelectorAll: () => [] } };
vm.createContext(context);
vm.runInContext(bundle, context);
vm.runInContext(grammar, context);
assert(context.hljs.getLanguage("typst"));

function highlight(source) {
    const result = context.hljs.highlight("typst", source, true);
    assert(!result.errorRaised, String(result.errorRaised));
    // Every byte copied from textContent survives markup/escaping unchanged.
    const text = result.value.replace(/<[^>]*>/g, "")
        .replace(/&lt;/g, "<").replace(/&gt;/g, ">")
        .replace(/&quot;/g, '"').replace(/&#x27;/g, "'")
        .replace(/&amp;/g, "&");
    assert.equal(text, source);
    return result.value;
}
function token(source, kind, text) {
    assert(highlight(source).includes('<span class="hljs-' + kind + '">' + text + '</span>'), source);
}
for (const word of ["let", "set", "show", "import", "include", "if", "else", "for", "while", "return", "context"]) {
    token("#" + word + " value", "keyword", word);
}
token("= A Heading", "section", "= A Heading");
token('#let x = "value"', "string", "&quot;value&quot;");
token("// A comment", "comment", "// A comment");
token("/* outer /* inner */ end */", "comment", "/* inner */");
token("<target> @target", "symbol", "&lt;target&gt;");
token("<target> @target", "symbol", "@target");
token("$x + y$", "formula", "$x + y$");
token("```typst\n#let x = 1\n```", "code", "```typst\n#let x = 1\n```");
token("``a ` b``", "code", "``a ` b``");
for (const quantity of ["12pt", "1.5em", "25%", ".5fr", "2e-3cm", "90deg"]) {
    token("#let x = " + quantity, "number", quantity);
}
token("#deixis-note[Hello]", "title", "deixis-note");
token("deixis-note(body: none)", "title", "deixis-note");
token("deixis-note(body: none)", "literal", "none");
token("#let x = {\n let y = true\n y\n}", "literal", "true");
assert(!highlight("Prose with if and for in it.").includes("hljs-keyword"));
highlight('#text[<script> & "quoted" @target]');
highlight("#let unfinished = (\n  \"string");

// The enhancement must neither replace the containing <pre> (and its copy
// button) nor assign anything when the engine fails on a particular block.
function block(source) {
    return { textContent: source, innerHTML: "original", parentNode: { copyButton: true },
             classList: { add: () => {} } };
}
const good = block("#let x = 2pt"), bad = block("broken"), errorResult = block("error-result");
const parent = good.parentNode;
context.document.querySelectorAll = () => [bad, errorResult, good];
const originalHighlight = context.hljs.highlight;
context.hljs.highlight = function (language, source, ...rest) {
    if (source === "broken") throw new Error("Synthetic block failure");
    if (source === "error-result") return { value: "partial", errorRaised: new Error("Bad output") };
    return originalHighlight(language, source, ...rest);
};
vm.runInContext(grammar, context);
assert.equal(bad.innerHTML, "original");
assert.equal(errorResult.innerHTML, "original");
assert(good.innerHTML.includes("hljs-keyword"));
assert.equal(good.parentNode, parent);
assert.equal(good.textContent, "#let x = 2pt");
vm.runInNewContext(grammar, {}); // No highlight.js or DOM: plain source survives.
vm.runInNewContext(grammar, { hljs: { registerLanguage() { throw new Error("No grammar"); } } });
console.log("Typst highlighting, exact copy source and fail-safe checks passed.");
