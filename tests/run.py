#!/usr/bin/env python3
"""Compile checkout fixtures/examples and verify behavior against structured output."""

import argparse
from collections import Counter
from concurrent.futures import ThreadPoolExecutor
import json
import math
import os
from pathlib import Path
import subprocess
import sys
import tomllib
import re
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--typst", default="typst")
    parser.add_argument("--manual", action="store_true", help="Also check the manual and its isolated worked examples.")
    parser.add_argument("--filter", action="append", default=[], metavar="GLOB",
                        help="Run matching source paths only; repeat for a union of globs.")
    parser.add_argument("--jobs", type=int, default=max(1, (os.cpu_count() or 2) // 2),
                        help="Sources checked concurrently (default: half the CPUs).")
    args = parser.parse_args()
    sources = sorted((ROOT / "tests").glob("**/*.typ")) + sorted((ROOT / "examples").glob("*.typ"))
    if args.manual:
        sources.append(ROOT / "docs/manual.typ")
        sources.extend(sorted((ROOT / "docs/examples").glob("*.typ")))
    if args.filter:
        sources = [s for s in sources if any(s.relative_to(ROOT).match(pattern) for pattern in args.filter)]
        if not sources:
            parser.error("No maintained sources match --filter.")
    out = ROOT / "target/tests"
    out.mkdir(parents=True, exist_ok=True)
    subprocess.run([sys.executable, ROOT / "scripts/install.py", "--namespace", "preview",
                    "--data-dir", out / "package-data", "--reinstall"], check=True, capture_output=True)
    packages = out / "package-data/typst/packages"
    base = [args.typst, "--root", str(ROOT), "--package-path", str(packages)]

    def typst(command, *arguments):
        result = subprocess.run([base[0], command, *base[1:], *map(str, arguments)],
                                cwd=ROOT, text=True, capture_output=True, timeout=120)
        if result.returncode or result.stderr:
            raise AssertionError(f"{command} {' '.join(map(str, arguments))}\n{result.stderr or result.stdout}")
        return result.stdout

    def values(source, selector="<test-result>"):
        return json.loads(typst("eval", "--in", source, "--format", "json",
                                f"query({selector}).map(it => it.value)"))

    expected_errors = {
        "numbering-record": "numbering record must be",
        "omission-reference": "is omitted by deixis-set",
        "omission-explicit-reference": "is omitted by deixis-set",
        "omission-policy": "omit must be none or",
        "omission-duplicate": "Duplicate note ID",
        "local-table-declarations": "deixis:",
        "collected-routing": "deixis:",
        "collected-ports": "Collected routing failed",
        "routing-policy": "Routing policy must be manual, avoid or separate",
        "routing-note-policy": "deixis:", "routing-nodes": "deixis:",
        "routing-wrapper-owner": "endpoint-blocked",
        "continuation-style": "connector.continuation",
        "palette": "palette must be none or",
        "spill-regions": "connector.spill", "spill-scope": "Automatic margin spill needs", "spill-blocked": "deixis:",
        "missing-setup": "must wrap your document",
        "helper-page": "physical page integer",
        "query-order": "Query order must be",
        "z-index": "invalid value", "z-footnote-group": "atomic footnote column requires matching z-index",
        "z-margin-group": "atomic custom margin batch requires matching z-index",
        "duplicate-id": "Duplicate note ID", "duplicate-body": "only one body",
        "body-destination-duplicate": "emitted more than one destination",
        "touying-duplicate-id": "Duplicate note ID",
        "touying-missing-frame-id": "of must name an original mark",
        "block-footnote-layer": "Invalid value",
        "scope-name": "must be a nonempty string or label",
        "scope-duplicate": "Duplicate block ID",
        "scope-unknown": "Unknown scope target",
        "mixed-scope": "cannot mix", "layer": "Invalid value",
        "overlay-footnote": "taller than a page",
        "target": "Target must be", "id": "note ID must be",
        "counter-cycle": "Cyclic counter synchronization",
        "counter-update-float": "counter update must be an integer or a function",
        "counter-update-string": "counter update must be an integer or a function",
        "counter-update-bool": "counter update must be an integer or a function",
        "counter-result-float": "update result must be an integer",
        "counter-result-string": "update result must be an integer",
        "counter-result-bool": "update result must be an integer",
        "counter-result-none": "update result must be an integer",
        "counter-read-series": "counter series must be a string",
        "counter-update-series": "counter series must be a string",
        "counter-mark-series": "counter series must be a string",
        "counter-read-setup": "must wrap your document",
        "head-renderer": "must return body, trim, and bounds",
        "waypoint-anchor": "Invalid waypoint anchor",
        "port-position": "Port at must be",
        "flow-region": "cannot render multi-page region",
        "repeat-missing": "must name an original mark",
        "repeat-standalone": "must name an original mark",
        "repeat-forward-standalone": "must name an original mark",
        "pin-name": "public pin name must be",
        "pin-extra": "cannot replace reserved fields",
        "pin-coordinate": "pin coordinates must be",
        "pin-option": "unknown pin option",
        "pin-padding": "percentages have no pin-size basis",
        "pin-padding-edge": "unknown annotation padding edge",
        "pin-pattern": "exactly one capture",
        "pin-anchor": "anchor/offset or dx/dy",
        "pin-scope": "pin scope must be",
        "pin-selector": "pin select must be",
        "pin-target-field": "unknown pin target field",
        "pin-page": "pin page must be",
        "pin-missing": "no pin matches",
        "pin-ambiguous": "ambiguous pin target",
        "pin-single": "needs one occurrence",
        "pin-flow-page": "no pin matches",
        "note-option": "unknown note option",
        "container-flat": "put native/custom container options in container-args",
        "container-options": "container-args must be a dictionary",
        "container-style": "outside container-args",
        "container-inline": "container-args requires inline: false",
        "pin-padding-map": "legacy per-name padding map",
        "connection-layer": "connector.layer must be",
        "occurrence-name": "occurrence must be",
        "occurrence-duplicate": "duplicate occurrence",
        "connect-selector": "connection mark selector must be",
        "connect-id": "endpoint ID must be",
        "connect-missing": "unknown connection mark target",
        "hidden-connection-missing": "unknown connection mark target",
        "connect-occurrence": "unknown connection occurrence",
        "connect-hidden": "no drawable mark frame",
        "connect-body": "require a margin, inset, or framed inline body",
        "connect-fragments": "needs one painted frame",
        "connect-source": "no drawable mark frame",
        "connect-inline-unframed": "needs one painted frame",
        "connect-inline-empty": "needs one painted frame",
        "connect-inline-duplicate": "needs one painted frame",
        "connect-inset-columns": "needs one painted frame",
        "connect-inset-empty": "needs one painted frame",
        "connect-inset-duplicate": "needs one painted frame",
        "connect-margin-empty": "needs one painted frame",
        "connect-margin-duplicate": "needs one painted frame",
        "inline-breakable": "must be a boolean",
        "connect-point-option": "body point must be",
        "connect-point-unprinted": "requires one complete live body span",
        "connect-point-duplicate": "requires one complete live body span",
        "connect-point-incomplete": "requires one complete live body span",
        "connect-point-destination": "requires one complete live body span",
        "connect-point-source": "connection mark selector must be",
        "connect-pin-missing": "no pin matches",
        "connect-pin-ambiguous": "ambiguous pin target",
        "connect-pin-multiple": "needs one occurrence",
        "connect-pin-selector": "accepts only pin",
        "connect-pin-port-missing": "no pin matches",
        "connect-pin-port-page": "on physical page",
        "connect-pin-waypoint-missing": "no pin matches",
        "connect-pin-waypoint-page": "on physical page",
        "connect-pin-offset": "offset needs two lengths",
        "connect-pin-gap": "gap needs an explicit side",
        "connect-pin-side": "pin port side must be",
        "connect-pin-option": "a routing pin accepts",
        "reuse-id": "use id or of, not both",
        "reuse-counter": "inherit numbering, scope target, and series",
        "reuse-occurrence": "occurrence requires of",
        "reuse-target": "use named id or of",
        "reuse-of": "of must be a nonempty",
        "attachment-id": "use id or of, not both",
        "attachment-content": "attached wrapper accepts only",
        "attachment-mark-options": "original-mark option(s)",
        "phantom-arguments": "Unknown phantom mark argument(s)",
        "comment-of": "deixis-comment creates an original",
        "attachment-series": "attached bodies inherit their original's series",
        "body-series": "body series must be auto or a string",
        "collection-filter": "must be",
        "collection-boundary": "no document element matches",
        "collection-boundary-type": "Collection boundary",
        "margin-overflow": "exceeds its margin frame",
        "margin-overflow-option": "invalid value",
        "gap-marks": "deixis: gap-marks",
        "connector-cuts": "deixis: connector.cuts",
        "automatic-crossings": "deixis: connector.crossings",
        "route-settings": "deixis: connector.route",
        "control-curves": "deixis: connector.route",
        "hobby": "deixis: connector.route",
        "numeric-routing": "numeric routing",
        "routing-scene": "routing", "route-group": "Routing group", "continuation": "connector.continuation", "document-scenes": "Document scene",
        "connector-scenes": "deixis: connector.scene",
        "scene-port-selection": "endpoint-blocked",
        "continuation-allocation": "endpoint-blocked",
        "continuation-counterparts": "continuation counterpart needs one accepted opposite fragment",
        "outline-options": "outline group-by must be",
        "query-unpaired": "include-unpaired must be",
        "query-setup": "must wrap your document",
        "note-data": "annotation data must be a dictionary",
        "configuration-callback": "invalid value",
        "configuration-nodes": "cannot mix",
        "printer-callback": "override must be auto or a function",
        "native-styles": "text-fill requires a single stroke",
        "sidenote-scope": "sidenote is a margin-note preset",
        "attachment-duplicate": "only one body",
        "identity-mark-wrapper": "duplicate note ID",
        "identity-wrapper-mark": "duplicate note ID",
        "identity-standalone": "duplicate note ID",
        "footnote-unallocated": "no native footer allocation",
        "footnote-float-allocation": "parent-scope floats",
        "removed-label": "label was removed",
        "removed-link": "was removed in 0.2; use connector",
        "removed-link-component": "link component was renamed",
        "removed-body-label": "label was removed",
        "mark-positional": "use named id or of",
        "mark-conflict": "use id or of",
        "mark-counter": "inherit numbering, scope target, and series",
        "mark-occurrence": "occurrence requires of",
        "mark-region-option": "region options require a region mark",
        "mark-phantom-passage": "phantom marks accept no passage",
        "attachment-missing": "of must name an original mark",
        "attachment-standalone": "of must name an original mark",
        "attachment-forward-standalone": "duplicate note ID",
        "identity-body-mark": "duplicate note ID",
        "identity-empty": "ID must be a nonempty",
        "repeat-region-content": "requires either pins or one",
        "repeat-region-options": "region options require a region repeat",
        "repeat-phantom-appearance": "phantom repeats accept no passage or appearance",
        "repeat-region-counter": "inherit numbering, scope target, and series",
        "repeat-kinds-duplicate": "duplicate occurrence",
        "repeat-region-flow": "cannot render multi-page region",
    }

    failures = []
    def check(source):
        name = source.relative_to(ROOT).as_posix()
        try:
            pdf = out / (name.replace("/", "-") + ".pdf")
            if source.parent.name == "invalid":
                inputs = [()]
                if source.stem in ("touying-duplicate-id", "touying-missing-frame-id"):
                    inputs = [("--input", f"touying-version={version}") for version in ("0.8.0", "0.6.3")]
                elif source.stem == "local-table-declarations":
                    inputs = [("--input", f"mode={mode}") for mode in ("original", "body", "occurrence", "scope")]
                elif source.stem == "palette":
                    inputs = [("--input", f"mode={mode}") for mode in ("empty", "none-entry", "mixed", "map", "bool", "scalar", "name")]
                elif source.stem == "spill-regions":
                    inputs = [("--input", f"mode={mode}") for mode in
                              ("type", "name", "key", "missing", "coordinate", "infinite", "reversed", "empty", "outside")]
                elif source.stem == "scope-name":
                    inputs = [("--input", f"option={option}", "--input", f"value={value}")
                              for option in ("id", "thread", "filter")
                              for value in ("empty", "number", "boolean", "array", "dictionary", "content", "none")
                              if not (option == "thread" and value == "none")]
                    inputs += [("--input", "value=reserved"), ("--input", "value=reserved-label")]
                elif source.stem == "missing-setup":
                    inputs = [("--input", f"feature={feature}") for feature in
                              ("pin", "attach", "mark", "body", "scope", "counter", "query", "connect", "scene")]
                elif source.stem == "helper-page":
                    inputs = [("--input", f"consumer={consumer}", "--input", f"sample={sample}")
                              for consumer in ("query",)
                              for sample in ("zero", "negative", "fractional", "boolean", "string", "missing", "array", "label", "infinite")]
                elif source.stem == "query-order":
                    inputs = [("--input", f"sample={sample}") for sample in
                              ("unknown", "missing", "boolean", "array", "integer", "callback")]
                elif source.stem == "scene-port-selection":
                    inputs = [("--input", f"constraint={constraint}") for constraint in ("source", "target", "pin", "side")]
                elif source.stem == "scope-duplicate":
                    inputs = [("--input", f"nested={value}") for value in ("off", "on")]
                elif source.stem == "scope-unknown":
                    inputs = [("--input", f"kind={kind}", "--input", f"label={label}")
                              for kind in ("mark", "region", "phantom", "counter", "sync", "printer",
                                           "inline", "footnote", "endnote", "margin", "inset")
                              for label in ("off", "on")]
                elif source.stem == "body-destination-duplicate":
                    inputs = [("--input", f"mode={mode}", "--input", f"kind={kind}", "--input", f"standalone={standalone}")
                              for mode in ("meta", "marker", "renderer")
                              for kind in ("inset", "footnote", "endnote") for standalone in ("off", "on")]
                elif source.stem == "footnote-float-allocation":
                    inputs = [("--input", f"layer={layer}", "--input", f"kind={kind}", "--input", f"placement={placement}")
                              for layer in ("flow", "foreground", "background")
                              for kind in ("wrapper", "standalone", "attached")
                              for placement in ("top", "bottom")]
                elif source.stem == "z-index":
                    inputs = [("--input", f"kind={kind}", "--input", f"sample={sample}")
                              for kind in ("mark", "inline-mark", "region-mark", "phantom-mark", "inline",
                                           "endnote-body", "footnote-body", "margin-body", "inset-body",
                                           "endnote", "footnote", "margin", "inset", "sidenote", "config", "connector")
                              for sample in ("float", "bool", "none", "string")]
                elif source.stem == "attachment-mark-options":
                    inputs = [("--input", f"kind={kind}", "--input", f"option={option}")
                              for kind in ("footnote", "endnote", "margin", "inset", "sidenote")
                              for option in ("numbering", "series", "marker", "mark-type", "marker-position",
                                             "inline-mode", "pins", "padding", "region-shape", "inline")]
                    inputs.append(("--input", "kind=endnote", "--input", "option=layer"))
                    # Inline-note inline/inline-mode style the attached body itself.
                    inputs += [("--input", "kind=inline", "--input", f"option={option}")
                               for option in ("numbering", "series", "marker", "mark-type", "marker-position",
                                              "pins", "padding", "region-shape", "layer")]
                elif source.stem in ("attachment-series", "body-series"):
                    inputs = [("--input", f"kind={kind}")
                              for kind in ("inline", "footnote", "endnote", "margin", "inset", "sidenote")]
                elif source.stem == "margin-overflow":
                    inputs = [("--input", f"layer={layer}", "--input", f"mode={mode}", "--input", f"form={form}")
                              for layer in ("flow", "foreground", "background")
                              for mode in ("tall", "wide", "above", "negative", "block")
                              for form in ("attached", "standalone", "wrapper")]
                    inputs += [("--input", "mode=custom", "--input", f"layer={layer}")
                               for layer in ("foreground", "background")]
                elif source.stem == "margin-overflow-option":
                    inputs = [("--input", f"form={form}", "--input", f"value={value}")
                              for form in ("settings", "wrapper", "body")
                              for value in ("unknown", "boolean", "integer")]
                elif source.stem == "gap-marks":
                    inputs = [("--input", f"form={form}", "--input", f"mode={mode}")
                              for form in ("explicit", "margin", "inset")
                              for mode in ("shape", "type", "key", "size", "zero", "negative")]
                elif source.stem == "connector-cuts":
                    inputs = [("--input", f"form={form}", "--input", f"mode={mode}")
                              for form in ("explicit", "margin", "inset")
                              for mode in ("type", "item", "unknown", "missing", "mixed", "coordinate", "relative",
                                           "negative", "zero", "negative-length", "empty")]
                elif source.stem == "continuation-style":
                    inputs = [("--input", f"mode={mode}") for mode in
                              ("shape", "type", "key", "zero", "negative", "ratio", "link", "legacy")]
                elif source.stem == "continuation-allocation":
                    inputs = [("--input", f"mode={mode}") for mode in ("closed", "fixed", "budget", "expansions", "waypoint", "real-endpoint", "no-path")]
                elif source.stem == "connector-scenes":
                    inputs = [("--input", f"mode={mode}") for mode in (
                        "type", "tag", "callback", "legacy", "curve", "rounded", "radius-auto", "mixed", "radius", "endpoint",
                        "waypoint", "no-path", "budget", "owner", "padding", "foreign", "interior", "continuation")]
                    inputs += [("--input", f"form={form}", "--input", f"mode={mode}")
                               for form in ("margin", "inset") for mode in ("type", "callback", "legacy", "curve", "rounded")]
                elif source.stem == "document-scenes":
                    inputs = [("--input", f"mode={mode}") for mode in (
                        "selector-mix", "literal-mix", "field", "occurrence-field", "missing", "mark-missing", "occurrence",
                        "empty-mark", "body-page", "mark-page", "page-zero", "page-none", "page-bool", "point",
                        "body-unprinted", "body-collected", "body-unframed", "pin-missing", "pin-ambiguous", "pin-page",
                        "pins-type", "pins-empty", "pins-pages", "region-page", "region-outside", "padding", "hidden-padding",
                        "padding-key", "padding-reversed", "point-avoid", "setup")]
                elif source.stem == "routing-policy":
                    inputs = [("--input", f"mode={mode}") for mode in (
                        "unknown", "none", "auto", "number", "record", "label")]
                elif source.stem == "routing-nodes":
                    inputs = [("--input", f"mode={mode}", "--input", f"policy={policy}")
                              for mode in ("type", "item", "mix", "field", "behavior", "id", "point", "padding",
                                           "padding-key", "pin", "pins", "page", "unpaged", "bounds", "count")
                              for policy in ("manual", "avoid", "separate")]
                    inputs += [("--input", f"mode={mode}", "--input", f"policy={policy}")
                               for mode in ("missing", "unframed", "owner-padding", "duplicate", "foreign")
                               for policy in ("avoid", "separate")]
                elif source.stem == "routing-note-policy":
                    inputs = [("--input", f"kind={kind}", "--input", f"mode={mode}")
                              for kind in ("margin", "inset") for mode in ("curve", "radius", "mixed", "scene")]
                elif source.stem == "collected-ports":
                    inputs = [("--input", f"mode={mode}") for mode in (
                        "fixed-point", "fixed-side", "fixed-pin", "visit", "fixed-split")]
                elif source.stem == "collected-routing":
                    inputs = [("--input", f"mode={mode}") for mode in (
                        "missing", "duplicate", "node-page", "node-field", "id", "behavior", "spacing", "budget",
                        "curve", "radius", "mixed", "scene", "count", "zero", "setup")]
                elif source.stem == "route-group":
                    inputs = [("--input", f"mode={mode}") for mode in (
                        "edges-type", "edges-count", "edge-type", "edge-missing", "edge-key", "id-type", "id-empty", "duplicate",
                        "spacing-zero", "spacing-font", "spacing-percent", "spacing-inf", "weight-negative", "weight-bool", "weight-inf", "weight-nan",
                        "detour-negative", "detour-type", "detour-inf", "rounds-type", "rounds-range", "searches", "expansions", "scene",
                        "via-type", "via-switch", "via-font", "normal", "owner-boundary", "endpoint-junction", "page-cross", "page-conflict", "page-missing", "overflow")]
                elif source.stem == "routing-scene":
                    inputs = [("--input", f"mode={mode}") for mode in (
                        "nodes-type", "nodes-count", "node-type", "node-key", "node-missing", "behavior", "id", "duplicate", "node-page",
                        "bounds-type", "bounds-key", "bounds-reverse", "bounds-font", "bounds-inf", "clearance", "escape", "cost", "limit",
                        "pages-type", "pages-missing", "pages-key", "pages-id", "pages-duplicate", "scene-tag", "missing-id",
                        "endpoint-key", "side", "at", "owner-normal", "owner-boundary", "normal", "page-type", "page-missing",
                        "page-conflict", "page-cross", "route", "radius", "via-switch", "sections", "prepare-failure")]
                elif source.stem == "numeric-routing":
                    inputs = [("--input", f"mode={mode}", "--input", f"form={form}")
                              for mode in ("point-type", "point-short", "point-long", "point-unitless", "point-percent", "point-font", "point-inf")
                              for form in ("from", "to", "via", "control", "section-control")]
                    inputs += [("--input", f"mode={mode}", "--input", f"form={form}")
                               for mode in ("normal-zero", "normal-unit", "normal-bool", "normal-nan", "normal-inf", "normal-short", "normal-long", "normal-center", "normal-corner", "normal-none")
                               for form in ("from", "to")]
                    inputs += [("--input", f"mode={mode}") for mode in
                               ("radius-negative", "radius-font", "radius-percent", "radius-auto", "radius-inf", "both", "via-type", "via-pin", "via-frame", "via-split",
                                "endpoint-key", "endpoint-missing", "endpoint-pin", "endpoint-type", "route-auto", "route-callback", "route-invalid", "route-record",
                                "segment-type", "segment-key", "segment-via", "segment-callback", "diagonal", "diagonal-end", "prepare", "prepare-incomplete")]
                elif source.stem == "hobby":
                    modes = ("low", "zero", "negative", "infinite", "nan", "length", "ratio", "boolean", "string", "tension-auto",
                             "curl-negative", "curl-infinite", "curl-nan", "curl-type", "curl-boolean", "curl-length",
                             "curl-ratio", "curl-auto", "curl-array", "curl-key", "curl-mark", "curl-body", "controls",
                             "parameterization", "close", "degree", "wrong-family")
                    inputs = [("--input", f"form={form}", "--input", f"mode={mode}")
                              for form in ("explicit", "margin", "inset", "settings", "segments", "via") for mode in modes]
                    inputs += [("--input", "mode=numeric")]
                elif source.stem == "control-curves":
                    inputs = [("--input", f"form={form}", "--input", f"mode={mode}")
                              for form in ("explicit", "margin", "inset", "settings", "segments", "via")
                              for mode in ("type", "scalar", "item", "string", "short", "long", "coordinate", "switch",
                                           "key", "offset", "offset-type", "frame", "anchor", "previous", "tension", "policy",
                                           "degree", "knots", "pin-name", "pin-offset", "pin-missing", "pin-page",
                                           "pin-multiple", "pin-ambiguous", "waypoints")
                              if not (mode == "waypoints" and form in ("segments", "via"))]
                elif source.stem == "route-settings":
                    inputs = [("--input", f"form={form}", "--input", f"mode={mode}")
                              for form in ("explicit", "margin", "inset", "settings", "segments", "via")
                              for mode in ("missing", "empty", "unknown", "kind", "key", "radius", "inapplicable", "disabled",
                                           "policy", "alias", "parameterization", "policy-type", "zero", "negative", "infinite",
                                           "nan", "underflow", "length", "ratio", "boolean", "auto")
                              if not (form == "via" and mode in ("missing", "empty"))]
                elif source.stem == "automatic-crossings":
                    inputs = [("--input", f"mode={mode}") for mode in
                              ("shape", "type", "key", "mode", "group", "empty", "ratio", "zero", "negative",
                               "precision", "legacy")]
                elif source.stem == "collection-boundary-type":
                    inputs = [("--input", f"consumer={consumer}", "--input", f"option={option}",
                               "--input", f"value={value}")
                              for consumer in ("printer", "outline", "query") for option in ("after", "before")
                              for value in ("integer", "boolean", "array", "content", "fraction", "auto")]
                elif source.stem == "collection-filter":
                    inputs = [("--input", f"consumer={consumer}", "--input", f"option={option}",
                               "--input", f"sample={sample}")
                              for consumer, option in (("printer", "series"), ("outline", "series"),
                                                       ("outline", "include-types"), ("outline", "exclude-types"),
                                                       ("query", "include-types"), ("query", "series"), ("outline", "thread"))
                              for sample in ("scalar", "array")]
                    inputs.append(("--input", "consumer=outline", "--input", "option=exclude-types", "--input", "sample=auto"))
                elif source.stem == "collection-boundary":
                    inputs = [("--input", f"consumer={consumer}") for consumer in ("printer", "outline")]
                elif source.stem == "outline-options":
                    inputs = [("--input", f"option={option}", "--input", f"sample={sample}")
                              for option, samples in (("group-by", ("unknown", "array", "bool", "callback")),
                                                       ("include-unpaired", ("unknown", "array", "none")),
                                                       ("include-celibates", ("bool",)))
                              for sample in samples]
                elif source.stem == "note-data":
                    inputs = [("--input", f"kind={kind}", "--input", f"mode={mode}")
                              for kind in ("mark", "inline-mark", "region-mark", "phantom-mark",
                                           "inline", "footnote-body", "endnote-body", "margin-body",
                                           "inset-body", "sidenote-body", "footnote", "endnote",
                                           "margin", "inset", "sidenote")
                              for mode in ("type", "inherit")]
                    inputs.append(("--input", "kind=phantom-mark", "--input", "mode=anonymous"))
                elif source.stem == "configuration-callback":
                    inputs = [("--input", f"option={option}", "--input", f"sample={sample}")
                              for option in ("render-single", "render-group", "container-func",
                                             "body-style", "marker-style", "region-shape")
                              for sample in ("number", "dictionary", "none")]
                    inputs += [("--input", "option=marker-style", "--input", f"sample={sample}",
                                "--input", "body=inline") for sample in ("number", "dictionary", "none")]
                elif source.stem == "printer-callback":
                    inputs = [("--input", f"option={option}") for option in
                              ("render-single", "render-group", "container-func", "body-style", "marker-style")]
                elif source.stem == "native-styles":
                    inputs = [("--input", f"mode={mode}") for mode in
                              ("text-fill", "margin-stroke", "inset-stroke", "radius", "independent")]
                elif source.stem == "removed-link-component":
                    inputs = [("--input", f"form={form}") for form in ("note", "settings", "z-index")]
                elif source.stem == "removed-link":
                    inputs = [("--input", f"form={form}", "--input", f"option={option}")
                              for form in ("margin", "margin-body", "inset", "inset-body", "sidenote")
                              for option in ("link", "link-ports", "link-waypoints", "link-marks", "link-heads")]
                elif source.stem == "sidenote-scope":
                    inputs = [("--input", f"mode={mode}") for mode in ("global", "nested", "local")]
                for flags in inputs:
                    result = subprocess.run([base[0], "compile", *base[1:], *flags, str(source), str(pdf)],
                                            cwd=ROOT, capture_output=True, text=True, timeout=30)
                    expected = expected_errors[source.stem]
                    if source.stem == "collected-routing":
                        mode = next(flag.removeprefix("mode=") for flag in flags if flag.startswith("mode="))
                        expected = {
                            "missing": "must select one instance", "duplicate": "Duplicate attached node ID",
                            "node-page": "endpoint page must be", "node-field": "endpoint accepts node, scope and page",
                            "id": "public pin name must be", "behavior": "Attached node behavior",
                            "spacing": "Routing group spacing", "budget": "Collected routing failed",
                            "curve": "Collected routing requires sharp orthogonal", "radius": "Collected routing requires sharp orthogonal",
                            "mixed": "Collected routing requires sharp orthogonal", "scene": "connector.scene is only available outside",
                            "count": "at most sixteen connections", "zero": "Routing scene bounds need",
                            "setup": "must wrap your document",
                        }[mode]
                    if source.stem == "route-group":
                        mode = next(flag.removeprefix("mode=") for flag in flags if flag.startswith("mode="))
                        expected = {
                            "scene": "must come from deixis-routing-scene", "via-switch": "points need two finite absolute lengths",
                            "via-font": "points need two finite absolute lengths", "normal": "needs cardinal endpoint normals",
                            "owner-boundary": "must lie on its node boundary", "endpoint-junction": "numeric routing endpoint",
                            "page-cross": "connects one page plane", "page-conflict": "connects one page plane",
                            "page-missing": "page is absent from the scene",
                        }.get(mode, expected)
                    if source.stem == "numeric-routing":
                        mode = next(flag.split("=", 1)[1] for flag in flags if flag.startswith("mode="))
                        form = next((flag.split("=", 1)[1] for flag in flags if flag.startswith("form=")), "from")
                        expected = {"via-type": "Numeric routing via must be an array", "via-pin": "Numeric routing points need",
                                    "via-frame": "Numeric routing points need", "via-split": "connector.route has an unknown kind",
                                    "both": "Use numeric routing via or segments", "route-invalid": "connector.route has an unknown kind",
                                    "route-record": "connector.route needs a string kind", "segment-type": "connector.segments must be an array",
                                    "segment-key": "A connector segment accepts route and via", "segment-via": "segment via must be an array",
                                    "segment-callback": "Numeric routing requires a native route", "route-auto": "Numeric routing requires a native route",
                                    "route-callback": "Numeric routing requires a native route", "prepare": "geometry result from deixis-route",
                                    "prepare-incomplete": "geometry result from deixis-route", "diagonal": "Orthogonal endpoint normals",
                                    "diagonal-end": "Orthogonal endpoint normals"}.get(mode, expected)
                        if mode.startswith("radius-"): expected = "Numeric routing radius must be"
                        elif mode.startswith("endpoint-"): expected = "numeric routing endpoint is a point"
                        elif mode.startswith("normal-"): expected = "numeric routing normal"
                        elif mode.startswith("point-"):
                            expected = "Numeric routing points need"
                            if mode == "point-type" and form in ("from", "to"): expected = "numeric routing endpoint is a point"
                            elif form in ("control", "section-control"):
                                if mode == "point-type": expected = "connector.route control point must be"
                                elif mode in ("point-short", "point-long", "point-unitless"): expected = "connector.route control point needs"
                    if source.stem == "continuation-allocation":
                        mode = next(flag.split("=", 1)[1] for flag in flags if flag.startswith("mode="))
                        expected = {"budget": "budget", "expansions": "budget", "waypoint": "waypoint-blocked", "no-path": "no-path"}.get(mode, expected)
                    if source.stem == "connector-scenes":
                        mode = next(flag.split("=", 1)[1] for flag in flags if flag.startswith("mode="))
                        expected = {
                            "endpoint": "endpoint-blocked", "waypoint": "waypoint-blocked", "no-path": "no-path",
                            "budget": "budget", "padding": "endpoint-blocked", "foreign": "endpoint-blocked",
                            "interior": "endpoint-blocked", "continuation": "endpoint-blocked"
                        }.get(mode, expected)
                    if source.stem == "document-scenes":
                        mode = next(flag.split("=", 1)[1] for flag in flags if flag.startswith("mode="))
                        expected = {
                            "point": "Connection body point must be", "body-unprinted": "requires one complete live body span",
                            "body-collected": "require a margin, inset, or framed inline body", "body-unframed": "needs one painted frame",
                            "pin-missing": "No pin matches", "pin-ambiguous": "Ambiguous pin target", "pin-page": "No pin matches",
                            "padding": "Annotation padding must be", "hidden-padding": "Annotation padding must be",
                            "padding-key": "Unknown annotation padding edge", "padding-reversed": "Routing scene bounds need",
                            "point-avoid": "only ignore nodes allow zero-area points"
                        }.get(mode, expected)
                    if source.stem == "hobby" and "mode=numeric" in flags:
                        expected = "Hobby boundary conditions are not numerically representable"
                    if source.stem == "control-curves":
                        mode = next(flag.split("=", 1)[1] for flag in flags if flag.startswith("mode="))
                        expected = {"pin-name": "public pin name must be", "pin-offset": "pin waypoint offset needs two lengths",
                                    "pin-missing": "No pin matches", "pin-page": "No pin matches", "pin-multiple": "needs one occurrence",
                                    "pin-ambiguous": "ambiguous pin target", "waypoints": "A b-spline section has one endpoint"}.get(mode, expected)
                    if source.stem == "missing-setup" and "feature=scene" in flags:
                        expected = "Document scene selectors require deixis-setup-notes"
                    if source.stem == "z-index" and "kind=connector" in flags:
                        expected = "connector.z-index must be an integer"
                    elif source.stem == "scope-name" and any(flag in flags for flag in ("value=reserved", "value=reserved-label")):
                        expected = "page is reserved"
                    elif source.stem == "margin-overflow" and "mode=custom" in flags:
                        expected = "requires a built-in margin layout"
                    elif source.stem == "local-table-declarations":
                        mode = next(flag.removeprefix("mode=") for flag in flags if flag.startswith("mode="))
                        expected = {"original": "Duplicate note ID", "body": "only one body",
                                    "occurrence": "Duplicate occurrence", "scope": "Duplicate block ID"}[mode]
                    elif source.stem == "collection-filter":
                        option = next(flag.removeprefix("option=") for flag in flags if flag.startswith("option="))
                        expected = "Thread filter must be" if option == "thread" else f"{option} must be"
                    elif source.stem == "outline-options":
                        if "option=include-celibates" in flags:
                            expected = "include-celibates was renamed"
                        elif "option=include-unpaired" in flags:
                            expected = "include-unpaired must be"
                        elif "sample=callback" in flags:
                            expected = "group-by callback must return a string"
                    elif source.stem == "note-data":
                        if "mode=inherit" in flags:
                            expected = "inherit annotation data"
                        elif "mode=anonymous" in flags:
                            expected = "phantom annotation data requires an original id"
                    elif source.stem == "printer-callback" and "option=marker-style" in flags:
                        expected = "invalid value"
                    elif source.stem == "native-styles":
                        if "mode=radius" in flags:
                            expected = "connector radius must be a single length"
                        elif "mode=text-fill" not in flags:
                            expected = "connector stroke must be a single stroke"
                    assert result.returncode != 0 and expected.lower() in result.stderr.lower(), (flags, result.stderr)
                print(f"PASS {name} (expected diagnostic; {len(inputs)} case(s))")
                return
            typst("compile", source, pdf)
            if source == ROOT / "docs/manual.typ":
                checked = subprocess.run([sys.executable, str(ROOT / "tests/manual.py"),
                                          "--typst", args.typst, "--pdf", str(pdf),
                                          "--output", str(out / "manual-check")],
                                         text=True, capture_output=True, timeout=120, cwd=ROOT)
                assert checked.returncode == 0 and not checked.stderr, checked.stderr or checked.stdout
            elif source.parent == ROOT / "docs/examples":
                from pypdf import PdfReader
                specimens = json.loads((ROOT / "docs/examples/catalog.json").read_text())
                specimen, = [s for s in specimens if (ROOT / "docs" / s["source"]).resolve() == source]
                assert len(PdfReader(pdf).pages) == specimen["pages"], name
            elif source.stem == "setup-reentry":
                expression = '{ import "/tests/integration/setup-reentry.typ": verify; verify() }'
                for mode in ("foreground", "background", "both", "same", "clear"):
                    for footnotes in ("flow", "overlay"):
                        flags = ("--input", f"mode={mode}", "--input", f"footnotes={footnotes}")
                        target = out / f"setup-reentry-{mode}-{footnotes}.pdf"
                        typst("compile", *flags, source, target)
                        data = json.loads(typst("eval", *flags, "--in", source, "--format", "json", expression))
                        check_pdf_links(target, data, minimum=16)
            elif source.parent.name == "integration" and source.stem == "comment-preset":
                typst("compile", "--input", "final=true", source, out / "comment-preset-final.pdf")
            elif source.parent.name == "integration" and source.stem == "automatic-splits":
                for kind in ("explicit", "inset"):
                    for direction in ("forward", "backward"):
                        for policy in ("native", "manual", "avoid", "separate"):
                            for mode in ("none", "bare", "array", "auto"):
                                typst("compile", "--input", f"kind={kind}", "--input", f"direction={direction}",
                                      "--input", f"policy={policy}", "--input", f"mode={mode}", source,
                                      out / f"automatic-split-{kind}-{direction}-{policy}-{mode}.pdf")
                        for policy in ("native", "manual"):
                            typst("compile", "--input", f"kind={kind}", "--input", f"direction={direction}",
                                  "--input", f"policy={policy}", "--input", "mode=fixed", source,
                                  out / f"fixed-split-{kind}-{direction}-{policy}.pdf")
            elif source.parent.name == "integration" and source.stem == "continuation-counterparts":
                from pypdf import PdfReader
                expression = '{ import "/tests/integration/continuation-counterparts.typ": verify; verify() }'
                for policy in ("native", "manual", "avoid", "separate"):
                    for direction in ("forward", "backward"):
                        for layer in ("foreground", "background"):
                            for mode in ("distinct", "shared", "allocated"):
                                flags = ("--input", f"policy={policy}", "--input", f"direction={direction}",
                                         "--input", f"layer={layer}", "--input", f"mode={mode}")
                                target = out / f"counterpart-{policy}-{direction}-{layer}-{mode}.pdf"
                                typst("compile", *flags, source, target)
                                data = json.loads(typst("eval", *flags, "--in", source, "--format", "json", expression))
                                check_pdf_links(target, data, minimum=4)
                                for page in PdfReader(target).pages:
                                    links = [ref.get_object() for ref in page.get("/Annots", [])
                                             if ref.get_object().get("/Subtype") == "/Link"]
                                    if not links:
                                        continue
                                    assert len(links) == 2, "Expected two separately selectable continuation links."
                                    a, b = ([float(v) for v in link["/Rect"]] for link in links)
                                    assert a[2] <= b[0] or b[2] <= a[0] or a[3] <= b[1] or b[3] <= a[1], "Paired link areas overlap."
                for policy in ("native", "manual", "avoid", "separate"):
                    for direction in ("forward", "backward"):
                        for layer in ("foreground", "background"):
                            flags = ("--input", f"policy={policy}", "--input", f"direction={direction}",
                                     "--input", f"layer={layer}", "--input", "where=shaft", "--input", "mode=allocated")
                            target = out / f"counterpart-shaft-{policy}-{direction}-{layer}.pdf"
                            typst("compile", *flags, source, target)
                            data = json.loads(typst("eval", *flags, "--in", source, "--format", "json", expression))
                            check_pdf_links(target, data, minimum=4)
                for policy in ("native", "manual"):
                    for direction in ("forward", "backward"):
                        for layer in ("foreground", "background"):
                            flags = ("--input", f"policy={policy}", "--input", f"direction={direction}",
                                     "--input", f"layer={layer}", "--input", "where=legacy")
                            target = out / f"counterpart-legacy-{policy}-{direction}-{layer}.pdf"
                            typst("compile", *flags, source, target)
                            data = json.loads(typst("eval", *flags, "--in", source, "--format", "json", expression))
                            check_pdf_links(target, data, minimum=4)
            elif source.parent.name == "integration" and source.stem == "note-counterparts":
                expression = '{ import "/tests/integration/note-counterparts.typ": verify; verify() }'
                variants = [("margin", "forward", body) for body in ("foreground", "background")]
                variants += [("inset", direction, body) for direction in ("forward", "backward")
                             for body in ("flow", "foreground", "background")]
                for kind, direction, body in variants:
                    for policy in ("native", "manual", "avoid", "separate"):
                        for layer in ("foreground", "background"):
                            flags = ("--input", f"kind={kind}", "--input", f"direction={direction}",
                                     "--input", f"body={body}", "--input", f"policy={policy}", "--input", f"layer={layer}")
                            target = out / f"note-counterpart-{kind}-{direction}-{body}-{policy}-{layer}.pdf"
                            typst("compile", *flags, source, target)
                            data = json.loads(typst("eval", *flags, "--in", source, "--format", "json", expression))
                            check_pdf_links(target, data, minimum=6 if kind == "margin" else 2)
            elif source.parent.name == "integration" and source.stem == "counterpart-visibility":
                for policy in ("native", "manual", "avoid", "separate"):
                    for mode in ("dots", "none", "disabled", "declaration", "source", "target"):
                        typst("compile", "--input", f"policy={policy}", "--input", f"mode={mode}", source,
                              out / f"counterpart-visible-{policy}-{mode}.pdf")
            elif source.parent.name == "integration" and source.stem == "document-relay-repair":
                expression = '{ import "/tests/integration/document-relay-repair.typ": verify; verify() }'
                for policy in ("manual", "avoid", "separate"):
                    for direction in ("forward", "backward"):
                        for layer in ("foreground", "background"):
                            for split in ("auto", "fixed"):
                                flags = ("--input", f"policy={policy}", "--input", f"direction={direction}",
                                         "--input", f"layer={layer}", "--input", f"split={split}")
                                target = out / f"relay-repair-{policy}-{direction}-{layer}-{split}.pdf"
                                typst("compile", *flags, source, target)
                                data = json.loads(typst("eval", *flags, "--in", source, "--format", "json", expression))
                                check_pdf_links(target, data, minimum=4)
            elif source.parent.name == "integration" and source.stem == "counterpart-scenes":
                for policy in ("native", "manual"):
                    for layer in ("foreground", "background"):
                        typst("compile", "--input", f"policy={policy}", "--input", f"layer={layer}",
                              source, out / f"counterpart-scene-{policy}-{layer}.pdf")
            elif source.parent.name == "integration" and source.stem == "touying-counterparts":
                for version in ("0.6.3", "0.8.0"):
                    for policy in ("native", "manual", "avoid", "separate"):
                        typst("compile", "--input", f"touying-version={version}", "--input", f"policy={policy}",
                              source, out / f"host-counterpart-{version}-{policy}.pdf")
            elif source.stem in ("paired-continuations", "linked-spill-points"):
                from pypdf import PdfReader
                if source.stem == "paired-continuations":
                    destinations = json.loads(typst("eval", "--in", source, "--format", "json",
                        'query(<deixis-pin>).map(p => (page: p.location().page(), '
                        'x: p.location().position().x.pt(), y: p.location().position().y.pt()))'))
                else:
                    destinations = json.loads(typst("eval", "--in", source, "--format", "json",
                        'query(<deixis-continuation-site>).map(m => (page: m.value.page, '
                        'x: m.value.point.first().pt(), y: m.value.point.last().pt()))'))
                check_pdf_links(pdf, {"destinations": destinations}, minimum=4)
                pages = PdfReader(pdf).pages
                assert [(float(p.mediabox.width), float(p.mediabox.height)) for p in pages] == [(420, 260), (460, 300)]
                for page in pages:
                    links = [ref.get_object() for ref in page.get("/Annots", []) if ref.get_object().get("/Subtype") == "/Link"]
                    assert len(links) == 2, "Each page needs two separately clickable continuation labels."
                    a, b = ([float(v) for v in link["/Rect"]] for link in links)
                    assert a[2] <= b[0] or b[2] <= a[0] or a[3] <= b[1] or b[3] <= a[1], "Continuation link hit areas overlap."
            elif source.stem == "deferred-registration":
                geometry_expression = """{
                  import "src/core/query.typ": _deixis-pin-index, _deixis-pins-for
                  let index = _deixis-pin-index()
                  (expected: query(<deixis-region-mark>).map(r => {
                    let pins = _deixis-pins-for(index, r.value.pins)
                    let page = pins.first().location().page()
                    let points = pins.map(p => (pos: p.location().position(), pad: p.value.padding))
                    let l = calc.min(..points.map(p => (p.pos.x - p.pad.left).pt()))
                    let t = calc.min(..points.map(p => (p.pos.y - p.pad.top).pt()))
                    let r = calc.max(..points.map(p => (p.pos.x + p.pad.right).pt()))
                    let b = calc.max(..points.map(p => (p.pos.y + p.pad.bottom).pt()))
                    (page: page, x: l, y: t, width: r - l, height: b - t)
                  }), actual: query(<flow-measure-shape>).map(s => (
                    page: s.location().page(), x: s.location().position().x.pt(), y: s.location().position().y.pt(),
                    width: s.value.width.pt(), height: s.value.height.pt())))
                }"""
                for marker in ("none", "auto"):
                    inputs = ("--input", f"inner-marker={marker}")
                    if marker == "auto":
                        typst("compile", *inputs, source, out / "deferred-registration-markers.pdf")
                    geometry = json.loads(typst("eval", *inputs, "--in", source,
                                               "--format", "json", geometry_expression))
                    assert len(geometry["expected"]) == len(geometry["actual"]) == 18, geometry
                    for expected, actual in zip(geometry["expected"], geometry["actual"]):
                        assert expected["page"] == actual["page"], (expected, actual)
                        assert all(abs(expected[key] - actual[key]) < .001
                                   for key in ("x", "y", "width", "height")), (expected, actual)
                check_pdf_links(pdf, values(source)[0], minimum=36)
            elif source.stem == "flow-region-measurement":
                expression = '{ import "' + source.relative_to(ROOT).as_posix() + '": verify; verify() }'
                typst("eval", "--in", source, "--format", "json", expression)
            elif source.stem == "flow-region-registered":
                # Keep the standalone-body matrix alongside the attached-body
                # declaration-chain regression above.
                geometry_expression = """{
                  import "src/core/query.typ": _deixis-pin-index, _deixis-pins-for
                  let regions = query(<deixis-region-mark>)
                  let index = _deixis-pin-index()
                  (expected: regions.map(r => {
                    let pins = _deixis-pins-for(index, r.value.pins)
                    let page = pins.first().location().page()
                    let points = pins.map(p => (pos: p.location().position(), pad: p.value.padding))
                    let l = calc.min(..points.map(p => (p.pos.x - p.pad.left).pt()))
                    let t = calc.min(..points.map(p => (p.pos.y - p.pad.top).pt()))
                    let r = calc.max(..points.map(p => (p.pos.x + p.pad.right).pt()))
                    let b = calc.max(..points.map(p => (p.pos.y + p.pad.bottom).pt()))
                    (page: page, x: l, y: t, width: r - l, height: b - t)
                  }), actual: query(<registered-flow-shape>).map(s => (
                    page: s.location().page(), x: s.location().position().x.pt(), y: s.location().position().y.pt(),
                    width: s.value.width.pt(), height: s.value.height.pt())))
                }"""
                for kind in ("margin", "inset", "footnote"):
                    for layer in ("flow", "foreground", "background"):
                        for inline in ("true", "false"):
                            inputs = ("--input", f"kind={kind}", "--input", f"layer={layer}", "--input", f"inline={inline}")
                            if (kind, layer, inline) != ("margin", "foreground", "true"):
                                typst("compile", *inputs, source,
                                      out / f"registered-region-{kind}-{layer}-{inline}.pdf")
                            # Final geometry is checked outside the document;
                            # live assertions would add another layout dependency.
                            geometry = json.loads(typst("eval", *inputs, "--in", source,
                                                       "--format", "json", geometry_expression))
                            assert len(geometry["expected"]) == len(geometry["actual"]) == 1, geometry
                            expected, actual = geometry["expected"][0], geometry["actual"][0]
                            assert expected["page"] == actual["page"], geometry
                            assert all(abs(expected[key] - actual[key]) < .001
                                       for key in ("x", "y", "width", "height")), geometry
            elif source.stem == "repeat-kinds":
                routes = values(source, "<repeat-kind-route>")
                assert sorted(r["name"] for r in routes) == ["implicit", "phantom", "region"], routes
            elif source.stem == "repeat-region-fragments":
                routes = values(source, "<repeat-fragment-route>")
                for route_name, pages, source_page, target_page in (("before", [1, 2], 2, 1), ("inside", [3], 3, 3), ("after", [4, 5], 4, 5)):
                    active = [r for r in routes if r["name"] == route_name]
                    assert [r["document"]["page"] for r in active] == pages, active
                    assert all(r["document"]["source-page"] == source_page and r["document"]["target-page"] == target_page for r in active), active
                check_pdf_links(pdf, values(source)[0])
            elif source.stem == "reuse-api":
                routes = values(source, "<reuse-route>")
                assert sorted(r["name"] for r in routes) == ["explicit", "implicit"], routes
            elif source.stem == "explicit-settings":
                routes = values(source, "<explicit-settings-route>")
                assert len(routes) == 3 and sorted(r["layer"] for r in routes) == ["background", "foreground", "foreground"], routes
            elif source.parent.name == "integration" and source.stem == "control-curves":
                counts = (0, 1, 2, 4)
                cases = [(kind, layer, edge, counts[i % 4], ("local", "settings", "flat")[i % 3], False)
                         for i, (kind, layer, edge) in enumerate((kind, layer, edge)
                             for kind in ("margin", "inset") for layer in ("flow", "foreground", "background")
                             for edge in ("foreground", "background"))]
                cases += [("explicit", "foreground", edge, count, form, False) for count in counts
                          for edge in ("foreground", "background") for form in ("local", "settings", "mixed", "via")]
                cases += [("cross-page", "flow" if edge == "foreground" else "background", edge, count, form, False)
                          for count in counts for edge in ("foreground", "background") for form in ("local", "backward")]
                cases += [("cross-page", "flow", edge, 0, "backward-zero", False) for edge in ("foreground", "background")]
                cases += [(kind, "foreground", edge, 4, form, False) for kind in ("margin", "inset")
                          for edge in ("foreground", "background") for form in ("mixed", "via")]
                cases += [("explicit", "foreground", edge, count, "local", True)
                          for count in counts for edge in ("foreground", "background")]
                expression = '{ import "' + source.relative_to(ROOT).as_posix() + '": verify; verify() }'
                for index, (kind, layer, edge, count, form, crossing) in enumerate(cases):
                    inputs = ("--input", f"kind={kind}", "--input", f"layer={layer}", "--input", f"edge={edge}",
                              "--input", f"count={count}", "--input", f"form={form}",
                              "--input", "crossings=" + ("on" if crossing else "off"))
                    target = out / f"control-curves-{index}.pdf"
                    typst("compile", *inputs, source, target)
                    data = json.loads(typst("eval", *inputs, "--in", source, "--format", "json", expression))
                    framed = json.loads(typst("eval", *inputs, "--input", "syntax=frames", "--in", source, "--format", "json", expression))
                    assert data == framed, (index, "Control pins and framed controls differ.")
                    uncut = json.loads(typst("eval", *inputs, "--input", "cuts=off", "--in", source, "--format", "json", expression))
                    assert data["destinations"] == uncut["destinations"], "Control-curve cuts moved a body."
                    for a, b in zip(data["routes"], uncut["routes"], strict=True):
                        assert a["route"] == b["route"], "Cuts changed original B-spline geometry."
                    if kind != "explicit":
                        check_pdf_links(target, data, minimum=2)
                    for syntax in ("pins", "frames"):
                        typst("compile", *inputs, "--input", f"syntax={syntax}", source, out / f"control-curves-{index}-{syntax}-{{p}}.svg")
                    for page in out.glob(f"control-curves-{index}-pins-*.svg"):
                        other = page.with_name(page.name.replace("-pins-", "-frames-"))
                        assert page.read_bytes() == other.read_bytes(), "Control-pin syntax changed native drawing."
            elif source.parent.name == "integration" and source.stem == "scene-side-sliding":
                cases = [(adapter, side, layer, mode, "same", "off")
                         for adapter in ("explicit", "inset", "margin") for side in ("left", "right")
                         for layer in ("foreground", "background") for mode in ("both", "clear")]
                cases += [(adapter, "right", "foreground", mode, "same", "on")
                          for adapter in ("explicit", "inset", "margin") for mode in ("source", "target")]
                cases += [(adapter, "right", layer, "both", direction, visits)
                          for adapter in ("explicit", "inset") for layer in ("foreground", "background")
                          for direction in ("forward", "backward") for visits in ("off", "on")]
                expression = '{ import "/tests/integration/scene-side-sliding.typ": verify; verify() }'
                for index, (adapter, side, layer, mode, direction, visits) in enumerate(cases):
                    flags = ("--input", f"adapter={adapter}", "--input", f"side={side}", "--input", f"layer={layer}",
                             "--input", f"mode={mode}", "--input", f"direction={direction}", "--input", f"visits={visits}")
                    outputs = []
                    for painter in ("native", "delegate"):
                        inputs = (*flags, "--input", f"painter={painter}")
                        typst("compile", *inputs, source, out / f"sliding-{index}-{painter}.pdf")
                        typst("eval", *inputs, "--in", source, "--format", "json", expression)
                        typst("compile", *inputs, source, out / f"sliding-{index}-{painter}-{{p}}.svg")
                        outputs.append([p.read_bytes() for p in sorted(out.glob(f"sliding-{index}-{painter}-*.svg"))])
                    assert outputs[0] == outputs[1], "Sliding ports differ between native and delegated drawing."
            elif source.parent.name == "integration" and source.stem == "scene-port-selection":
                cases = [(adapter, layer, mode, "same", "region", visits)
                         for adapter in ("explicit", "inset") for layer in ("foreground", "background")
                         for mode in ("source", "target", "both", "clear") for visits in ("off", "on")]
                cases += [(adapter, layer, "both", direction, "region", visits)
                          for adapter in ("explicit", "inset") for layer in ("foreground", "background")
                          for direction in ("forward", "backward") for visits in ("off", "on")]
                cases += [(adapter, "foreground", mode, "same", "inline", visits)
                          for adapter in ("explicit", "inset") for mode in ("both", "clear") for visits in ("off", "on")]
                expression = '{ import "/tests/integration/scene-port-selection.typ": verify; verify() }'
                for index, (adapter, layer, mode, direction, mark, visits) in enumerate(cases):
                    flags = ("--input", f"adapter={adapter}", "--input", f"layer={layer}", "--input", f"mode={mode}",
                             "--input", f"direction={direction}", "--input", f"mark={mark}", "--input", f"visits={visits}")
                    outputs = []
                    for painter in ("native", "delegate"):
                        inputs = (*flags, "--input", f"painter={painter}")
                        typst("compile", *inputs, source, out / f"port-selection-{index}-{painter}.pdf")
                        typst("eval", *inputs, "--in", source, "--format", "json", expression)
                        typst("compile", *inputs, source, out / f"port-selection-{index}-{painter}-{{p}}.svg")
                        outputs.append([p.read_bytes() for p in sorted(out.glob(f"port-selection-{index}-{painter}-*.svg"))])
                    assert outputs[0] == outputs[1], "Selected ports differ between native and delegated painting."
            elif source.parent.name == "integration" and source.stem == "scene-continuation-allocation":
                cases = [(adapter, direction, layer, mode, visits, "pt", "equal")
                         for adapter in ("explicit", "inset") for direction in ("forward", "backward")
                         for layer in ("foreground", "background") for mode in ("blocked", "unreachable", "clear")
                         for visits in ("off", "on")]
                cases += [(adapter, direction, layer, "blocked", "on", "em", "equal")
                          for adapter in ("explicit", "inset") for direction in ("forward", "backward")
                          for layer in ("foreground", "background")]
                cases += [(adapter, direction, layer, "blocked", "on", "pt", "mixed")
                          for adapter in ("explicit", "inset") for direction in ("forward", "backward")
                          for layer in ("foreground", "background")]
                expression = '{ import "/tests/integration/scene-continuation-allocation.typ": verify; verify() }'
                for index, (adapter, direction, layer, mode, visits, units, widths) in enumerate(cases):
                    flags = ("--input", f"adapter={adapter}", "--input", f"direction={direction}", "--input", f"layer={layer}",
                             "--input", f"mode={mode}", "--input", f"visits={visits}", "--input", f"units={units}", "--input", f"widths={widths}")
                    outputs = []
                    for painter in ("native", "delegate"):
                        inputs = (*flags, "--input", f"painter={painter}")
                        target = out / f"allocation-{index}-{painter}.pdf"
                        typst("compile", *inputs, source, target)
                        data = json.loads(typst("eval", *inputs, "--in", source, "--format", "json", expression))
                        check_pdf_links(target, data, minimum=2)
                        if units == "em":
                            from pypdf import PdfReader
                            native_pages = PdfReader(target).pages
                            assert len(native_pages) == 3
                            assert all(abs(float(p.mediabox.width)-400) < 0.01 and abs(float(p.mediabox.height)-260) < 0.01
                                       for p in native_pages), "Captured connector font changed native page dimensions."
                        svg = out / f"allocation-{index}-{painter}-{{p}}.svg"
                        typst("compile", *inputs, source, svg)
                        outputs.append([p.read_bytes() for p in sorted(out.glob(f"allocation-{index}-{painter}-*.svg"))])
                    assert outputs[0] == outputs[1], "Relocated fragments differ between native and delegated painting."
            elif source.parent.name == "integration" and source.stem == "connector-scenes":
                cases = [(kind, layer, edge, "original", "callback")
                         for kind in ("inset", "margin") for layer in ("flow", "foreground", "background")
                         for edge in ("foreground", "background")]
                cases += [("explicit", "foreground", edge, "original", form)
                          for edge in ("foreground", "background") for form in ("callback", "prepared")]
                cases += [(kind, "foreground", "foreground", occurrence, "callback")
                          for kind in ("inset", "margin") for occurrence in ("inline", "region")]
                expression = '{ import "/tests/integration/connector-scenes.typ": verify; verify() }'
                for index, (kind, layer, edge, occurrence, form) in enumerate(cases):
                    flags = ("--input", f"kind={kind}", "--input", f"layer={layer}", "--input", f"edge={edge}",
                             "--input", f"occurrence={occurrence}", "--input", f"form={form}")
                    typst("compile", *flags, source, out / f"connector-scenes-{index}.pdf")
                    typst("eval", *flags, "--in", source, "--format", "json", expression)
            elif source.parent.name == "integration" and source.stem in ("connector-scene-pages", "hidden-connector-scenes"):
                cases = ([dict(visits=visits, missing=missing) for visits in ("off", "on") for missing in ("off", "on")]
                         if source.stem.endswith("pages") else [dict(mode=mode) for mode in ("obstacle", "source", "target", "declaration", "disabled")])
                expression = '{ import "/' + source.relative_to(ROOT).as_posix() + '": verify; verify() }'
                for index, case in enumerate(cases):
                    flags = tuple(part for key, value in case.items() for part in ("--input", f"{key}={value}"))
                    typst("compile", *flags, source, out / f"{source.stem}-{index}.pdf")
                    typst("eval", *flags, "--in", source, "--format", "json", expression)
            elif source.parent.name == "integration" and source.stem == "connector-scene-cuts":
                expression = '{ import "/tests/integration/connector-scene-cuts.typ": verify; verify() }'
                cases = [(family, crossing, "fixed", "off")
                         for family in ("polyline", "orthogonal", "chamfer", "curve", "ccr", "ucr", "hobby", "b-spline")
                         for crossing in ("off", "on")]
                cases += [("orthogonal", "on", "auto", "off"), ("curve", "on", "fixed", "on")]
                for index, (family, crossing, radius, sections) in enumerate(cases):
                    outputs = []
                    for painter in ("native", "delegate"):
                        flags = ("--input", f"route={family}", "--input", f"crossing={crossing}", "--input", f"painter={painter}",
                                 "--input", f"radius={radius}", "--input", f"sections={sections}")
                        svg = out / f"scene-cuts-{index}-{painter}.svg"
                        typst("compile", *flags, source, svg)
                        data = json.loads(typst("eval", *flags, "--in", source, "--format", "json", expression))
                        outputs.append(svg.read_bytes())
                        if painter == "delegate":
                            plain = json.loads(typst("eval", *flags, "--input", "scene=off", "--in", source, "--format", "json", expression))
                            assert data[0]["route"] == plain[0]["route"], "Scene cuts refitted the original curve."
                    assert outputs[0] == outputs[1], "Scene cuts changed native painter delegation."
            elif source.parent.name == "integration" and source.stem == "document-scenes":
                for kind in ("margin", "inset", "inline", "footnote", "endnote"):
                    for layer in (("flow", "foreground", "background") if kind in ("margin", "inset", "footnote") else ("flow",)):
                        snapshots = []
                        geometry = []
                        for timing in ("forward", "backward"):
                            flags = ("--input", f"kind={kind}", "--input", f"layer={layer}", "--input", f"timing={timing}")
                            target = out / f"document-scene-{kind}-{layer}-{timing}.svg"
                            typst("compile", *flags, source, target)
                            snapshots.append(target.read_bytes())
                            geometry.append(json.loads(typst("eval", *flags, "--in", source, "--format", "json", 'query(<document-scene>).map(m => m.value)')))
                        assert all(len(g) == 1 for g in geometry), "Expected exactly one document scene."
                        # Explicit drawing follows native flow paint order. Moving
                        # the drawing call may reorder top-level SVG items, but
                        # must not change any shape/text/route geometry.
                        import xml.etree.ElementTree as ET
                        primitives = [sorted(ET.tostring(child) for child in ET.fromstring(svg)) for svg in snapshots]
                        assert primitives[0] == primitives[1], (kind, layer, "Document scene moved native drawing primitives.")
                        assert geometry[0] == geometry[1], "Document scene declaration order changed accepted geometry."
            elif source.parent.name == "integration" and source.stem == "hidden-document-scenes":
                for kind in ("mark", "body", "pin", "pins", "repeat", "region"):
                    typst("compile", "--input", f"kind={kind}", source, out / f"hidden-scene-{kind}.pdf")
            elif source.parent.name == "integration" and source.stem == "document-routing-invisibility":
                for policy in ("manual", "avoid", "separate"):
                    typst("compile", "--input", f"policy={policy}", source, out / f"policy-invisibility-{policy}.pdf")
            elif source.parent.name == "integration" and source.stem == "routing-policy-pages":
                for policy in ("manual", "avoid", "separate"):
                    typst("compile", "--input", f"policy={policy}", source, out / f"policy-pages-{policy}.pdf")
            elif source.parent.name == "integration" and source.stem == "routing-policy-overlap":
                for policy in ("manual", "avoid"):
                    typst("compile", "--input", f"policy={policy}", source, out / f"policy-overlap-{policy}.pdf")
            elif source.parent.name == "integration" and source.stem == "portal-connections":
                from pypdf import PdfReader
                expression = '{ import "/tests/integration/portal-connections.typ": verify; verify() }'
                cases = [dict(policy=policy, layer=layer, painter=painter)
                         for policy in ("manual", "avoid", "separate")
                         for layer in ("foreground", "background") for painter in ("native", "custom")]
                cases += [dict(mode=mode, painter=painter, layer="background")
                          for mode in ("peer", "unlinked", "dot", "none", "hidden", "disabled")
                          for painter in ("native", "custom")]
                cases += [dict(route=route, policy="manual", painter="custom", cuts="on")
                          for route in ("orthogonal", "curve", "hobby", "b-spline")]
                for index, variant in enumerate(cases):
                    flags = tuple(v for k, value in variant.items() for v in ("--input", f"{k}={value}"))
                    target = out / f"portal-connections-{index}.pdf"
                    typst("compile", *flags, source, target)
                    data = json.loads(typst("eval", *flags, "--in", source, "--format", "json", expression))
                    check_pdf_links(target, data, minimum=data["links"])
                    links = [ref.get_object() for page in PdfReader(target).pages for ref in page.get("/Annots", [])
                             if ref.get_object().get("/Subtype") == "/Link"]
                    assert len(links) == data["links"], "Unexpected native portal link ownership."
            elif source.parent.name == "integration" and source.stem in (
                    "routing-identity-coexistence", "connection-shorthand-coexistence"):
                expression = '{ import "/' + source.relative_to(ROOT).as_posix() + '": verify; verify() }'
                for policy in ("manual", "avoid", "separate"):
                    for layer in ("foreground", "background"):
                        for wrapped in (("node", "body") if source.stem.startswith("routing-") else ("node",)):
                            flags = ("--input", f"policy={policy}", "--input", f"layer={layer}",
                                     "--input", f"wrapped={wrapped}")
                            target = out / f"{source.stem}-{policy}-{layer}-{wrapped}.pdf"
                            typst("compile", *flags, source, target)
                            data = json.loads(typst("eval", *flags, "--in", source, "--format", "json", expression))
                            if source.stem.startswith("routing-"):
                                check_pdf_links(target, data, minimum=3)
            elif source.parent.name == "integration" and source.stem in (
                    "routing-node-bodies", "routing-node-owners", "routing-node-scopes", "routing-node-pages",
                    "routing-node-hidden", "touying-routing-nodes"):
                expression = '{ import "/' + source.relative_to(ROOT).as_posix() + '": verify; verify() }'
                variants = []
                if source.stem in ("routing-node-bodies", "routing-node-owners"):
                    kinds = ("inset", "margin", "inline") if source.stem.endswith("bodies") else ("inset", "margin")
                    variants = [dict(kind=kind, **{"body-layer": body, "layer": layer, "policy": policy})
                                for kind in kinds for body in (("flow",) if kind == "inline" else ("flow", "foreground", "background"))
                                for layer in ("foreground", "background") for policy in ("manual", "avoid", "separate")]
                    if source.stem.endswith("bodies"):
                        variants += [dict(behavior=behavior, layer=layer, policy=policy)
                                     for behavior in ("ignore", "cut", "cross") for layer in ("foreground", "background")
                                     for policy in ("manual", "avoid", "separate")]
                    else:
                        variants += [dict(occurrence=occurrence, layer=layer, policy=policy)
                                     for occurrence in ("inline", "region") for layer in ("foreground", "background")
                                     for policy in ("manual", "avoid", "separate")]
                elif source.stem == "routing-node-pages":
                    variants = [dict(policy=policy, layer=layer) for policy in ("manual", "avoid", "separate")
                                for layer in ("foreground", "background")]
                elif source.stem == "routing-node-hidden":
                    variants = [dict(mode=mode, layer=layer) for mode in ("mark", "body", "repeat", "region")
                                for layer in ("foreground", "background")]
                elif source.stem == "touying-routing-nodes":
                    variants = [{"touying-version": version, "policy": policy} for version in ("0.6.3", "0.8.0")
                                for policy in ("manual", "avoid", "separate")]
                else:
                    variants = [{}]
                for index, variant in enumerate(variants):
                    flags = tuple(v for k, value in variant.items() for v in ("--input", f"{k}={value}"))
                    target = out / f"{source.stem}-{index}.pdf"
                    typst("compile", *flags, source, target)
                    data = json.loads(typst("eval", *flags, "--in", source, "--format", "json", expression))
                    if source.stem == "routing-node-pages":
                        check_pdf_links(target, data, minimum=2)
            elif source.parent.name == "integration" and source.stem == "document-routing-notes":
                for kind in ("margin", "inset"):
                    typst("compile", "--input", f"kind={kind}", source, out / f"document-routing-{kind}.pdf")
            elif source.parent.name == "integration" and source.stem == "routing-note-policy":
                for kind in ("margin", "inset"):
                    for policy in ("manual", "avoid", "separate"):
                        for layer in ("flow", "foreground", "background"):
                            for edge in ("foreground", "background"):
                                typst("compile", "--input", f"kind={kind}", "--input", f"policy={policy}",
                                      "--input", f"layer={layer}", "--input", f"edge={edge}", source,
                                      out / f"note-policy-{kind}-{policy}-{layer}-{edge}.pdf")
                    for policy in ("manual", "avoid", "separate"):
                        for form in ("region", "phantom"):
                            typst("compile", "--input", f"kind={kind}", "--input", f"policy={policy}",
                                  "--input", f"form={form}", source, out / f"note-policy-{kind}-{policy}-{form}.pdf")
                    typst("compile", "--input", f"kind={kind}", "--input", "policy=manual", "--input", "scene=on",
                          source, out / f"note-policy-{kind}-manual-scene.pdf")
            elif source.parent.name == "integration" and source.stem == "routing-note-scopes":
                for kind in ("margin", "inset"):
                    typst("compile", "--input", f"kind={kind}", source, out / f"note-scopes-{kind}.pdf")
            elif source.parent.name == "integration" and source.stem == "routing-note-hidden":
                for kind in ("margin", "inset"):
                    for policy in ("manual", "avoid", "separate"):
                        for mode in ("mark", "body", "disabled"):
                            typst("compile", "--input", f"kind={kind}", "--input", f"policy={policy}",
                                  "--input", f"mode={mode}", source, out / f"note-hidden-{kind}-{policy}-{mode}.pdf")
            elif source.parent.name == "integration" and source.stem == "routing-note-pages":
                for kind, direction in (("margin", "forward"), ("inset", "forward"), ("inset", "backward")):
                    for policy in ("manual", "avoid", "separate"):
                        for edge in ("foreground", "background"):
                            typst("compile", "--input", f"kind={kind}", "--input", f"policy={policy}",
                                  "--input", f"direction={direction}", "--input", f"edge={edge}", source,
                                  out / f"note-pages-{kind}-{policy}-{direction}-{edge}.pdf")
            elif source.parent.name == "integration" and source.stem == "routing-note-invisibility":
                for kind in ("margin", "inset"):
                    for policy in ("manual", "avoid", "separate"):
                        for layer in ("foreground", "background"):
                            typst("compile", "--input", f"kind={kind}", "--input", f"policy={policy}",
                                  "--input", f"layer={layer}", source,
                                  out / f"note-invisibility-{kind}-{policy}-{layer}.pdf")
                            typst("compile", "--input", f"kind={kind}", "--input", f"policy={policy}",
                                  "--input", f"layer={layer}", "--input", "nodes=on", source,
                                  out / f"note-invisibility-nodes-{kind}-{policy}-{layer}.pdf")
            elif source.parent.name == "integration" and source.stem == "routing-note-native":
                for kind in ("margin", "inset"):
                    drawings = []
                    routes = []
                    for policy in ("off", "manual"):
                        flags = ("--input", f"kind={kind}", "--input", f"policy={policy}")
                        svg = out / f"note-native-{kind}-{policy}.svg"
                        typst("compile", *flags, source, svg)
                        drawings.append(svg.read_bytes())
                        routes.append(json.loads(typst("eval", *flags, "--in", source, "--format", "json",
                                                      "query(<note-native-route>).map(m => m.value)")))
                    assert drawings[0] == drawings[1], f"Manual policy changed native {kind} painting."
                    assert routes[0] == routes[1], f"Manual policy changed native {kind} geometry."
            elif source.parent.name == "integration" and source.stem == "routing-note-effects":
                for kind in ("margin", "inset"):
                    for policy in ("manual", "avoid", "separate"):
                        typst("compile", "--input", f"kind={kind}", "--input", f"policy={policy}", source,
                              out / f"note-effects-{kind}-{policy}.pdf")
            elif source.parent.name == "integration" and source.stem == "touying-routing-notes":
                for version in ("0.6.3", "0.8.0"):
                    for kind in ("margin", "inset"):
                        for policy in ("manual", "avoid", "separate"):
                            typst("compile", "--input", f"touying-version={version}", "--input", f"kind={kind}",
                                  "--input", f"policy={policy}", source, out / f"host-note-{version}-{kind}-{policy}.pdf")
            elif source.parent.name == "integration" and source.stem == "document-routing-sockets":
                for policy in ("manual", "avoid", "separate"):
                    for mode in ("auto", "fixed", "source-fixed", "pin", "sliding"):
                        for layer in ("foreground", "background"):
                            typst("compile", "--input", f"policy={policy}", "--input", f"mode={mode}",
                                  "--input", f"layer={layer}", source, out / f"socket-{policy}-{mode}-{layer}.pdf")
                    for layer in ("foreground", "background"):
                        typst("compile", "--input", f"policy={policy}", "--input", "visits=on",
                              "--input", f"layer={layer}", source, out / f"socket-{policy}-visits-{layer}.pdf")
            elif source.parent.name == "integration" and source.stem == "document-routing-ports":
                for mode in ("source", "target", "both", "sliding", "pin"):
                    for layer in ("foreground", "background"):
                        for visits in ("off", "on"):
                            typst("compile", "--input", f"mode={mode}", "--input", f"layer={layer}",
                                  "--input", f"visits={visits}", source, out / f"group-ports-{mode}-{layer}-{visits}.pdf")
                    for layer in ("foreground", "background"):
                        typst("compile", "--input", "policy=avoid", "--input", f"mode={mode}", "--input", f"layer={layer}",
                              "--input", "visits=on", source, out / f"avoid-ports-{mode}-{layer}.pdf")
            elif source.parent.name == "integration" and source.stem == "document-routing-allocation":
                for policy in ("separate", "avoid"):
                    for direction in ("forward", "backward"):
                        for layer in ("foreground", "background"):
                            typst("compile", "--input", f"direction={direction}", "--input", f"layer={layer}",
                                  "--input", f"policy={policy}", source, out / f"group-allocation-{policy}-{direction}-{layer}.pdf")
            elif source.parent.name == "integration" and source.stem in ("touying-document-scenes", "touying-connector-scenes", "touying-continuations", "touying-document-routing"):
                for version in ("0.6.3", "0.8.0"):
                    typst("compile", "--input", f"touying-version={version}", source, out / f"{source.stem}-{version}.pdf")
            elif source.parent.name == "integration" and source.stem == "breakable-scopes":
                typst("eval", "--in", source, "--format", "json",
                      '{ import "/tests/integration/breakable-scopes.typ": verify; verify() }')
            elif source.parent.name == "integration" and source.stem.startswith("palette-"):
                expression = '{ import "/tests/integration/' + source.name + '": verify; verify() }'
                cases = [{}]
                if source.stem == "palette-order":
                    cases = [dict(kind=kind, mark=mark, layer=layer)
                             for kind in ("margin", "inset", "inline", "footnote", "endnote")
                             for mark in ("inline", "region", "phantom")
                             for layer in (("flow", "foreground", "background") if kind in ("margin", "inset", "footnote") else ("foreground",))]
                elif source.stem == "palette-anonymous":
                    cases = [dict(layer=layer) for layer in ("flow", "foreground", "background")]
                elif source.stem == "palette-nested":
                    cases = [dict(kind=kind) for kind in ("margin", "inset")]
                elif source.stem == "palette-visibility":
                    cases = [{}, dict(cover="on"), dict(target="named", priority="on")]
                elif source.stem == "palette-edges":
                    cases = [dict(policy=policy) for policy in ("manual", "avoid", "separate")]
                elif source.stem == "palette-pages":
                    cases = [dict(policy=policy, layer=layer) for policy in ("native", "manual", "avoid", "separate")
                             for layer in ("foreground", "background")]
                for i, inputs in enumerate(cases):
                    flags = tuple(arg for k, v in inputs.items() for arg in ("--input", f"{k}={v}"))
                    typst("compile", *flags, source, out / f"{source.stem}-{i}.pdf")
                    typst("eval", *flags, "--in", source, "--format", "json", expression)
            elif source.parent.name == "integration" and source.stem == "touying-palette":
                for version in ("0.6.3", "0.8.0"):
                    flags = ("--input", f"touying-version={version}")
                    typst("compile", *flags, source, out / f"touying-palette-{version}.pdf")
                    typst("eval", *flags, "--in", source, "--format", "json",
                          '{ import "/tests/integration/touying-palette.typ": verify; verify() }')
            elif source.parent.name == "integration" and source.stem == "spill-scopes":
                for spill in ("auto", "content", "page"):
                    for source_mode in (("inside",) if spill == "auto" else ("inside", "outside")):
                        flags = ("--input", f"spill={spill}", "--input", f"source={source_mode}")
                        typst("compile", *flags, source, out / f"spill-scopes-{spill}-{source_mode}.pdf")
                        typst("eval", *flags, "--in", source, "--format", "json",
                              '{ import "/tests/integration/spill-scopes.typ": verify; verify() }')
            elif source.parent.name == "integration" and source.stem == "spill-threads":
                typst("eval", "--in", source, "--format", "json",
                      '{ import "/tests/integration/spill-threads.typ": verify; verify() }')
            elif source.parent.name == "integration" and source.stem == "spill-regions":
                for kind in ("margin", "inset", "node"):
                    for policy in ("native", "scene", "manual", "avoid", "separate"):
                        for direction in ("forward", "backward"):
                            for side in (("left", "right") if kind == "margin" else ("right",)):
                                flags = ("--input", f"kind={kind}", "--input", f"policy={policy}",
                                         "--input", f"direction={direction}", "--input", f"side={side}",
                                         "--input", f"layer={'background' if direction == 'backward' else 'foreground'}")
                                typst("compile", *flags, source, out / f"spill-regions-{kind}-{policy}-{direction}-{side}.pdf")
                for spill in ("page", "content", "custom"):
                    for policy in ("native", "scene", "separate"):
                        typst("compile", "--input", f"spill={spill}", "--input", f"policy={policy}", source,
                              out / f"spill-regions-{spill}-{policy}.pdf")
                for point in ("start", "end"):
                    for policy in ("native", "scene", "separate"):
                        typst("compile", "--input", f"point={point}", "--input", f"policy={policy}", source,
                              out / f"spill-margin-point-{point}-{policy}.pdf")
                for spill in ("page", "content", "custom"):
                    typst("compile", "--input", f"spill={spill}", "--input", "policy=scene", "--input", "obstacle=channel", source,
                          out / f"spill-blocked-override-{spill}.pdf")
            elif source.parent.name == "integration" and source.stem == "margin-continuations":
                for layer in ("foreground", "background"):
                    for mode in ("custom", "hidden", "disabled", "default", "portal"):
                        target = out / f"margin-continuations-{layer}-{mode}.pdf"
                        flags = ("--input", f"layer={layer}", "--input", f"mode={mode}")
                        typst("compile", *flags, source, target)
                        if mode in ("custom", "portal"):
                            expression = '{ import "/tests/integration/margin-continuations.typ": verify; verify() }'
                            expected = json.loads(typst("eval", *flags, "--in", source, "--format", "json", expression))
                            check_pdf_links(target, expected)
                for layer in ("foreground", "background"):
                    for scene_mode in ("on", "blocked"):
                        target = out / f"margin-scene-continuations-{layer}-{scene_mode}.pdf"
                        flags = ("--input", f"layer={layer}", "--input", f"scene={scene_mode}")
                        typst("compile", *flags, source, target)
                        expression = '{ import "/tests/integration/margin-continuations.typ": verify; verify() }'
                        expected = json.loads(typst("eval", *flags, "--in", source, "--format", "json", expression))
                        check_pdf_links(target, expected)
                for layer in ("foreground", "background"):
                    target = out / f"margin-em-continuations-{layer}.pdf"
                    flags = ("--input", f"layer={layer}", "--input", "scene=blocked", "--input", "units=em")
                    typst("compile", *flags, source, target)
                    expression = '{ import "/tests/integration/margin-continuations.typ": verify; verify() }'
                    expected = json.loads(typst("eval", *flags, "--in", source, "--format", "json", expression))
                    check_pdf_links(target, expected)
            elif source.parent.name == "integration" and source.stem == "continuations":
                for adapter in ("explicit", "inset"):
                    for direction in ("forward", "backward"):
                        for mode in ("custom", "hidden", "disabled", "default"):
                            typst("compile", "--input", f"adapter={adapter}", "--input", f"mode={mode}",
                                  "--input", f"direction={direction}", source,
                                  out / f"continuations-{adapter}-{direction}-{mode}.pdf")
            elif source.parent.name == "integration" and source.stem == "numeric-routing":
                expression = '{ import "' + source.relative_to(ROOT).as_posix() + '": verify; verify() }'
                for route in ("straight-line", "orthogonal", "chamfer", "curve", "ccr", "ucr", "hobby", "b-spline"):
                    for mode in ("ordinary", "gap", "consumed", "empty", "disabled", "loop", "sections"):
                        flags = ("--input", f"route={route}", "--input", f"mode={mode}")
                        snapshots = []
                        outputs = []
                        for backend in ("numeric", "document"):
                            inputs = (*flags, "--input", f"backend={backend}")
                            target = out / f"numeric-routing-{route}-{mode}-{backend}.svg"
                            typst("compile", *inputs, source, target)
                            outputs.append(target.read_bytes())
                            snapshots.append(json.loads(typst("eval", *inputs, "--in", source, "--format", "json", expression)))
                        assert snapshots[0] == snapshots[1], "Preparation changed route geometry or cuts."
                        assert outputs[0] == outputs[1], "Numeric and document painting differ."
            elif source.parent.name == "integration" and source.stem == "route-settings":
                families = ("curve", "centripetal", "uniform")
                cases = [(kind, layer, edge, families[i % 3], ("local", "settings", "flat")[i % 3])
                         for i, (kind, layer, edge) in enumerate((kind, layer, edge)
                             for kind in ("margin", "inset") for layer in ("flow", "foreground", "background")
                             for edge in ("foreground", "background"))]
                cases += [("explicit", "foreground", "foreground", family, form) for family in families
                          for form in ("local", "settings", "flat", "replace", "mixed", "via")]
                cases += [("margin", "flow", edge, family, "auto") for family in families for edge in ("foreground", "background")]
                cases += [("cross-page", "flow" if edge == "foreground" else "background", edge, family, "local")
                          for family in families for edge in ("foreground", "background")]
                cases += [(kind, "foreground", edge, "curve", form) for kind in ("margin", "inset")
                          for edge in ("foreground", "background") for form in ("mixed", "via")]
                cases += [(kind, layer, edge, "hobby", ("local", "settings", "flat")[i % 3])
                          for i, (kind, layer, edge) in enumerate((kind, layer, edge)
                              for kind in ("margin", "inset") for layer in ("flow", "foreground", "background")
                              for edge in ("foreground", "background"))]
                cases += [("explicit", "foreground", "foreground", "hobby", form)
                          for form in ("local", "settings", "flat", "replace", "mixed", "via")]
                cases += [("margin", "flow", edge, "hobby", "auto") for edge in ("foreground", "background")]
                cases += [("cross-page", "flow" if edge == "foreground" else "background", edge, "hobby", form)
                          for edge in ("foreground", "background") for form in ("local", "backward")]
                cases += [(kind, "foreground", edge, "hobby", form) for kind in ("margin", "inset")
                          for edge in ("foreground", "background") for form in ("mixed", "via")]
                cases += [(kind, "foreground", "foreground", "hobby", form)
                          for kind in ("explicit", "margin", "inset") for form in ("equal", "equal-via")]
                expression = '{ import "' + source.relative_to(ROOT).as_posix() + '": verify; verify() }'
                for index, (kind, layer, edge, family, form) in enumerate(cases):
                    inputs = ("--input", f"kind={kind}", "--input", f"layer={layer}", "--input", f"edge={edge}",
                              "--input", f"family={family}", "--input", f"form={form}")
                    target = out / f"route-settings-{index}.pdf"
                    typst("compile", *inputs, source, target)
                    data = json.loads(typst("eval", *inputs, "--in", source, "--format", "json", expression))
                    plain = json.loads(typst("eval", *inputs, "--input", "tension=1", "--in", source, "--format", "json", expression))
                    assert data["destinations"] == plain["destinations"], "Route settings moved a body."
                    if family == "hobby":
                        curled = json.loads(typst("eval", *inputs, "--input", "curl=mixed", "--in", source, "--format", "json", expression))
                        assert data["destinations"] == curled["destinations"], "Hobby curl moved a body."
                        for a, b in zip(data["routes"], curled["routes"], strict=True):
                            assert a["heads"] == b["heads"]
                            assert [(s["start"], s["end"]) for s in a["numeric"]] == [(s["start"], s["end"]) for s in b["numeric"]]
                    if kind != "explicit":
                        check_pdf_links(target, data, minimum=2)
                    if form not in ("mixed", "via"):
                        for actual, baseline in zip(data["routes"], plain["routes"], strict=True):
                            assert actual["heads"] == baseline["heads"]
                            for a, b in zip(actual["numeric"], baseline["numeric"], strict=True):
                                assert a["start"] == b["start"] and a["end"] == b["end"]
                                if family != "hobby":
                                    for control, knot in (("c1", "start"), ("c2", "end")):
                                        assert all(abs(2 * (x-o) - (y-o)) < 1e-6
                                                   for x, y, o in zip(a[control], b[control], a[knot], strict=True)), (index, control)
                    # Neutral records must preserve the exact native output of
                    # route-name shorthand, including mixed section behavior.
                    if form not in ("mixed", "via"):
                        record_svg = out / f"route-settings-{index}-record-{{p}}.svg"
                        string_svg = out / f"route-settings-{index}-string-{{p}}.svg"
                        typst("compile", *inputs, "--input", "tension=1", source, record_svg)
                        typst("compile", *inputs, "--input", "tension=1", "--input", "syntax=string", source, string_svg)
                        for record_page in out.glob(f"route-settings-{index}-record-*.svg"):
                            other = record_page.with_name(record_page.name.replace("-record-", "-string-"))
                            assert record_page.read_bytes() == other.read_bytes(), "Neutral route record changed drawing."
            elif source.parent.name == "integration" and source.stem == "curve-endpoints":
                expression = '{ import "' + source.relative_to(ROOT).as_posix() + '": verify; verify() }'
                for route in ("curve", "ccr", "ucr", "hobby"):
                    for layer in ("foreground", "background"):
                        for mode in ("free", "forced", "return", "duplicate"):
                            inputs = ("--input", f"route={route}", "--input", f"layer={layer}", "--input", f"mode={mode}")
                            typst("compile", *inputs, source, out / f"curve-endpoints-{route}-{layer}-{mode}.pdf")
                            typst("eval", *inputs, "--in", source, "--format", "json", expression)
            elif source.parent.name == "integration" and source.stem == "automatic-crossings":
                import xml.etree.ElementTree as ET
                def moves(path):
                    return sum(node.attrib.get("d", "").lower().count("m") for node in ET.parse(path).getroot().iter()
                               if node.attrib.get("stroke", "none") != "none")
                cases = [(kind, layer, edge, "gap", "normal") for kind in ("inset", "margin")
                         for layer in ("foreground", "background", "flow") for edge in ("foreground", "background")]
                cases += [("explicit", "foreground", edge, "gap", "normal") for edge in ("foreground", "background")]
                cases += [("explicit", "foreground", "foreground", mode, "normal") for mode in
                          ("priority", "tie", "groups", "layers", "unselected", "manual", "manual-lower", "clearance", "zero", "hidden", "disabled")]
                cases += [(kind, "foreground", "foreground", "tie", "reverse") for kind in ("explicit", "inset", "margin")]
                cases += [("explicit", "foreground", "foreground", "priority", "reverse")]
                cases = [(*case, "polyline") for case in cases]
                cases += [(kind, layer, edge, "gap", "normal", route)
                          for route in ("curve", "ccr", "ucr", "orthogonal", "hobby")
                          for kind, layer in (("explicit", "foreground"), ("inset", "flow"), ("margin", "background"))
                          for edge in ("foreground", "background")]
                cases += [("explicit", "foreground", "foreground", mode, "reverse", route)
                          for route in ("curve", "ccr", "ucr", "orthogonal", "hobby") for mode in ("priority", "tie")]
                expression = '{ import "' + source.relative_to(ROOT).as_posix() + '": verify; verify() }'
                for index, (kind, layer, edge, mode, declarations, route) in enumerate(cases):
                    inputs = ("--input", f"kind={kind}", "--input", f"layer={layer}", "--input", f"edge-layer={edge}",
                              "--input", f"mode={mode}", "--input", f"declarations={declarations}", "--input", f"route={route}",
                              "--input", "inherit=on" if index % 3 == 0 else "inherit=off")
                    case_name = f"automatic-crossings-{index}"
                    actual_pdf = out / f"{case_name}.pdf"
                    typst("compile", *inputs, source, actual_pdf)
                    data = json.loads(typst("eval", *inputs, "--in", source, "--format", "json", expression))
                    plain = json.loads(typst("eval", *inputs, "--input", "crossings=off", "--in", source,
                                             "--format", "json", expression))
                    assert data["destinations"] == plain["destinations"], "Crossing gaps changed body placement."
                    for actual, baseline in zip(data["routes"], plain["routes"], strict=True):
                        for key in ("name", "manual", "original", "page"):
                            assert actual[key] == baseline[key], (case_name, key)
                    if kind != "explicit":
                        check_pdf_links(actual_pdf, data, minimum=2)
                    actual_svg = out / f"{case_name}.svg"
                    plain_svg = out / f"{case_name}-plain.svg"
                    typst("compile", *inputs, source, actual_svg)
                    typst("compile", *inputs, "--input", "crossings=off", source, plain_svg)
                    cut_count = sum(len(route["plan"]["cuts"]) for route in data["routes"] if route["plan"])
                    assert moves(actual_svg) - moves(plain_svg) == cut_count, "Native SVG did not paint the planned gaps."
                    if route != "polyline":
                        restored = out / f"{case_name}-restored.svg"
                        typst("compile", *inputs, "--input", "restore=on", source, restored)
                        assert restored.read_bytes() == plain_svg.read_bytes(), "Restoring the manual shaft changed the curve."
            elif source.parent.name == "integration" and source.stem == "crossing-pages":
                expression = '{ import "' + source.relative_to(ROOT).as_posix() + '": verify; verify() }'
                cases = [(route, edge, settings) for route in ("polyline", "curve", "ccr", "ucr", "orthogonal", "b-spline", "hobby")
                         for edge in ("foreground", "background")
                         for settings in (("off", "on") if route in ("curve", "ccr", "ucr", "hobby") else ("off",))]
                for route, edge, settings in cases:
                    inputs = ("--input", f"edge-layer={edge}", "--input", f"route={route}", "--input", f"route-settings={settings}")
                    actual_pdf = out / f"crossing-pages-{route}-{edge}-{settings}.pdf"
                    typst("compile", *inputs, source, actual_pdf)
                    data = json.loads(typst("eval", *inputs, "--in", source, "--format", "json", expression))
                    plain = json.loads(typst("eval", *inputs, "--input", "crossings=off", "--in", source,
                                             "--format", "json", expression))
                    assert data["destinations"] == plain["destinations"]
                    for actual, baseline in zip(data["routes"], plain["routes"], strict=True):
                        for key in ("name", "manual", "original", "page", "heads"):
                            assert actual[key] == baseline[key], key
                    check_pdf_links(actual_pdf, data, minimum=2)
            elif source.stem == "touying-crossings":
                expression = '{ import "' + source.relative_to(ROOT).as_posix() + '": verify; verify() }'
                cases = [(version, route, settings) for version in ("0.6.3", "0.8.0") for route in ("polyline", "curve", "b-spline", "hobby")
                         for settings in (("off", "on") if route in ("curve", "hobby") else ("off",))]
                for version, route, settings in cases:
                    inputs = ("--input", f"touying-version={version}", "--input", f"route={route}", "--input", f"route-settings={settings}")
                    typst("compile", *inputs, source, out / f"touying-crossings-{version}-{route}-{settings}.pdf")
                    typst("eval", *inputs, "--in", source, "--format", "json", expression)
            elif source.parent.name == "integration" and source.stem == "connector-cuts":
                import xml.etree.ElementTree as ET
                cases = [(kind, layer, edge_layer) for kind in ("inset", "margin")
                         for layer in ("foreground", "background", "flow")
                         for edge_layer in ("foreground", "background")]
                cases += [("explicit", "foreground", edge_layer) for edge_layer in ("foreground", "background")]
                cases += [("cross-page", layer, edge_layer) for layer in ("foreground", "background", "flow")
                          for edge_layer in ("foreground", "background")]
                expression = '{ import "' + source.relative_to(ROOT).as_posix() + '": verify; verify() }'
                for index, (kind, layer, edge_layer) in enumerate(cases):
                    inputs = ("--input", f"kind={kind}", "--input", f"layer={layer}", "--input", f"edge-layer={edge_layer}",
                              "--input", "inherit=on" if index % 3 == 0 else "inherit=off",
                              "--input", "mode=interval" if index % 2 else "mode=center")
                    case_name = f"connector-cuts-{kind}-{layer}-{edge_layer}"
                    actual_pdf = out / f"{case_name}.pdf"
                    typst("compile", *inputs, source, actual_pdf)
                    data = json.loads(typst("eval", *inputs, "--in", source, "--format", "json", expression))
                    plain = json.loads(typst("eval", *inputs, "--input", "cuts=off", "--in", source,
                                             "--format", "json", expression))
                    unmarked = json.loads(typst("eval", *inputs, "--input", "indicators=off", "--in", source,
                                                "--format", "json", expression))
                    assert data == unmarked, "Indicators changed cut geometry or body placement."
                    assert data["destinations"] == plain["destinations"], "Cuts changed body placement."
                    for cut_route, full_route in zip(data["routes"], plain["routes"], strict=True):
                        for key in ("geometry", "uncut", "heads", "page"):
                            assert cut_route[key] == full_route[key], (case_name, key)
                        assert cut_route["shaft"] != full_route["shaft"] and len(cut_route["gaps"]) == 1
                    if kind != "explicit":
                        check_pdf_links(actual_pdf, data, minimum=2)
                    typst("compile", *inputs, source, out / (case_name + "-{p}.svg"))
                    ticks = 0
                    for page in range(1, 3 if kind == "cross-page" else 2):
                        tree = ET.parse(out / f"{case_name}-{page}.svg")
                        ticks += sum(element.attrib.get("stroke") == "#228855" for element in tree.getroot().iter())
                    assert ticks == (4 if kind == "cross-page" else 2), (case_name, ticks)
                    if index == 0:
                        # A custom painter can restore uncut geometry; the native
                        # helper must neither recut it nor leave stale indicators.
                        restored = out / "connector-cuts-restored.svg"
                        original = out / "connector-cuts-original.svg"
                        typst("compile", *inputs, "--input", "restore=on", source, restored)
                        typst("compile", *inputs, "--input", "cuts=off", source, original)
                        assert restored.read_bytes() == original.read_bytes(), "Painter restoration changed native output."
            elif source.parent.name == "integration" and source.stem == "connector-gaps":
                import xml.etree.ElementTree as ET
                cases = [(kind, layer, edge_layer) for kind in ("inset", "margin")
                         for layer in ("foreground", "background", "flow")
                         for edge_layer in ("foreground", "background")]
                cases += [("explicit", "foreground", edge_layer) for edge_layer in ("foreground", "background")]
                cases += [("cross-page", layer, edge_layer) for layer in ("foreground", "background", "flow")
                          for edge_layer in ("foreground", "background")]
                expression = '{ import "' + source.relative_to(ROOT).as_posix() + '": verify; verify() }'
                for index, (kind, layer, edge_layer) in enumerate(cases):
                    shape = "bar" if index % 2 else "slash"
                    inputs = ("--input", f"kind={kind}", "--input", f"layer={layer}",
                              "--input", f"edge-layer={edge_layer}", "--input", f"shape={shape}",
                              "--input", "inherit=on" if index % 3 == 0 else "inherit=off")
                    case_name = f"connector-gaps-{kind}-{layer}-{edge_layer}"
                    actual_pdf = out / f"{case_name}.pdf"
                    typst("compile", *inputs, source, actual_pdf)
                    data = json.loads(typst("eval", *inputs, "--in", source, "--format", "json", expression))
                    plain = json.loads(typst("eval", *inputs, "--input", "marks=off", "--in", source,
                                             "--format", "json", expression))
                    assert data == plain, "Gap decoration changed routing or body placement."
                    if kind != "explicit":
                        check_pdf_links(actual_pdf, data, minimum=2)
                    typst("compile", *inputs, source, out / (case_name + "-{p}.svg"))
                    ticks = 0
                    for page in range(1, 3 if kind == "cross-page" else 2):
                        tree = ET.parse(out / f"{case_name}-{page}.svg")
                        ticks += sum(element.attrib.get("stroke") == "#228855" for element in tree.getroot().iter())
                    assert ticks == 2, (case_name, ticks)
            elif source.stem == "connector-painter":
                # Delegating to the public native painter must retain every
                # visible path, dash, head, and intentional discontinuity.
                expression = '{ import "' + source.relative_to(ROOT).as_posix() + '": verify; verify() }'
                images = []
                for painter in ("native", "delegate"):
                    inputs = ("--input", f"painter={painter}")
                    actual_pdf = pdf if painter == "native" else out / "connector-painter-delegate.pdf"
                    if actual_pdf != pdf:
                        typst("compile", *inputs, source, actual_pdf)
                    typst("eval", *inputs, "--in", source, "--format", "json", expression)
                    png = out / f"connector-painter-{painter}"
                    subprocess.run(["pdftoppm", "-scale-to", "1400", "-singlefile", "-png",
                                    str(actual_pdf), str(png)], check=True, capture_output=True)
                    images.append(png.with_suffix(".png").read_bytes())
                assert images[0] == images[1], "Native painter delegation changed visible output."
            elif source.parent.name == "integration" and source.stem in ("margin-overflow", "margin-overflow-spill"):
                cases = [(layer, "adaptive") for layer in ("foreground", "background", "flow")]
                if source.stem.endswith("spill"):
                    cases = [(layer, layout) for layer in ("foreground", "background") for layout in ("adaptive", "flow")]
                for layer, layout in cases:
                    inputs = ("--input", f"layer={layer}", "--input", f"layout={layout}")
                    actual_pdf = out / f"{source.stem}-{layer}-{layout}.pdf"
                    typst("compile", *inputs, source, actual_pdf)
                    expression = '{ import "' + source.relative_to(ROOT).as_posix() + '": verify; verify() }'
                    data = json.loads(typst("eval", *inputs, "--in", source, "--format", "json", expression))
                    check_pdf_links(actual_pdf, data, minimum=4)
                    if source.stem.endswith("spill"):
                        allowed = json.loads(typst("eval", *inputs, "--input", "policy=allow", "--in", source,
                                                  "--format", "json", expression))
                        assert allowed == data, "Overflow checking must preserve accepted geometry."

            elif source.stem == "collection-empty-ranges":
                expression = '{ import "' + source.relative_to(ROOT).as_posix() + '": verify; verify() }'
                data = json.loads(typst("eval", "--in", source, "--format", "json", expression))
                check_pdf_links(pdf, data)
            elif source.stem == "deferred-scopes":
                cases = [(kind, layer) for kind in ("inset", "margin", "footnote")
                         for layer in ("foreground", "background", "flow")]
                cases += [(kind, "flow") for kind in ("inline", "endnote")]
                for kind, layer in cases:
                    for inner in ("inside", "outside"):
                        for scope in ("named", "anonymous"):
                            inputs = ("--input", f"kind={kind}", "--input", f"layer={layer}",
                                      "--input", f"inner={inner}", "--input", f"scope={scope}")
                            default = (kind, layer, inner, scope) == ("inset", "foreground", "inside", "named")
                            actual_pdf = pdf if default else out / f"deferred-scopes-{kind}-{layer}-{inner}-{scope}.pdf"
                            if actual_pdf != pdf:
                                typst("compile", *inputs, source, actual_pdf)
                            expression = '{ import "' + source.relative_to(ROOT).as_posix() + '": verify; verify() }'
                            data = json.loads(typst("eval", *inputs, "--in", source, "--format", "json", expression))
                            check_pdf_links(actual_pdf, data)
            elif source.stem == "scope-convergence":
                for mode in ("named", "anonymous", "contextual", "siblings"):
                    inputs = ("--input", f"mode={mode}")
                    actual_pdf = pdf if mode == "named" else out / f"scope-convergence-{mode}.pdf"
                    if actual_pdf != pdf:
                        typst("compile", *inputs, source, actual_pdf)
                    expression = '{ import "' + source.relative_to(ROOT).as_posix() + '": verify; verify() }'
                    data = json.loads(typst("eval", *inputs, "--in", source, "--format", "json", expression))
                    check_pdf_links(actual_pdf, data)
            elif source.stem in ("custom-renderer-navigation", "custom-renderer-pagination"):
                cases = [(kind, layer) for kind in ("margin", "inset", "footnote")
                         for layer in ("flow", "foreground", "background")]
                cases += [(kind, "flow") for kind in ("inline", "block-footnote", "endnote")]
                if source.stem == "custom-renderer-pagination":
                    cases = [(kind, "flow") for kind in ("inline", "footnote", "block-footnote", "endnote")]
                for kind, layer in cases:
                    inputs = ("--input", f"kind={kind}", "--input", f"layer={layer}")
                    default = ("inset", "foreground") if source.stem.endswith("navigation") else ("inline", "flow")
                    actual_pdf = pdf if (kind, layer) == default else out / f"{source.stem}-{kind}-{layer}.pdf"
                    if actual_pdf != pdf:
                        typst("compile", *inputs, source, actual_pdf)
                    expression = '{ import "' + source.relative_to(ROOT).as_posix() + '": verify; verify() }'
                    data = json.loads(typst("eval", *inputs, "--in", source, "--format", "json", expression))
                    check_pdf_links(actual_pdf, data, minimum=3 if source.stem.endswith("pagination") else 6)
            elif source.stem == "attachment-options":
                expression = '{ import "/tests/integration/attachment-options.typ": verify; verify() }'
                data = json.loads(typst("eval", "--in", source, "--format", "json", expression))
                check_pdf_links(pdf, data)
            elif source.stem == "footnote-flow-pagination":
                for mode in ("paragraphs", "native", "single-paragraph", "lists", "table", "columns",
                             "mixed", "border", "native-renderer", "custom-renderer", "shared", "standalone"):
                    inputs = ("--input", f"mode={mode}")
                    actual_pdf = pdf if mode == "paragraphs" else out / f"footnote-flow-pagination-{mode}.pdf"
                    if actual_pdf != pdf:
                        typst("compile", *inputs, source, actual_pdf)
                    expression = '{ import "/tests/integration/footnote-flow-pagination.typ": verify; verify() }'
                    data = json.loads(typst("eval", *inputs, "--in", source, "--format", "json", expression))
                    check_pdf_links(actual_pdf, data, minimum=2)
                    pages = pdf_words(actual_pdf)
                    tokens = []
                    for page, words in enumerate(pages, 1):
                        for word in words:
                            assert 0 <= word["x"] < word["right"] <= 420, (mode, page, word)
                            assert 0 <= word["y"] < word["bottom"] <= 300, (mode, page, word)
                            for token in re.findall(r"FN1[0-9]{2}|ENDLONG", word["text"]):
                                assert data["start"] <= page <= data["end"], (mode, token, page, data)
                                tokens.append(token)
                    assert tokens == data["expected"] + ["ENDLONG"], (mode, tokens)
                    if mode == "mixed":
                        text = subprocess.run(["pdftotext", "-layout", str(actual_pdf), "-"],
                                              text=True, capture_output=True, check=True).stdout
                        assert re.search(r"1\s*Native One\.", text) and re.search(r"2\s*Native Two\.", text), text
            elif source.stem == "footnote-whitespace":
                control = out / "footnote-whitespace-native.pdf"
                typst("compile", "--input", "mode=native", source, control)
                native = pdf_words(control)
                assert len(native) == 1
                for layer in ("flow", "foreground", "background"):
                    for renderer in ("default", "native"):
                        inputs = ("--input", f"mode={layer}", "--input", f"renderer={renderer}")
                        actual_pdf = pdf if (layer, renderer) == ("flow", "default") else out / f"footnote-whitespace-{layer}-{renderer}.pdf"
                        if actual_pdf != pdf:
                            typst("compile", *inputs, source, actual_pdf)
                        words = pdf_words(actual_pdf)
                        assert len(words) == 1
                        # Compare the entire main paragraph, with genuine spaces
                        # and line wrapping. Footer typography can differ.
                        main = lambda ws: [(w["text"], round(w["x"], 3), round(w["y"], 3)) for w in ws if w["y"] < 350]
                        assert main(words[0]) == main(native[0]), (layer, renderer, main(words[0]), main(native[0]))
                        # Single/multiline source syntax, styles, metadata and
                        # contextual content all retain the native first-line x.
                        # Explicit blank paragraphs/linebreaks start at the edge.
                        alpha = lambda ws: [w for w in ws if "Alpha." in w["text"]]
                        a, b = alpha(words[0]), alpha(native[0])
                        assert len(a) == len(b) == 10
                        for i in (0, 1, 4, 5, 6, 7, 8):
                            assert abs(a[i]["right"] - a[0]["right"]) < .01, (layer, renderer, a)
                        for i in (2, 3, 9):
                            assert abs(a[i]["right"] - b[i]["right"]) < .01, (layer, renderer, a, b)
                        assert all(("Alpha." == x["text"]) == ("Alpha." == y["text"]) for x, y in zip(a, b))
            elif source.stem == "footnote-start-line":
                control = out / "footnote-start-line-native.pdf"
                typst("compile", "--input", "mode=native", source, control)
                native = pdf_words(control)
                assert len(native) == 2
                for layer in ("flow", "foreground", "background"):
                    actual_pdf = pdf if layer == "flow" else out / f"footnote-start-line-{layer}.pdf"
                    if actual_pdf != pdf:
                        typst("compile", "--input", f"mode={layer}", source, actual_pdf)
                    pages = pdf_words(actual_pdf)
                    assert len(pages) == 2
                    for actual, expected in zip(pages, native):
                        a = [w for w in actual if "Alpha." in w["text"]]
                        b = [w for w in expected if "Alpha." in w["text"]]
                        assert len(a) == len(b) == 1
                        assert abs(a[0]["right"] - b[0]["right"]) < .01, (layer, a, b)
                        assert "Alpha." != a[0]["text"], (layer, a)
                for layer in ("flow", "foreground", "background"):
                    actual_pdf = out / f"footnote-start-line-zero-{layer}.pdf"
                    typst("compile", "--input", f"mode={layer}", "--input", "gap=zero", source, actual_pdf)
                    pages = pdf_words(actual_pdf)
                    assert len(pages) == 2
                    alpha = [[w for w in p if "Alpha." in w["text"]] for p in pages]
                    assert all(len(a) == 1 and a[0]["text"] != "Alpha." for a in alpha), (layer, alpha)
                    assert abs(alpha[0][0]["right"] - alpha[1][0]["right"]) < .01, (layer, alpha)
            elif source.stem == "note-body-whitespace":
                for kind in ("margin", "inset", "inline", "footnote", "block-footnote", "endnote"):
                    actual_pdf = pdf if kind == "margin" else out / f"note-body-whitespace-{kind}.pdf"
                    if actual_pdf != pdf:
                        typst("compile", "--input", f"kind={kind}", source, actual_pdf)
                    text = subprocess.run(["pdftotext", str(actual_pdf), "-"], text=True,
                                          capture_output=True, check=True).stdout
                    assert text.count("Alpha.") == 8, (kind, text)
            elif source.stem == "inline-decoration-pagination":
                for ownership in ("attached", "standalone"):
                    for mode in ("highlight", "underline", "box", "parentheses", "text-fill", "none"):
                        inputs = ("--input", f"ownership={ownership}", "--input", f"mode={mode}")
                        actual_pdf = pdf if (ownership, mode) == ("attached", "highlight") else out / f"inline-decoration-{ownership}-{mode}.pdf"
                        if actual_pdf != pdf:
                            typst("compile", *inputs, source, actual_pdf)
                        expression = '{ import "/tests/integration/inline-decoration-pagination.typ": verify; verify() }'
                        data = json.loads(typst("eval", *inputs, "--in", source, "--format", "json", expression))
                        check_pdf_links(actual_pdf, data, minimum=2 if ownership == "attached" else 0)
                        words = [w for page in pdf_words(actual_pdf) for w in page]
                        assert sum("STARTLONG" in w["text"] for w in words) == 1
                        assert sum("ENDLONG" in w["text"] for w in words) == 1
                        assert all(0 <= w["x"] < w["right"] <= 300 and 0 <= w["y"] < w["bottom"] <= 220 for w in words)
            elif source.stem == "native-footnote-allocation":
                actual_text = subprocess.run(["pdftotext", str(pdf), "-"], text=True,
                                             capture_output=True, check=True).stdout
                assert actual_text.count("Native entry.") == 22, actual_text
            elif source.stem == "footnote-allocation":
                for layer in ("foreground", "background", "flow"):
                    inputs = ("--input", f"layer={layer}")
                    actual_pdf = pdf if layer == "foreground" else out / f"footnote-allocation-{layer}.pdf"
                    if actual_pdf != pdf:
                        typst("compile", *inputs, source, actual_pdf)
                    data = json.loads(typst("eval", *inputs, "--in", source, "--format", "json",
                                            "query(<test-result>).map(m=>m.value)"))[0]
                    check_pdf_links(actual_pdf, data)
            elif source.stem == "local-table-notes":
                for layer in ("foreground", "background", "flow"):
                    for caption in ("bottom", "top"):
                        for repeat in ("mark", "ref"):
                            inputs = ("--input", f"layer={layer}", "--input", f"caption={caption}",
                                      "--input", f"repeat={repeat}")
                            actual_pdf = pdf if (layer, caption, repeat) == ("foreground", "bottom", "mark") else out / f"local-table-{layer}-{caption}-{repeat}.pdf"
                            if actual_pdf != pdf:
                                typst("compile", *inputs, source, actual_pdf)
                            expression = '{ import "/tests/integration/local-table-notes.typ": verify; verify() }'
                            data = json.loads(typst("eval", *inputs, "--in", source, "--format", "json", expression))
                            check_pdf_links(actual_pdf, data)
                            pages = pdf_words(actual_pdf)
                            words = [w for p in pages for w in p]
                            for marker in ("UNITNOTE", "ENDUNITNOTE", "ROWNOTE0", "ROWNOTE13", "OUTSIDEBEFORE", "OUTSIDEAFTER"):
                                assert sum(bool(re.search(r"(?<![A-Z])" + marker + r"(?![A-Z0-9])", w["text"])) for w in words) == 1, (layer, caption, repeat, marker)
                            for token in [f"ROW{i}" for i in range(14)] + [f"DETAIL{i}" for i in range(8)]:
                                assert sum(bool(re.search(token + r"(?![0-9])", w["text"])) for w in words) == 1, (layer, caption, repeat, token)
                            text = " ".join(w["text"] for w in words)
                            assert re.findall(r"ROW(1[0-3]|[0-9])(?![0-9])", text) == [str(i) for i in range(14)]
                            assert re.findall(r"DETAIL([0-7])", text) == [str(i) for i in range(8)]
                            for i, page in enumerate(pages, 1):
                                assert all(0 <= w["x"] < w["right"] <= 420 and 0 <= w["y"] < w["bottom"] <= 300 for w in page)
                                if repeat == "mark":
                                    assert any(w["text"].startswith("Value") for w in page) == (i in data["header-pages"])
            elif source.stem == "local-figure-notes":
                for placement in ("top", "bottom"):
                    for scope in ("parent", "column"):
                        for caption in ("bottom", "top"):
                            for columns in ("one", "two"):
                                inputs = ("--input", f"placement={placement}", "--input", f"scope={scope}",
                                          "--input", f"caption={caption}", "--input", f"columns={columns}")
                                actual_pdf = pdf if (placement, scope, caption, columns) == ("top", "parent", "bottom", "one") else out / f"local-figure-{placement}-{scope}-{caption}-{columns}.pdf"
                                if actual_pdf != pdf:
                                    typst("compile", *inputs, source, actual_pdf)
                                expression = '{ import "/tests/integration/local-figure-notes.typ": verify; verify() }'
                                data = json.loads(typst("eval", *inputs, "--in", source, "--format", "json", expression))
                                check_pdf_links(actual_pdf, data)
                                pages = pdf_words(actual_pdf)
                                words = [w for p in pages for w in p]
                                for token in ("CAPTIONNOTE0", "CAPTIONNOTE1", "DIAGRAMNOTE0", "DIAGRAMNOTE1", "OUTSIDEBEFORE", "OUTSIDEAFTER"):
                                    assert sum(token in w["text"] for w in words) == 1, (placement, scope, caption, columns, token)
                                for figure in data["figures"]:
                                    index = figure["owner"].split("-")[-1]
                                    actual = " ".join(w["text"] for w in pages[figure["page"] - 1])
                                    assert f"CAPTIONNOTE{index}" in actual and f"DIAGRAMNOTE{index}" in actual
                                assert all(0 <= w["x"] < w["right"] <= 440 and 0 <= w["y"] < w["bottom"] <= 340 for w in words)
            elif source.stem == "block-pagination":
                cases = [(mode, layer, "native") for mode in ("exact", "adaptive", "flow")
                         for layer in ("foreground", "background")]
                cases += [("adaptive", "foreground", group) for group in ("aligned", "grid")]
                for mode, layer, group in cases:
                    inputs = ("--input", f"mode={mode}", "--input", f"layer={layer}", "--input", f"group={group}")
                    actual_pdf = pdf if (mode, layer, group) == ("exact", "foreground", "native") else out / f"block-pagination-{mode}-{layer}-{group}.pdf"
                    if actual_pdf != pdf:
                        typst("compile", *inputs, source, actual_pdf)
                    data = json.loads(typst("eval", *inputs, "--in", source, "--format", "json",
                                            "query(<test-result>).map(m=>m.value)"))[0]
                    check_pdf_links(actual_pdf, data)
            elif source.parent.name == "integration" and source.stem in ("counter-streams", "counter-boundaries", "native-visibility", "page-note-order", "collection-boundaries", "collection-scopes", "note-catalogue", "catalogue-adapters", "outline-navigation", "scope-identities"):
                check_pdf_links(pdf, values(source)[0])
                if source.stem == "outline-navigation":
                    text = subprocess.run(["pdftotext", str(pdf), "-"], text=True, capture_output=True, check=True).stdout
                    assert "iv,B,P2" in "".join(text.split()), text
                elif source.stem == "native-visibility":
                    text = subprocess.run(["pdftotext", str(pdf), "-"], text=True, capture_output=True, check=True).stdout
                    compact = "".join(text.split())
                    for hidden in ("Coveredmark", "Coveredoccurrence", "Coveredregion", "Coveredpin",
                                   "HiddenInsetBody", "HiddenBlockBody", "HiddenEndBody", "HiddenNested", "UnprintedBody"):
                        assert hidden not in compact, text
            elif source.stem == "visibility-boundaries":
                text = subprocess.run(["pdftotext", str(pdf), "-"], text=True, capture_output=True, check=True).stdout
                compact = "".join(text.split())
                assert "VisibleOverlay" in compact and "VisibleFooter" in compact, text
                assert all(hidden not in compact for hidden in ("CoveredFirst", "CoveredSecond", "HiddenPrinterBody")), text
            elif source.stem == "pin-connections" and source.parent.name == "integration":
                data, = values(source)
                routes = values(source, "<pin-route>")
                cases = values(source, "<pin-case>")
                assert len(routes) == len(cases) == 12, routes
                for route in routes:
                    check_finite_geometry(route)
                    case, = [c for c in cases if c["name"] == route["name"]]
                    doc = route["document"]
                    assert doc["page"] == doc["source-page"] == doc["target-page"] == case["page"], route
                    assert doc["connection"]["source"]["pin"] == "a" and doc["connection"]["target"]["pin"] == "b", route
                    assert doc["nodes"]["mark"]["bounds"]["left"] == "80pt", route
                    assert doc["nodes"]["body"]["bounds"]["left"] == "360pt", route
                    assert route["heads"] == [True, True], route
                    gap_s, gap_d = (2, -3) if case["directed"] else (0, 0)
                    assert doc["endpoints"]["mark"]["point"] == [f"{80 + gap_s}pt", "130pt"], route
                    assert doc["endpoints"]["body"]["point"] == [f"{360 + gap_d}pt", "150pt"], route
                    assert doc["endpoints"]["mark"]["normal"] == ([1, 0] if case["directed"] else [0, 0]), route
                    origin = route["origin"]
                    def absolute(point):
                        return [float(a[:-2]) + float(b[:-2]) for a, b in zip(origin, point)]
                    ends = [absolute(s["end"]) for s in route["segments"]]
                    expected_points = [[235, 87]] if case["name"].startswith(("right-angle", "chamfer")) else [[235, 87], [255, 97]]
                    for expected in expected_points:
                        assert any(all(abs(a - b) < .001 for a, b in zip(point, expected)) for point in ends), route
                without, = json.loads(typst("eval", "--input", "edges=off", "--in", source, "--format", "json",
                                           "query(<test-result>).map(it=>it.value)"))
                assert data == without, "Connections changed pin positions."
            elif source.stem == "pin-connection-adapters":
                data, = values(source)
                routes = values(source, "<pin-adapter-route>")
                assert len(routes) == 18, routes
                for route in routes:
                    check_finite_geometry(route)
                    route_name, doc = route["name"], route["document"]
                    if route_name.startswith("to-pin-"):
                        continue
                    explicit = route_name.startswith("explicit-")
                    identity = route_name.removeprefix("explicit-")
                    socket, = [p["position"] for p in data["pins"] if p["name"] == "socket" and p["scope"] == identity]
                    x, y = doc["endpoints"]["body"]["point"]
                    assert abs(float(x[:-2]) - float(socket["x"][:-2]) - (1 if explicit else -2)) < .001, route
                    assert y == socket["y"], route
                    assert doc["nodes"]["body"]["bounds"] == data["frames"]["id-" + identity][0]["bounds"], route
                typst("compile", "--input", "edges=off", source, out / "pin-adapters-without-edges.pdf")
                without, = json.loads(typst("eval", "--input", "edges=off", "--in", source, "--format", "json",
                                           "query(<test-result>).map(it=>it.value)"))
                assert data == without, "Custom pin ports changed body geometry or live pin positions."
            elif source.stem == "pin-connection-spillover":
                baseline_pins = None
                for kind in ("curve", "b-spline", "hobby"):
                    typst("compile", "--input", f"route={kind}", source, out / f"pin-spillover-{kind}.pdf")
                    pins, = json.loads(typst("eval", "--input", f"route={kind}", "--in", source, "--format", "json",
                                            "query(<test-result>).map(it=>it.value)"))
                    routes = json.loads(typst("eval", "--input", f"route={kind}", "--in", source, "--format", "json",
                                              "query(<pin-spill-route>).map(it=>it.value)"))
                    if baseline_pins is None:
                        baseline_pins = pins
                    assert pins == baseline_pins, "Control curves moved margin bodies or live pins."
                    assert len(routes) > 5, routes
                    for edge_name in {r["name"] for r in routes}:
                        parts = [r for r in routes if r["name"] == edge_name]
                        assert sum(r["heads"][0] for r in parts) == sum(r["heads"][1] for r in parts) == 1, parts
                    for route in routes:
                        check_finite_geometry(route)
                        doc = route["document"]
                        for role, pin_name, expected_normal in (("mark", "source", [0, 1]), ("body", "socket", [-1, 0])):
                            end = doc["endpoints"][role]
                            if end["role"] == "continuation":
                                continue
                            pos, = [p["position"] for p in pins if p["scope"] == route["name"] and p["name"] == pin_name]
                            assert doc["page"] == pos["page"] and end["point"] == [pos["x"], pos["y"]], route
                            assert end["normal"] == expected_normal, route
            elif source.stem == "pin-connection-pages":
                routes = values(source, "<pin-page-route>")
                assert len(routes) == 4, routes
                for route in routes:
                    check_finite_geometry(route)
                    doc = route["document"]
                    assert doc["page"] in (1, 3), route
                    assert route["heads"] == [not doc["is-incoming"], not doc["is-outgoing"]], route
                    assert doc["source-page"] == (1 if route["name"] == "forward" else 3), route
                    assert doc["target-page"] == (3 if route["name"] == "forward" else 1), route
            elif source.stem in ("body-points-collected", "body-points-adapters"):
                data, = values(source)
                check_pdf_links(pdf, data)
                tag = "<collected-point-route>" if source.stem == "body-points-collected" else "<adapter-point-route>"
                routes = values(source, tag)
                spans = {"id-" + s["id"]: s for s in data["spans"]}
                check_body_point_routes(routes, spans, data.get("cases"))
                assert len({r["name"] for r in routes}) == (12 if source.stem == "body-points-collected" else 22), routes
                if source.stem == "body-points-collected":
                    typst("compile", "--input", "edges=off", source, out / "collected-without-point-edges.pdf")
                    without, = json.loads(typst("eval", "--input", "edges=off", "--in", source,
                                               "--format", "json", "query(<test-result>).map(it => it.value)"))
                    assert data == without, "Point connections changed native collection layout or PDF destinations."
                    assert json.loads(typst("eval", "--input", "edges=off", "--in", source, "--format", "json",
                                           "query(<collected-point-route>).len()")) == 0
            elif source.stem == "body-frame-columns":
                data, = values(source)
                check_pdf_links(pdf, data, minimum=2)
                assert set(data["frames"]) == {"id-short", "id-rotated", "id-scaled"}, data
                for i, span in enumerate(data["spans"]):
                    assert span["start"]["page"] == span["end"]["page"], span
                    delta = float(span["end"]["x"][:-2]) - float(span["start"]["x"][:-2])
                    assert (delta > 200 if i == 0 else delta < -200), span
                routes = values(source, "<column-point-route>")
                assert len(routes) == 8, routes
                check_body_point_routes(routes, {"id-" + s["id"]: s for s in data["spans"]}, data["cases"])
                typst("compile", "--input", "edges=off", source, out / "columns-without-edges.pdf")
                without, = json.loads(typst("eval", "--input", "edges=off", "--in", source,
                                           "--format", "json", "query(<test-result>).map(it => it.value)"))
                assert data == without, "Connections changed native column layout or frame evidence."
                assert json.loads(typst("eval", "--input", "edges=off", "--in", source,
                                       "--format", "json", "query(<column-point-route>).len()")) == 0
            elif source.stem == "body-points-routing":
                routes = values(source, "<point-router>")
                assert len(routes) == 12, routes
                for r in routes:
                    check_finite_geometry(r)
                    if r["coincident"]:
                        assert r["document"]["nodes"]["mark"]["bounds"] == r["document"]["nodes"]["body"]["bounds"], r
            elif source.stem == "explicit-inline-bodies":
                data, = values(source)
                check_pdf_links(pdf, data)
                routes = values(source, "<inline-body-route>")
                assert len(routes) == 15, routes
                frames = {n["identity"]: n for n in data["frames"]}
                for route in routes:
                    doc = route["document"]
                    assert doc["nodes"]["body"]["bounds"] == frames[doc["connection"]["target"]]["bounds"], route
                for direction in ("forward", "backward"):
                    parts = [r for r in routes if r["name"] == direction]
                    assert [r["document"]["page"] for r in parts] == [8, 10], parts
                    assert all(r["document"]["source-page"] == (8 if direction == "forward" else 10)
                               and r["document"]["target-page"] == (10 if direction == "forward" else 8)
                               for r in parts), parts
                typst("compile", "--input", "edges=off", source, out / "inline-bodies-without-edges.pdf")
                without, = json.loads(typst("eval", "--input", "edges=off", "--in", source,
                                           "--format", "json", "query(<test-result>).map(it => it.value)"))
                assert data == without, "Declaring connections changed live body geometry or destinations."
                assert json.loads(typst("eval", "--input", "edges=off", "--in", source, "--format", "json",
                                       "query(<inline-body-route>).len()")) == 0
            elif source.stem == "inline-body-containers":
                check_pdf_links(pdf, values(source)[0])
                routes = values(source, "<nested-inline-route>")
                assert len(routes) == len({r["name"] for r in routes}) == 9, routes
                assert all(r["document"]["source-page"] == r["document"]["target-page"] for r in routes), routes
            elif source.stem == "explicit-connections":
                routes = values(source, "<explicit-route>")
                assert len(routes) == 9, routes
                assert Counter(r["name"] for r in routes) == Counter(primary=1, repeat=1, **{"other-body": 1, "forward": 2, "backward": 2, "far-repeat": 2}), routes
                for direction in ("forward", "backward"):
                    assert [r["document"]["page"] for r in routes if r["name"] == direction] == [2, 4], routes
                assert [r["document"]["page"] for r in routes if r["name"] == "far-repeat"] == [1, 4], routes
                for r in routes:
                    doc = r["document"]
                    assert r["heads"] == [r["drawable"][0] and not doc["is-incoming"], r["drawable"][1] and not doc["is-outgoing"]], r
                    assert r["drawable"] == [bool(r["segments"])] * 2, r
                    assert doc["layer"] == ("background" if r["name"] in ("repeat", "backward", "far-repeat") else "foreground"), r
                    assert "connection" in doc, r
                empty = [r for r in routes if not r["segments"]]
                assert [(r["name"], r["document"]["page"], r["heads"]) for r in empty] == [("backward", 4, [False, False])], empty
            elif source.stem == "explicit-adapters":
                routes = values(source, "<explicit-adapter-route>")
                assert len(routes) == 11, routes
                assert len({r["name"] for r in routes}) == 11, routes
                assert all(r["document"]["source-page"] == r["document"]["target-page"] == r["document"]["page"] for r in routes)
            elif source.stem == "explicit-regions":
                routes = values(source, "<explicit-region-route>")
                assert [(r["name"], r["document"]["source-page"], r["document"]["target-page"]) for r in routes] == [("region", 3, 3), ("phantom", 4, 4)], routes
            elif source.stem == "connection-layers":
                routes = values(source, "<layer-route>")
                assert len(routes) == 32, routes
                for r in routes:
                    expected = "background" if r["name"].endswith("-2") and not r["name"].startswith("spill-") else "foreground"
                    if r["name"].startswith(("forward-", "backward-")):
                        expected = r["name"].split("-", 1)[1]
                    elif r["name"].startswith("spill-"):
                        expected = "background"
                    assert r["layer"] == expected, r
                for layer in ("foreground", "background"):
                    for direction in ("forward", "backward"):
                        assert [r["page"] for r in routes if r["name"] == f"{direction}-{layer}"] == [10, 11]
                assert [r["page"] for r in routes if r["name"] == "spill-3"] == [12, 13]
            elif source.stem == "repeat-wrap":
                data = json.loads(typst("eval", "--in", source, "--format", "json", """{
                  import "src/core/references.typ": _deixis-reference-sites
                  let sites = _deixis-reference-sites(destinations: true).values().flatten()
                  let corner = query(<deixis-occurrence-corner>).find(p => p.value.corner == "tl").location()
                  let early = query(<deixis-mark-occurrence>).first().location()
                  (count: sites.len(), actual: sites.first().position(), corner: corner.position(), early: early.position(),
                    destinations: ((page: corner.page(), x: corner.position().x.pt(), y: corner.position().y.pt()),))
                }"""))
                assert data["count"] == 1 and data["actual"] == data["corner"], data
                assert data["early"] != data["corner"], data
                check_pdf_links(pdf, data, minimum=4)
            elif source.stem == "repeat-geometry":
                data = json.loads(typst("eval", "--in", source, "--format", "json", """{
                  import "src/core/occurrences.typ": _deixis-occurrence-index
                  import "src/core/occurrences.typ": _deixis-occurrence-target
                  import "src/core/state.typ": deixis-system
                  import "src/routing/occurrences.typ": _deixis-occurrence-nodes
                  let nodes = _deixis-occurrence-nodes()
                  let origins = _deixis-occurrence-index()
                  let probes = query(<deixis-occurrence-corner>)
                  (nodes: nodes, origins: origins.values().map(s => s.keys()),
                    probes: probes.map(p => (data: p.value, position: p.location().position(), page: p.location().page(),
                      uid: _deixis-occurrence-target(deixis-system.final().registry.value, p.value.target))))
                }"""))
                assert sum(len(names) for names in data["origins"]) == 7, data
                nodes = [n for names in data["nodes"].values() for n in names.values()]
                assert len(nodes) == 6 and len(data["probes"]) == 24, data
                assert all(n["identity"]["occurrence"] != "hidden" for n in nodes)
                pt = lambda value: float(value.removesuffix("pt"))
                for node in nodes:
                    assert node["frame"] == "page" and len(node["ports"]) == 4, node
                    bounds = {k: pt(v) for k, v in node["bounds"].items()}
                    assert bounds["right"] > bounds["left"] and bounds["bottom"] > bounds["top"], node
                    probes = [p for p in data["probes"] if p["uid"] == node["identity"]["annotation"]
                              and p["data"]["name"] == node["identity"]["occurrence"]]
                    assert len(probes) == 4 and {p["data"]["corner"] for p in probes} == {"tl", "tr", "bl", "br"}
                    assert all(p["page"] == node["page"] for p in probes)
                    for axis, lo, hi in (("x", "left", "right"), ("y", "top", "bottom")):
                        coordinates = [pt(p["position"][axis]) for p in probes]
                        assert abs(bounds[lo] - min(coordinates)) < .001, node
                        assert abs(bounds[hi] - max(coordinates)) < .001, node
                    if node["identity"]["occurrence"] == "rotated":
                        assert bounds["bottom"] - bounds["top"] > 25, node
            elif source.stem == "implicit-connections":
                routes = values(source, "<implicit-route>")
                assert len(routes) == 15, routes
                for layer in ("foreground", "background", "flow"):
                    for kind in ("margin", "inset"):
                        assert sum(r["name"] == f"{kind}-{layer}" for r in routes) == 1
                for route_name, pages in (("forward", [4, 5]), ("backward", [4, 5]), ("spill-3", [6, 7])):
                    assert [r["document"]["page"] for r in routes if r["name"] == route_name] == pages
                for r in routes:
                    doc = r["document"]
                    assert (r["head-trims"][0] is not None) == (r["drawable"][0] and not doc["is-incoming"]), r
                    assert (r["head-trims"][1] is not None) == (r["drawable"][1] and not doc["is-outgoing"]), r
                    assert r["drawable"] == [bool(r["segments"])] * 2, r
                empty = [r for r in routes if not r["segments"]]
                assert [(r["name"], r["document"]["page"], r["head-trims"]) for r in empty] == [("backward", 5, [None, None])], empty
            elif source.stem == "layers":
                assert Counter(values(source, "<layer-event>")) == Counter(
                    ["native-background", "native-foreground", "user-background", "user-foreground"])
            elif source.stem == "z-order-placement":
                geometry = """{
                  let bodies = query(<deixis-body-destination>).map(m => (id: str(m.value.id),
                    page: m.location().page(), x: m.location().position().x.pt(), y: m.location().position().y.pt()
                  )).sorted(key: r => r.id)
                  let pins = query(<deixis-pin>).map(m => (name: m.value.name,
                    scope: m.value.scope, position: m.location().position())).sorted(key: r => (r.scope, r.name))
                  let frames = query(<deixis-body-frame>).map(m => (id: m.value.identity,
                    node: m.value.node)).sorted(key: r => r.id)
                  (bodies: bodies, pins: pins, frames: frames, prepared: query(<deixis-margin-connection>).len())
                }"""
                with_priority = json.loads(typst("eval", "--in", source, "--format", "json", geometry))
                without_priority = json.loads(typst("eval", "--input", "priority=off", "--in", source,
                                                  "--format", "json", geometry))
                assert with_priority == without_priority, (with_priority, without_priority)
                assert len(with_priority["bodies"]) == 6 and len(with_priority["pins"]) == 10, with_priority
                routes = values(source, "<z-placement-route>")
                plain = json.loads(typst("eval", "--input", "priority=off", "--in", source,
                                         "--format", "json", "query(<z-placement-route>).map(m => m.value)"))
                assert any(r["document"]["is-incoming"] for r in routes), routes
                for route in routes:
                    assert route["document"]["z-index"] == int(route["name"].split("-")[-1]) - 4, route
                for collection in (routes, plain):
                    for route in collection:
                        route["document"].pop("z-index")
                    collection.sort(key=lambda r: (r["name"], r["document"]["page"]))
                assert routes == plain, (routes, plain)
            elif source.stem in ("z-order-nested", "z-order-inheritance"):
                expected = json.loads(typst("eval", "--in", source, "--format", "json", """{
                  let bodies = query(<deixis-body-destination>).filter(m => {
                    let id = str(m.value.id)
                    id not in ("a", "b") and not id.starts-with("wrapper-")
                  })
                  (destinations: bodies.map(m => (page: m.location().page(),
                    x: m.location().position().x.pt(), y: m.location().position().y.pt())))
                }"""))
                check_pdf_links(pdf, expected, minimum=22 if source.stem == "z-order-nested" else 30)
            elif source.parent.name == "integration" and source.stem in ("z-order", "z-order-groups"):
                import xml.etree.ElementTree as ET
                if source.stem == "z-order":
                    expected = [
                        ["101010", "202020", "313131", "414141", "515151", "616161", "626262", "636363",
                         "717171", "727272", "a1a1a1", "818181", "919191"],
                        ["101010", "202020", "a1a1a1", "313131", "414141", "515151", "616161", "626262",
                         "636363", "717171", "727272", "818181", "919191"],
                    ]
                    routes = values(source, "<z-edge>")
                    assert len(routes) == 6, routes
                    assert all(r["priority"] == {"inset-edge": -3, "margin-edge": 3, "explicit": 4}[r["name"]]
                               for r in routes), routes
                    geometry = """{
                      let bodies = query(<deixis-body-destination>).map(m => (
                        id: if m.value.id == none { str(m.value.internal-id) } else { str(m.value.id) },
                        page: m.location().page(), x: m.location().position().x.pt(), y: m.location().position().y.pt()
                      )).sorted(key: r => r.id)
                      let frames = query(<deixis-body-frame>).map(m => (id: m.value.identity,
                        bounds: m.value.node.bounds)).sorted(key: r => r.id)
                      let slots = query(<deixis-reserver-left>).map(m => (id: str(m.value.id),
                        page: m.location().page(), x: m.location().position().x.pt(), y: m.location().position().y.pt(),
                        width: m.value.reserved-width.pt(), height: m.value.reserved-height.pt()
                      )).sorted(key: r => r.id)
                      (bodies: bodies, frames: frames, slots: slots, margin: query(<deixis-margin-connection>).len())
                    }"""
                    with_priority = json.loads(typst("eval", "--in", source, "--format", "json", geometry))
                    without_priority = json.loads(typst("eval", "--input", "priority=off", "--in", source,
                                                      "--format", "json", geometry))
                    assert with_priority == without_priority, (with_priority, without_priority)
                    assert with_priority["margin"] == 2, with_priority
                    assert len(with_priority["bodies"]) == 8, with_priority
                else:
                    expected = [["111111", "222222", "232323", "242424"],
                                ["313131", "323232", "333333", "343434", "353535"],
                                ["414141", "434343", "424242", "444444"]]
                swatches = {"#" + color for page in expected for color in page}
                typst("compile", source, out / (source.stem + "-{p}.svg"))
                for index, page in enumerate(expected, start=1):
                    tree = ET.parse(out / f"{source.stem}-{index}.svg")
                    colors = [elem.attrib["fill"] for elem in tree.getroot().iter()
                              if elem.attrib.get("fill") in swatches]
                    assert colors == ["#" + color for color in page], colors
            elif source.stem == "paint-commands":
                # The private queue must order actual drawings across kinds,
                # retain equal-priority ties, and emit each callback once.
                import xml.etree.ElementTree as ET
                svg = out / "paint-commands.svg"
                typst("compile", source, svg)
                colors = [elem.attrib.get("fill") for elem in ET.parse(svg).getroot().iter()]
                assert [c for c in colors if c in ("#123456", "#234567", "#345678")] == [
                    "#234567", "#123456", "#345678"], colors
            elif source.stem == "paint-order":
                # Check actual SVG paint sequence, independently of native query
                # ordering. Opaque swatches overlap at the same page position.
                import xml.etree.ElementTree as ET
                from itertools import groupby
                expected = [
                    ["101010", "202020", "314151", "415161", "425262", "435363", "506070",
                     "516171", "526272", "617181", "718191", "a1b1c1", "a2b2c2", "8191a1", "91a1b1"],
                    ["101010", "202020", "a1b1c1", "314151", "a2b2c2", "415161", "425262",
                     "435363", "506070", "516171", "526272", "617181", "718191", "8191a1", "91a1b1"],
                    ["101010", "202020", "a1b1c1", "b1c1d1", "b3c3d3", "b4c4d4", "b2c2d2", "8191a1", "91a1b1"],
                ]
                swatches = {"#" + color for page in expected for color in page}
                typst("compile", source, out / "paint-order-{p}.svg")
                for index, page in enumerate(expected, start=1):
                    tree = ET.parse(out / f"paint-order-{index}.svg")
                    colors = [elem.attrib["fill"] for elem in tree.getroot().iter()
                              if elem.attrib.get("fill") in swatches]
                    assert [color for color, _ in groupby(colors)] == ["#" + color for color in page], colors
                    # A two-digit marker uses its paint once per glyph. Every
                    # opaque rectangle still has exactly one live SVG painting.
                    counts = Counter(colors)
                    assert all(counts["#" + color] == 1 for color in page if color != "a2b2c2"), counts
            elif source.stem == "identity":
                result, = values(source)
                assert len(result["notes"]) == 8, result
                assert all(n["type"] is not None for n in result["notes"]), result
                assert len(result["labels"]) == 5, result
            elif source.stem == "page-notes":
                assert values(source) == [["endnote", "footnote"]]
            elif source.stem == "overlay-invisibility":
                assert values(source) == [28]
                typst("compile", "--input", "priority=on", source, out / "overlay-invisibility-priority.pdf")
                for priority in ("off", "on"):
                    typst("compile", "--input", "cover=on", "--input", f"priority={priority}",
                          source, out / f"overlay-invisibility-covered-{priority}.pdf")
                for priority in ("off", "on"):
                    for cover in ("off", "on"):
                        inputs = ("--input", "target=named", "--input", f"priority={priority}", "--input", f"cover={cover}")
                        typst("compile", *inputs, source, out / f"overlay-invisibility-named-{priority}-{cover}.pdf")
                        assert json.loads(typst("eval", *inputs, "--in", source, "--format", "json",
                                               "query(<test-result>).map(m => m.value)")) == [20]
            elif source.stem == "render-layers":
                result, = values(source)
                assert Counter((n["type"], n["layer"]) for n in result) == Counter(
                    (kind, layer) for kind in ("footnote", "margin-note", "inset-note")
                    for layer in ("flow", "foreground", "background")), result
                assert all(n["page"] == 1 for n in result), result
            elif source.stem == "margin-scopes":
                result, = values(source)
                assert len(result) == 4, result
                odd = next(n for n in result if n["page"] == 1)
                even = next(n for n in result if n["page"] == 2 and n["target"] == "page")
                assert odd["x"] > 350 and even["x"] < 100, result
            elif source.stem == "named-targets":
                text = subprocess.run(["pdftotext", str(pdf), "-"],
                                      capture_output=True, text=True, check=True).stdout
                for body in ("Forward thread body.", "Inside thread body.", "Backward thread body.",
                             "Synced block body.", "Forward phantom.", "Forward region body."):
                    assert text.count(body) == 1, text
                assert "10Syncedblockbody." in "".join(text.split()), text
            elif source.stem == "regions":
                assert values(source) == [[3]]
            elif source.stem == "regions-in-notes":
                # Inspect final geometry after compilation. Probing the painter's
                # own output inside the document adds an artificial layout pass.
                geometry = json.loads(typst("eval", "--in", source, "--format", "json", """{
                  let pins = query(<deixis-pin>)
                  let expected = query(<deixis-region-mark>).map(r => {
                    let active = pins.filter(p => p.value.name in r.value.pins)
                    let points = active.map(p => (page: p.location().page(),
                      pos: p.location().position(), pad: p.value.padding))
                    let l = calc.min(..points.map(p => (p.pos.x - p.pad.left).pt()))
                    let t = calc.min(..points.map(p => (p.pos.y - p.pad.top).pt()))
                    let r = calc.max(..points.map(p => (p.pos.x + p.pad.right).pt()))
                    let b = calc.max(..points.map(p => (p.pos.y + p.pad.bottom).pt()))
                    (page: points.first().page, x: l, y: t, width: r - l, height: b - t)
                  })
                  let actual = query(<nested-note-region>).map(s => (page: s.location().page(),
                    name: s.value.name,
                    x: s.location().position().x.pt(), y: s.location().position().y.pt(),
                    width: s.value.width.pt(), height: s.value.height.pt()))
                  let atoms = query(<annotated-atom>).map(a => (name: a.value.name, edge: a.value.edge,
                    page: a.location().page(), x: a.location().position().x.pt(), y: a.location().position().y.pt()))
                  (expected: expected, actual: actual, atoms: atoms)
                }"""))
                assert len(geometry["expected"]) == len(geometry["actual"]) == 9, geometry
                for expected in geometry["expected"]:
                    assert any(actual["page"] == expected["page"] and all(
                        abs(actual[key] - expected[key]) < .001 for key in ("x", "y", "width", "height"))
                        for actual in geometry["actual"]), (expected, geometry["actual"])
                # Independent content probes catch pins left on a previous line
                # when an inline math/code atom moves to the next line.
                assert len(geometry["atoms"]) == 18, geometry
                for actual in geometry["actual"]:
                    top = next(a for a in geometry["atoms"] if a["name"] == actual["name"] and a["edge"] == "top")
                    bottom = next(a for a in geometry["atoms"] if a["name"] == actual["name"] and a["edge"] == "bottom")
                    assert top["page"] == bottom["page"] == actual["page"], actual
                    assert abs(actual["x"] - (top["x"] - 3)) < .001, (actual, top)
                    assert abs(actual["y"] - (top["y"] - 3)) < .001, (actual, top)
                    assert abs(actual["x"] + actual["width"] - (bottom["x"] + 3)) < .001, (actual, bottom)
                    assert abs(actual["y"] + actual["height"] - (bottom["y"] + 3)) < .001, (actual, bottom)
            elif source.stem == "page-frames":
                result, = values(source)
                assert result["frames"] == [
                    {"page": 1, "width": 400, "height": 300, "left": 40, "top": 30},
                    {"page": 2, "width": 600, "height": 400, "left": 90, "top": 20},
                ], result
                assert result["note-pages"] == [1, 2], result
            elif source.stem == "auto-pages":
                from pypdf import PdfReader
                frames, = values(source)
                pages = PdfReader(pdf).pages
                assert len(pages) == len(frames) == 5
                for frame, page in zip(frames, pages):
                    assert abs(float(page.mediabox.width) - frame["width"]) < .01, frame
                    assert abs(float(page.mediabox.height) - frame["height"]) < .01, frame
            elif source.stem == "footnote-native":
                pages = subprocess.run(["pdftotext", "-layout", str(pdf), "-"],
                                       text=True, capture_output=True, check=True).stdout
                assert pages.count("Native-start.") == pages.count("Native-end.") == 1
                assert len(pages.rstrip("\f\n").split("\f")) >= 3, "Long native footnotes must paginate."
                assert "2Ordinarytwo." in "".join(pages.split()), "Custom footnotes must preserve native numbering."
            elif source.stem == "repeated-adapters":
                # Check final routed pages outside the live painter. Assertions
                # during transient page/identity resolution can suppress its
                # output and add a false convergence dependency.
                routes = values(source, "<repeat-route>")
                assert len(routes) == 6 and all(r["expected"] == r["source"] for r in routes), routes
            elif source.stem == "footnote-alignment":
                records, = values(source)
                assert len(records) == 6 and all(n["y"] <= 265.1 for n in records), records
            elif source.stem == "footnote-columns":
                result, = values(source)
                assert len(result["bodies"]) == 6 and all(n["y"] <= 455.1 for n in result["bodies"]), result
                assert any(x < 250 for x in result["marks"]) and any(x > 250 for x in result["marks"]), result
            elif source.stem == "reference-ranges":
                text = subprocess.run(["pdftotext", str(pdf), "-"],
                                      capture_output=True, text=True, check=True).stdout
                compact = "".join(text.split())
                for expected in ("Same:1–3.", "Duplicate:1.", "Supplement:Notes1–3.",
                                 "Empty:.", "Scopes:3,1,2.", "Series:1,2,3.",
                                 "Styles:A4,B5,C6.", "Override:4–6.", "Manual:7,8,9.",
                                 "Unprinted:1.", "Native:Section1."):
                    assert expected in compact, text
            elif source.stem == "reference-show-rules":
                text = subprocess.run(["pdftotext", str(pdf), "-"],
                                      capture_output=True, text=True, check=True).stdout
                compact = "".join(text.split())
                for expected in ("Native:Section1;Customheading;Figure1;Equation1;1.",
                                 "Normal:1.Callback:Collected1.Range:Collected1–3.",
                                 "Mixed:Note1,Heading1.Emptyprefix:1.",
                                 "Page:pageG.Aliaspage:AtG.Directpage:CollectedG.",
                                 "Nativepage:i.Markpage:i.Missingpage:?.Pendingsupplement:Pending?.Standalonepages:G,G.",
                                 "Pagelist:PagesG,G.",
                                 "Inherited:Collected1."):
                    assert expected in compact, text
                check_pdf_links(pdf, values(source)[0])
            elif source.stem == "repeated-marks":
                text = subprocess.run(["pdftotext", str(pdf), "-"],
                                      capture_output=True, text=True, check=True).stdout
                compact = "".join(text.split())
                for expected in ("Forward1.Primary1.Again1.Next2.", "Otherscope1.Local1", "Laterpage1.",
                                 "Phantomrepeated3.", "Regionrepeated4.", "LiteralrepeatedC.", "CustomRXanotherpassage."):
                    assert expected in compact, text
                check_pdf_links(pdf, values(source)[0])
            elif source.stem in ("compact-api", "identity-order", "identity-order-pages", "pdf-links",
                                 "endnote-collections", "outline-summaries", "reference-backlinks", "reference-adapters"):
                check_pdf_links(pdf, values(source)[0])
            elif source.stem == "anchoring":
                records, = values(source)
                assert len(records) == 3
                assert all(abs(r["dx"] - 25) < .1 and abs(r["dy"] - 20) < .1
                           and r["height"] > 20 for r in records), records
            elif source.stem == "touying-identities":
                check_touying_identities(typst, source, pdf, out)
            elif source.stem == "touying-contextual-blocks":
                for version in ("0.8.0", "0.6.3"):
                    for kind in ("inset", "margin", "footnote"):
                        for nested in ("off", "on"):
                            if (version, kind, nested) == ("0.8.0", "inset", "off"):
                                continue
                            typst("compile", "--input", f"touying-version={version}", "--input", f"kind={kind}",
                                  "--input", f"nested={nested}", source, out / f"contextual-{version}-{kind}-{nested}.pdf")
            elif source.stem == "touying-shared-notes":
                typst("compile", source, out / "touying-shared-notes-{p}.svg")
                # The native inline box on frame two paints four fill pieces;
                # the other two paths are its shared body and original region.
                for page, count in ((1, 2), (2, 6)):
                    svg = (out / f"touying-shared-notes-{page}.svg").read_text()
                    actual = svg.count('fill="#e8f3f6"')
                    assert actual == count, (page, actual, count)
            elif source.stem in ("omission", "omission-adapters"):
                text = subprocess.run(["pdftotext", str(pdf), "-"],
                                      capture_output=True, text=True, check=True).stdout
                assert "REMOVED" not in text, text
                expected = ("This Passage", "Forward Passage", "Original Passage", "Anonymous Passage",
                            "Inline Passage", "End Passage", "Margin Passage", "Inset Passage", "Region Passage",
                            "Visible Draft Body", "Visible Final Body") if source.stem == "omission" else (
                            "Kept Separate Passage", "Kept Repeated Passage", "Kept Nested Passage",
                            "Inner Passage", "Kept Parent Passage", "Visible Live Body")
                compact = "".join(text.split())
                for token in expected:
                    assert "".join(token.split()) in compact, (token, text)
            elif source.stem == "touying-omission":
                for version in ("0.8.0", "0.6.3"):
                    target = out / f"touying-omission-{version}.pdf"
                    typst("compile", "--input", f"touying-version={version}", source, target)
                    text = subprocess.run(["pdftotext", str(target), "-"],
                                          capture_output=True, text=True, check=True).stdout
                    pages = ["".join(p.split()) for p in text.rstrip("\f\n").split("\f")]
                    assert len(pages) == 2 and "REMOVED" not in text, pages
                    assert ["KeptPassage" in p for p in pages] == [False, True], pages
                    assert all("1VisibleBody" in p for p in pages), pages
                    assert "2AfterBody" in pages[1], pages
            elif source.stem == "touying-visibility":
                check_touying_visibility(typst, source, pdf, out)
            elif source.stem == "counter-slide-resets":
                for version in ("0.8.0", "0.6.3"):
                    inputs = ("--input", f"touying-version={version}")
                    slide_pdf = pdf if version == "0.8.0" else out / f"counter-slides-{version}.pdf"
                    if version != "0.8.0":
                        typst("compile", *inputs, source, slide_pdf)
                    marks = json.loads(typst("eval", *inputs, "--in", source, "--format", "json",
                                             "query(<deixis-inline-mark>).map(m => "
                                             "(page: m.location().page(), count: m.value.count))"))
                    assert marks == [{"page": page, "count": count}
                                     for page, counts in ((1, (1, 2)), (2, (1, 2)), (3, (1,)))
                                     for count in counts], marks
                    text = subprocess.run(["pdftotext", str(slide_pdf), "-"],
                                          capture_output=True, text=True, check=True).stdout
                    pages = ["".join(page.split()) for page in text.rstrip("\f\n").split("\f")]
                    assert len(pages) == 3, pages
                    assert all("First1Second2" in page for page in pages[:2]), pages
                    assert "Revealedtext." not in pages[0] and "Revealedtext." in pages[1], pages
                    assert "Restart1" in pages[2] and "1Newslidenote." in pages[2], pages
            elif source.stem == "touying":
                text = subprocess.run(["pdftotext", "-layout", str(pdf), "-"],
                                      capture_output=True, text=True, check=True).stdout
                pages = text.rstrip("\f\n").split("\f")
                assert len(pages) == 2
                assert all("Framefootnote." in "".join(p.split()) and "Framecallout." in "".join(p.split()) for p in pages)
                assert "Revealed slide content." not in pages[0] and "Revealed slide content." in pages[1]
                modern_pdf = out / "touying-0.8.pdf"
                typst("compile", "--input", "touying-version=0.8.0", source, modern_pdf)
                modern_text = subprocess.run(["pdftotext", str(modern_pdf), "-"],
                                             capture_output=True, text=True, check=True).stdout
                assert len(modern_text.rstrip("\f\n").split("\f")) == 2
            print(f"PASS {name}")
        except (AssertionError, subprocess.TimeoutExpired) as error:
            failures.append((name, str(error)))
            print(f"FAIL {name}: {error}", file=sys.stderr)

    # Each check runs its own Typst processes and writes only its own outputs.
    with ThreadPoolExecutor(max_workers=args.jobs) as pool:
        list(pool.map(check, sources))
    failures.sort()

    # A copied runtime must exclude development/documentation and retain its entrypoint.
    package = tomllib.loads((ROOT / "typst.toml").read_text())["package"]
    installed = packages / "preview" / package["name"] / package["version"]
    assert (installed / package["entrypoint"]).is_file()
    assert all(not (installed / directory).exists() for directory in ("tests", "docs", "develop", "target", ".git"))
    consumer = out / "consumer"
    consumer.mkdir(exist_ok=True)
    (consumer / "client.svg").write_text('<svg xmlns="http://www.w3.org/2000/svg" width="20" height="10"><rect width="20" height="10" fill="teal"/></svg>')
    (consumer / "main.typ").write_text(
        f'#import "@preview/{package["name"]}:{package["version"]}": *\n'
        '#let group = deixis-route-group(((from: (0pt, 0pt), to: (80pt, 0pt)),))\n'
        '#assert.eq(group.routes.first().status, "ok")\n'
        '#show: deixis-setup-notes\n'
        '#deixis-routing[\n'
        '#grid(columns: (auto, 30pt, auto), deixis-attach(id: <a>)[A], [], deixis-attach(id: <b>)[B])\n'
        '#deixis-connect(from: (node: <a>), to: (node: <b>), connector: (heads: "triangle"))\n'
        ']\n'
        '#let container(body, ..args) = block[#image("client.svg")#body]\n'
        '#deixis-footnote(layer: "flow", container-func: container)[External client.]\n')
    result = subprocess.run([args.typst, "compile", "--root", str(consumer), "--package-path", str(packages),
                             str(consumer / "main.typ"), str(consumer / "main.pdf")],
                            capture_output=True, text=True, timeout=30)
    assert result.returncode == 0 and not result.stderr, result.stderr
    print("PASS isolated installed consumer and caller-relative callback asset")
    (out / "results.json").write_text(json.dumps({"sources": len(sources), "failures": failures}, indent=2) + "\n")
    print(f"{len(sources) - len(failures)}/{len(sources)} compilation/behavior checks passed.")
    return bool(failures)


def check_touying_identities(typst, source, default_pdf, out):
    cases = [(kind, mark, "off", "page")
             for kind in ("inline", "endnote", "footnote", "margin", "inset")
             for mark in ("inline", "region", "phantom")]
    cases += [(kind, "inline", "on", "page")
              for kind in ("inline", "endnote", "footnote", "margin", "inset")]
    cases += [("inset", "inline", "off", domain) for domain in ("block", "thread")]
    for version in ("0.8.0", "0.6.3"):
        for kind, mark, cover, domain in cases:
            name = f"identities-{version}-{kind}-{mark}-{cover}-{domain}"
            inputs = ("--input", f"touying-version={version}", "--input", f"kind={kind}",
                      "--input", f"mark={mark}", "--input", f"cover={cover}", "--input", f"domain={domain}")
            pdf = default_pdf if (version, kind, mark, cover, domain) == ("0.8.0", "inset", "inline", "off", "page") else out / f"{name}.pdf"
            if pdf != default_pdf:
                typst("compile", *inputs, source, pdf)
            text = subprocess.run(["pdftotext", str(pdf), "-"], capture_output=True, text=True, check=True).stdout
            pages = ["".join(page.split()) for page in text.rstrip("\f\n").split("\f")]
            frame_count = 6 if domain == "page" else 2
            assert len(pages) == frame_count, (name, pages)
            visible = [cover == "off" or page % 2 == 0 for page in range(1, frame_count + 1)]
            assert ["FrameBody" in page for page in pages] == visible, (name, pages)
            assert all("1NativeOne" in page and "2NativeTwo" in page for page in pages), (name, pages)
            data = json.loads(typst("eval", *inputs, "--in", source, "--format", "json", """{
              (targets: query(<test-result>).first().value, edges: query(<frame-edge>).map(m => m.value),
                cases: query(<frame-case>).map(m => m.value))
            }"""))
            assert [case["frame"] for case in data["cases"]] == list(range(1, frame_count + 1)), (name, data)
            edge_count = 3 if kind in ("inset", "margin") else 2
            expected = [{"page": page, "source": page, "target": page}
                        for page, show in enumerate(visible, 1) if show for _ in range(edge_count)]
            assert sorted(data["edges"], key=lambda e: e["page"]) == expected, (name, data)
            check_pdf_links(pdf, data["targets"])
            if cover == "off":
                from pypdf import PdfReader
                reader = PdfReader(pdf)
                numbers = {page.indirect_reference.idnum: n for n, page in enumerate(reader.pages, 1)}
                cross = set()
                for origin, page in enumerate(reader.pages, 1):
                    for item in page.get("/Annots", []):
                        annotation = item.get_object()
                        dest = annotation.get("/Dest", annotation.get("/A", {}).get("/D"))
                        if hasattr(dest, "get_object"):
                            dest = dest.get_object()
                        if isinstance(dest, list) and numbers[dest[0].idnum] != origin:
                            cross.add((origin, numbers[dest[0].idnum]))
                expected_cross = ({(page, frame_count) for page in range(1, frame_count)}
                                  | {(frame_count, page) for page in range(1, frame_count)}
                                  | {(page, 1) for page in range(2, frame_count + 1)})
                assert cross == expected_cross, (name, cross)


def check_touying_visibility(typst, source, default_pdf, out):
    cases = [(kind, layer, "pause")
             for kind in ("footnote", "margin", "inset", "region", "repeat-region")
             for layer in ("flow", "foreground", "background")]
    cases += [(kind, "flow", "pause") for kind in ("inline", "endnote")]
    cases += [(kind, "foreground" if kind in ("footnote", "inset", "region") else "flow", mode)
              for kind in ("footnote", "inset", "region", "inline", "endnote")
              for mode in ("uncover", "only", "nested", "first")]
    cases += [(kind, "background", "first")
              for kind in ("footnote", "margin", "inset", "region", "repeat-region")]
    evidence = """{
      import "src/core/visibility.typ": _deixis-is-hidden
      let bodies = query(selector(<deixis-footnote>).or(<deixis-margin-note>)
        .or(<deixis-inset-note>).or(<deixis-inline-note>).or(<deixis-endnote>))
      let marks = query(selector(<deixis-inline-mark>).or(<deixis-phantom-mark>).or(<deixis-region-mark>))
      (outside: query(<visibility-outside>).map(m => (page: m.location().page(), hidden: _deixis-is-hidden(m.value))),
        marks: marks.map(m => (page: m.location().page(), count: m.value.count)),
        bodies: bodies.map(m => (page: m.location().page(), hidden: _deixis-is-hidden(m.value))),
        events: query(<visibility-body-event>).map(m => (page: m.location().page(), hidden: _deixis-is-hidden(m.value))),
        edges: query(<visibility-edge-event>).map(m => (page: m.location().page(), layer: m.value.layer)),
        shapes: query(<visibility-region-event>).map(m => m.location().page()))
    }"""
    for version in ("0.8.0", "0.6.3"):
        for kind, layer, mode in cases:
            name = f"visibility-{version}-{kind}-{layer}-{mode}"
            inputs = ("--input", f"touying-version={version}", "--input", f"kind={kind}",
                      "--input", f"layer={layer}", "--input", f"mode={mode}")
            pdf = default_pdf if (version, kind, layer, mode) == ("0.8.0", "footnote", "foreground", "pause") else out / f"{name}.pdf"
            if pdf != default_pdf:
                typst("compile", *inputs, source, pdf)
            text = subprocess.run(["pdftotext", str(pdf), "-"], capture_output=True, text=True, check=True).stdout
            pages = ["".join(page.split()) for page in text.rstrip("\f\n").split("\f")]
            assert len(pages) == 2, (name, pages)
            visible = [False, False] if mode == "nested" else [True, False] if mode == "first" else [False, True]
            region = kind in ("region", "repeat-region")
            token = "TargetPassage" if region else "TargetBody"
            assert [token in page for page in pages] == visible, (name, pages)
            assert all("1NativeIntro" in page and "2NativeTail" in page for page in pages), (name, pages)

            typst("compile", *inputs, source, out / f"{name}-{{p}}.svg")
            colors = ["#2b8c43"] if region else ["#a10b31"]
            if kind in ("margin", "inset"):
                colors.append("#125ba2")
            for page, show in enumerate(visible, 1):
                svg = (out / f"{name}-{page}.svg").read_text()
                for color in colors:
                    assert (color in svg) == show, (name, page, color)

            data = json.loads(typst("eval", *inputs, "--in", source, "--format", "json", evidence))
            assert data["outside"] == [{"page": page, "hidden": False} for page in (1, 2)], (name, data)
            declared_pages = [2] if mode == "only" and kind != "repeat-region" else [1, 2]
            assert data["marks"] == [{"page": page, "count": 1} for page in declared_pages], (name, data)
            shown_pages = [page for page, show in enumerate(visible, 1) if show]
            if region:
                shape_pages = declared_pages if layer == "flow" else shown_pages
                assert data["shapes"] == shape_pages and not data["events"] and not data["bodies"], (name, data)
            else:
                declarations = [{"page": page, "hidden": not visible[page - 1]} for page in declared_pages]
                assert data["bodies"] == declarations, (name, data)
                native_flow = kind == "inline" or (kind in ("margin", "inset") and layer == "flow")
                expected_events = declarations if native_flow else [{"page": page, "hidden": False} for page in shown_pages]
                assert data["events"] == expected_events, (name, data)
            expected_edges = [{"page": page, "layer": "foreground" if layer == "flow" else layer}
                              for page in shown_pages] if kind in ("margin", "inset") else []
            assert data["edges"] == expected_edges, (name, data)
    check_touying_cover_controls(typst, source, out)


def check_touying_cover_controls(typst, source, out):
    # A non-hiding cover remains visible. Its ordinary inherited text fill can
    # be captured; this does not promise arbitrary overlay cover effects.
    for version in ("0.8.0", "0.6.3"):
        for kind in ("footnote", "inset", "region"):
            inputs = ("--input", f"touying-version={version}", "--input", f"kind={kind}",
                      "--input", "cover=tint")
            pdf = out / f"visibility-tint-{version}-{kind}.pdf"
            typst("compile", *inputs, source, pdf)
            text = subprocess.run(["pdftotext", str(pdf), "-"], capture_output=True, text=True, check=True).stdout
            pages = ["".join(page.split()) for page in text.rstrip("\f\n").split("\f")]
            token = "TargetPassage" if kind == "region" else "TargetBody"
            assert len(pages) == 2 and all(token in page for page in pages), (version, kind, pages)
            data = json.loads(typst("eval", *inputs, "--in", source, "--format", "json", """{
              import "src/core/visibility.typ": _deixis-is-hidden
              let entries = query(selector(<deixis-footnote>).or(<deixis-inset-note>).or(<deixis-region-mark>))
              (outside: query(<visibility-outside>).map(m => _deixis-is-hidden(m.value)), entries: entries.map(m => (
                page: m.location().page(), hidden: _deixis-is-hidden(m.value),
                tinted: if m.value.render-context == none { none } else { m.value.render-context.text.fill == gray })))
            }"""))
            # Page footnotes follow the native footer typography, like std.footnote
            # under the same cover; other bodies capture the covered declaration.
            tints = (None, None) if kind == "footnote" else (True, False)
            assert data == {"outside": [False, False], "entries": [{"page": 1, "hidden": False, "tinted": tints[0]},
                                                    {"page": 2, "hidden": False, "tinted": tints[1]}]}, data


def check_finite_geometry(value):
    if isinstance(value, dict):
        for item in value.values():
            check_finite_geometry(item)
    elif isinstance(value, list):
        for item in value:
            check_finite_geometry(item)
    elif isinstance(value, float):
        assert math.isfinite(value), value
    elif isinstance(value, str) and value.endswith("pt"):
        assert math.isfinite(float(value[:-2])), value


def check_body_point_routes(routes, spans, cases=None):
    specifications = {c["name"]: c for c in cases} if cases else {}
    grouped = {}
    for route in routes:
        check_finite_geometry(route)
        name, doc = route["name"], route["document"]
        grouped.setdefault(name, []).append(doc)
        target = doc["connection"]["target"]
        pos = spans[target["annotation"]][target["point"]]
        assert doc["target-page"] == doc["nodes"]["body"]["page"] == pos["page"], route
        bounds = doc["nodes"]["body"]["bounds"]
        assert bounds["left"] == bounds["right"] == pos["x"], route
        assert bounds["top"] == bounds["bottom"] == pos["y"], route
        gap = specifications.get(name, {}).get("gap", 0)
        expected_layer = specifications.get(name, {}).get("layer", "foreground" if target["point"] == "start" else "background")
        assert doc["layer"] == expected_layer, route
        if doc["endpoints"]["body"]["role"] == "body":
            x, y = doc["endpoints"]["body"]["point"]
            assert abs(float(x[:-2]) - float(pos["x"][:-2]) + gap) < .001, route
            assert abs(float(y[:-2]) - float(pos["y"][:-2])) < .001, route
    for parts in grouped.values():
        expected = {parts[0]["source-page"], parts[0]["target-page"]}
        assert len(parts) == len(expected) and {p["page"] for p in parts} == expected, parts


def pdf_words(pdf):
    """Read actual painted words and glyph bounds, including clipped content."""
    xml = subprocess.run(["pdftotext", "-bbox", str(pdf), "-"],
                         text=True, capture_output=True, check=True).stdout
    ns = {"pdf": "http://www.w3.org/1999/xhtml"}
    return [[{"text": w.text or "", "x": float(w.attrib["xMin"]),
              "right": float(w.attrib["xMax"]), "y": float(w.attrib["yMin"]),
              "bottom": float(w.attrib["yMax"])} for w in p.findall(".//pdf:word", ns)]
            for p in ET.fromstring(xml).findall(".//pdf:page", ns)]


def check_pdf_links(pdf, expected, minimum=6):
    """Check actual PDF destinations, not only Typst's logical link elements."""
    try:
        from pypdf import PdfReader
    except ImportError as error:
        raise AssertionError("PDF link checks require pypdf: python3 -m pip install pypdf") from error
    reader = PdfReader(pdf)
    page_numbers = {page.indirect_reference.idnum: i + 1 for i, page in enumerate(reader.pages)}
    destinations = []
    for page in reader.pages:
        for ref in page.get("/Annots", []):
            annotation = ref.get_object()
            dest = annotation.get("/Dest", annotation.get("/A", {}).get("/D"))
            if hasattr(dest, "get_object"):
                dest = dest.get_object()
            if not isinstance(dest, list):
                continue
            assert dest[0].idnum in page_numbers, "Link points outside the PDF page tree."
            target_page = page_numbers[dest[0].idnum]
            x, y = float(dest[2]), float(dest[3])
            height = float(reader.pages[target_page - 1].mediabox.height)
            assert math.isfinite(x) and math.isfinite(y)
            destinations.append((target_page, x, height - y))
    assert len(destinations) >= minimum, "Expected mark/body, reference and backlink annotations."
    # Typst destinations include a native 10pt scroll offset above the anchor.
    for target in expected["destinations"]:
        assert any(page == target["page"] and abs(x - target["x"]) < 1
                   and abs(y + 10 - target["y"]) < 1 for page, x, y in destinations), target


if __name__ == "__main__":
    sys.exit(main())
