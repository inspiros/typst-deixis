/* Progressive enhancement: keep page links, zoom bare images and image links. */
(function () {
    "use strict";

    if (typeof HTMLDialogElement === "undefined" ||
        typeof HTMLDialogElement.prototype.showModal !== "function") return;

    const dialog = document.createElement("dialog");
    dialog.className = "deixis-image-zoom";
    dialog.id = "deixis-image-zoom";
    dialog.setAttribute("aria-label", "Image zoom");
    const close = document.createElement("button");
    close.type = "button";
    close.className = "deixis-image-zoom-close";
    close.textContent = "Close zoom (Esc)";
    close.setAttribute("aria-label", "Close image zoom");
    const enlarged = document.createElement("img");
    enlarged.draggable = false;
    dialog.append(close, enlarged);
    document.body.append(dialog);

    let opener;
    function imageURL(url) {
        const target = new URL(url, document.baseURI);
        target.hash = "";
        return target.href;
    }
    // Native modal dialogs supply focus containment, inert background and Esc.
    dialog.addEventListener("click", function (event) {
        if (event.target === dialog || event.target === enlarged || event.target === close) {
            dialog.close();
        }
    });
    dialog.addEventListener("close", function () {
        if (opener) {
            opener.setAttribute("aria-expanded", "false");
            opener.focus({ preventScroll: true });
        }
        enlarged.removeAttribute("src");
    });

    document.querySelectorAll("main img").forEach(function (image) {
        const link = image.closest("a[href]");
        // Resolve relative URLs against the page, including project subpaths.
        if (link && imageURL(link.href) !== imageURL(image.src) &&
            (!image.currentSrc || imageURL(link.href) !== imageURL(image.currentSrc))) return;
        // Preserve any other interactive owner (e.g. an authored button).
        if (image.closest("button, [role='button']")) return;
        const trigger = link || image;
        if (link) link.removeAttribute("href");
        trigger.classList.add("deixis-zoomable");
        trigger.tabIndex = 0;
        trigger.setAttribute("role", "button");
        trigger.setAttribute("aria-label", "Zoom image: " + (image.alt || "Document figure"));
        trigger.setAttribute("aria-haspopup", "dialog");
        trigger.setAttribute("aria-controls", dialog.id);
        trigger.setAttribute("aria-expanded", "false");

        function open(event) {
            event.preventDefault();
            if (dialog.open) return;
            opener = trigger;
            enlarged.src = image.currentSrc || image.src;
            enlarged.alt = image.alt;
            trigger.setAttribute("aria-expanded", "true");
            dialog.showModal();
            close.focus({ preventScroll: true });
        }
        trigger.addEventListener("click", open);
        trigger.addEventListener("keydown", function (event) {
            if (event.key === "Enter" || event.key === " ") {
                event.preventDefault();
                if (!event.repeat) open(event);
            }
        });
    });
})();
