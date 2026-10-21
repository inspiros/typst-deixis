/* Exercise our event wiring; native dialog focus containment/Esc belong to the browser. */
const assert = require("node:assert/strict");
const fs = require("node:fs");
const vm = require("node:vm");
const source = fs.readFileSync(process.argv[2], "utf8");

class Element {
    constructor(tag) {
        this.tag = tag;
        this.attrs = {};
        this.events = {};
        this.children = [];
        this.classList = new Set();
    }
    setAttribute(name, value) { this.attrs[name] = value; }
    removeAttribute(name) { delete this.attrs[name]; }
    append(...children) { this.children.push(...children); }
    closest(selector) {
        return selector === "a[href]" ? this.link : this.owner;
    }
    addEventListener(type, handler) { (this.events[type] ||= []).push(handler); }
    fire(type, values = {}) {
        const event = { target: this, preventDefault() { this.prevented = true; }, ...values };
        for (const handler of this.events[type] || []) handler(event);
        return event;
    }
    focus() { document.activeElement = this; }
}
class Dialog extends Element {
    constructor() { super("dialog"); }
    showModal() { this.open = true; }
    close() { this.open = false; this.fire("close"); }
}
function image(path, link) {
    const result = new Element("img");
    result.src = new URL(path, "https://deixis.invalid/typst-deixis/docs/guides/intro.html").href;
    result.alt = "A document figure";
    result.link = link;
    return result;
}
const self = new Element("a");
self.href = "https://deixis.invalid/typst-deixis/docs/assets/figure.svg#page";
self.setAttribute("href", self.href);
const page = new Element("a");
page.href = "https://deixis.invalid/typst-deixis/gallery/first-notes.html";
page.setAttribute("href", page.href);
const bare = image("../assets/figure.svg");
const linked = image("../assets/figure.svg", self);
const card = image("../assets/figure.svg", page);
const owned = image("../assets/figure.svg");
owned.owner = new Element("button");
const document = {
    baseURI: "https://deixis.invalid/typst-deixis/docs/guides/intro.html",
    body: new Element("body"),
    createElement: tag => tag === "dialog" ? new Dialog() : new Element(tag),
    querySelectorAll: selector => {
        assert.equal(selector, "main img");
        return [bare, linked, card, owned];
    }
};
// Unsupported browsers retain readable images and authored links.
vm.runInNewContext(source, { document, URL });
assert.equal(document.body.children.length, 0);
assert.deepEqual(bare.attrs, {});
assert.ok(self.attrs.href);

vm.runInNewContext(source, { document, URL, HTMLDialogElement: Dialog });
const [dialog] = document.body.children;
const [close, enlarged] = dialog.children;
assert.equal(dialog.attrs["aria-label"], "Image zoom");
assert.equal(bare.attrs.role, "button");
assert.equal(bare.tabIndex, 0);
assert.equal(bare.attrs["aria-haspopup"], "dialog");
assert.match(bare.attrs["aria-label"], /A document figure/);
assert.equal(self.attrs.href, undefined);
assert.equal(page.attrs.href, page.href);
assert.deepEqual(page.events, {});
assert.deepEqual(card.attrs, {});
assert.deepEqual(owned.attrs, {});

for (const key of ["Enter", " "]) {
    const event = bare.fire("keydown", { key });
    assert.ok(event.prevented);
    assert.ok(dialog.open);
    assert.equal(enlarged.src, bare.src);
    assert.equal(enlarged.alt, bare.alt);
    assert.equal(document.activeElement, close);
    assert.equal(bare.attrs["aria-expanded"], "true");
    // Native Esc closes the dialog and emits this same close event.
    dialog.close();
    assert.equal(document.activeElement, bare);
    assert.equal(bare.attrs["aria-expanded"], "false");
}
assert.ok(bare.fire("keydown", { key: " ", repeat: true }).prevented);
assert.equal(dialog.open, false);
bare.fire("keydown", { key: "x" });
assert.equal(dialog.open, false);
for (const target of [enlarged, dialog, close]) {
    assert.ok(self.fire("click").prevented);
    assert.ok(dialog.open);
    dialog.fire("click", { target });
    assert.equal(dialog.open, false);
    assert.equal(document.activeElement, self);
}
console.log("Image zoom controls and page navigation passed.");
