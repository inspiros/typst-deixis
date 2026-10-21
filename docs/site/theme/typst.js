/* A local Typst grammar, written for this book. No network assets are needed.
 * mdBook 0.5.4 loads additional-js after its own highlighting/copy setup.
 * Rehighlight only Typst <code> contents; retain mdBook's <pre> and buttons.
 */
(function () {
    "use strict";

    function typst(hljs) {
        const identifier = "[A-Za-z_][A-Za-z0-9_-]*";
        const keywords = {
            keyword: "let set show import include as if else for in while break continue return context and or not",
            literal: "true false none auto"
        };
        const string = {
            className: "string", begin: /"/, end: /"/,
            contains: [{ begin: /\\[\s\S]/ }]
        };
        const comments = [
            hljs.COMMENT(/\/\//, /$/),
            { className: "comment", begin: /\/\*/, end: /\*\//, contains: ["self"] }
        ];
        const number = {
            className: "number",
            begin: /(?:\b(?:0x[\da-fA-F]+|0b[01]+|0o[0-7]+)|(?:\b\d+(?:\.\d+)?|\.\d+)(?:[eE][+-]?\d+)?)(?:pt|mm|cm|in|em|deg|rad|fr|%)?/
        };
        const label = { className: "symbol", begin: /<[A-Za-z_][A-Za-z0-9_.:-]*>/ };
        const reference = { className: "symbol", begin: /@[A-Za-z_][A-Za-z0-9_.:-]*/ };
        // Match the opening delimiter again, so inline `raw` and fenced raw
        // blocks can contain shorter backtick runs without ending early.
        const raw = hljs.END_SAME_AS_BEGIN({
            className: "code", begin: /(`+)/, end: /(`+)/
        });
        const call = {
            className: "title", begin: new RegExp("\\b" + identifier + "(?=\\s*[\\(\\[])"),
            relevance: 0
        };
        const math = {
            className: "formula", begin: /\$/, end: /\$/,
            contains: [string, ...comments, number, label, reference, { begin: /\\[\s\S]/ }]
        };
        const markup = [];
        const code = [];
        const content = { begin: /\[/, end: /\]/, contains: markup };
        const parentheses = { begin: /\(/, end: /\)/, keywords, contains: code };
        const braces = { begin: /\{/, end: /\}/, keywords, contains: code };
        code.push(string, ...comments, raw, number, label, reference, math,
                  call, parentheses, braces, content);
        const statement = {
            begin: /#(?=(?:let|set|show|import|include|if|else|for|while|return|context|break|continue)\b)/,
            end: /(?=[;\n]|$)/,
            keywords, contains: code
        };
        const expression = {
            begin: /#(?=[A-Za-z_({"])/,
            end: /(?=[^A-Za-z0-9_.(["-]|$)/,
            keywords, contains: code
        };
        markup.push(...comments, raw, statement, expression, label, reference, math,
            { className: "section", begin: /^={1,6}(?=\s)/, end: /$/, contains: [reference, raw] },
            { className: "strong", begin: /\*(?=\S)/, end: /\*/ },
            { className: "emphasis", begin: /_(?=\S)/, end: /_/ },
            { begin: /\\[\s\S]/ },
            // Bare calls and quantities also occur in API signatures and
            // configuration fragments, which intentionally omit markup '#'.
            call, string, number, parentheses);
        return { name: "Typst", aliases: ["typ"], contains: markup };
    }

    try {
        if (typeof hljs === "undefined" || typeof hljs.registerLanguage !== "function") return;
        hljs.registerLanguage("typst", typst);
        if (!hljs.getLanguage("typst")) return;
        document.querySelectorAll("pre code.language-typst, pre code.lang-typst").forEach(function (block) {
            try {
                const source = block.textContent;
                const result = typeof hljs.highlightElement === "function"
                    ? hljs.highlight(source, { language: "typst", ignoreIllegals: true })
                    : hljs.highlight("typst", source, true);
                // Only replace the source after highlighting succeeds. Escaping
                // is performed by highlight.js, including literal HTML in code.
                if (result && typeof result.value === "string" && !result.errorRaised) {
                    block.innerHTML = result.value;
                    block.classList.add("hljs");
                }
            } catch (_) { /* A broken block must remain readable and copyable. */ }
        });
    } catch (_) { /* Plain source remains usable if registration is unavailable. */ }
})();
