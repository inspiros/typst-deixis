
/// ```warning
/// This is not a real function, added only for documentation purposes.
/// ```
/// 
/// This is a list of common arguments of note functions in the `deixis` package and their usage.
/// 
/// -> content
#let deixis-common-note-args(
  /// The type of mark to render in the text. Choices: `"inline"` | `"region"` | `"phantom"`.
  /// 
  /// This argument is present in all wrapper note functions @deixis-footnote, @deixis-endnote, @deixis-margin-note, and @deixis-inset-note.
  /// These note functions create both the mark and the body, and oftentimes it is ambiguous to infer which mark function to use internally.
  /// `mark-type` can then be used to specify this.
  /// 
  /// ```example
  /// #deixis-margin-note(
  ///   mark-type: "region",
  ///   padding: "text",
  ///   target: "page",
  /// )[$ e^(i pi) + 1 = 0 $][Euler's Identity.]
  /// ```
  /// 
  /// ```tip
  /// The allowed choices also include verbose names: `"inline-mark"` | `"region-mark"` | `"phantom-mark"`.
  /// ```
  /// 
  /// -> auto | str
  mark-type: auto,
  /// A unique identifier for linking a mark to a decoupled body.
  /// 
  /// ```example
  /// #deixis-inline-mark(id: <common-note.id>)[This is a standalone inline note.]
  /// #deixis-margin-note-body(id: <common-note.id>, target: "page")[This is a decoupled margin note body linked to the standalone inline note.]
  /// ```
  /// 
  /// ```info
  /// For celibate marks, if an `id` is given but the mark is linked to no body, the mark will be numbered with a marker but not clickable.
  /// ```
  /// 
  /// -> none | str | label
  id: none,
  /// The numbering style (used for the body and outline, though invisible here).
  /// 
  /// ```example
  /// #deixis-footnote(numbering: "i")[A note with roman numbering.]
  /// #deixis-footnote(numbering: "*")[A note with symbol numbering.]
  /// #deixis-footnote(numbering: it => std.numbering("(1.1)", counter(heading).get().first(), it))[A note with functional numbering.]
  /// ```
  /// 
  /// -> auto | str | function
  numbering: auto,
  /// The specific block/minipage counter context a mark belongs to, or a specific render context a note body belongs to.
  /// - If `"page"`, the note will be a page-level note regardless of where it is.
  /// ```example
  /// #deixis-footnote(target: "page")[This is a page-level footnote.]
  /// #deixis-margin-note(target: "page")[This is a page-level margin note.]
  /// ```
  /// - If a `label` id of a @deixis-block is provided, the note will be rendered as part of that block.
  ///   This is especially usefull for footnote and margin note.
  /// ```example
  /// #deixis-footnote(target: <common-note.target>)[This footnote is targeted at the gray block.]
  /// #deixis-block(
  ///   id: <common-note.target>,
  ///   fill: gray.lighten(50%),
  ///   inset: 0.1em)
  /// External notes can target a block *regardless* of their relative position being before or after the block.
  /// #deixis-footnote(target: <common-note.target>)[And so is this footnote.]
  /// ```
  /// - If a *non-positive* `int` is provided, the target will be resolved based on the current stack level.
  ///   For example, value of `0` means this current block/minipage, a value of `-1` means the parent block/minipage, and so on.
  /// - An `auto` is intepreted as `0` in mark functions and to _inherit_ the target of the mark in body functions.
  /// 
  /// ```tip
  /// - For mark-only note functions (e.g. @deixis-inline-mark and @deixis-region-mark), `target` decides which counter system the note uses. The mark is always placed where it is called.
  /// - For body-only note functions (e.g. @deixis-margin-note-body or @deixis-inset-note-body), `target` decides where to render the body.
  /// ```
  /// 
  /// -> auto | int | label | str
  target: 0,
  /// The counter series this note belongs to.
  /// 
  /// For grouped notes like footnote, notes from the same series are also grouped together.
  /// 
  /// ```example
  /// This is a translation note#deixis-footnote(series: "trans", numbering: "*")[Old Latin: 'Salvé'.].
  /// This is a general comment#deixis-footnote(series: "comm", numbering: "1")[Added by the editor.].
  /// Another translation note#deixis-footnote(series: "trans", numbering: "*")[Modern: 'Hello'.].
  /// And another comment#deixis-footnote(series: "comm", numbering: "1")[Added by the reviewer.].
  /// ```
  /// 
  /// -> str
  series: "default",
  /// A hardcoded marker override.
  /// 
  /// One can also use `numbering: it => content` to replace the marker with any content they want, `marker` is just a short-hand syntactic sugar.
  /// 
  /// ```example
  /// #deixis-footnote(marker: emoji.gear)[A note with _gear_ marker.]
  /// ```
  /// 
  /// -> auto | content
  marker: auto,
  /// The border stroke applied to the mark, the note body, and/or the link.
  /// -> auto | stroke | none
  stroke: auto,
  /// The background fill color applied to the mark and/or the note body.
  /// -> auto | color | none
  fill: auto,
  /// The border radius applied to the mark, the note body, and/or the link.
  /// -> auto | length | dictionary
  radius: auto,
  /// The type of connector line. Choices: `"none"` | `"straight-line"` | `"right-angle"` | `"chamfer"` | `"curve"` | `"ucr"` | `"ccr"`.
  /// 
  /// See @deixis-set.link.
  /// 
  /// -> auto | str
  link: auto,
  /// An array of intermediate coordinate offsets to route the connector line through.
  /// 
  /// Waypoints allow you to manually detour the link around obstacles or create custom geometric paths.
  /// The array can mix several types of instructions to build complex paths:
  /// - Relative coordinates (`array`): Offsets relative to the previous point in the path.
  /// - Component keywords (`"mark"` | `"body"`): offsets to the respective component's absolute coordinates.
  ///   - Component keywords can be mixed with `alignment` keywords like `"body-top-left"` to offset to a corner of that component.
  /// - Link types (`"none"` | `"straight-line"` | `"right-angle"` | `"curve"` | `"ucr"` | `"ccr"`): Changes link type mid-path.
  /// - `"split"`: A reserved keyword for splitting the paths of spoiled notes, which have marks and bodys lying in different pages. It can also be put in a tuple:
  ///   - `("split", "mark")`: Spills at the x-coordinate of the mark.
  ///   - `("split", "body")`: Spills at the x-coordinate of the body.
  ///   - `("split", "center")`: Spills at the center x-coordinates of the mark and the body.
  ///   - `("split", 10pt)`: Spills at a x-offset relative to the previous position in the path.
  /// 
  /// ```example
  /// //| sandbox-mode: "page"
  /// #deixis-inset-note(
  ///   stroke: green,
  ///   fill: green.transparentize(95%),
  ///   link: "curve",
  ///   link-waypoints: ((10pt, 40pt), (10pt, -10pt), (10pt, 20pt), (10pt, -20pt)),
  ///   dx: 6em, dy: 3em,
  /// )[Note mark.][Note body.]
  /// ```
  /// 
  /// ```example
  /// //| sandbox-mode: "page"
  /// #deixis-inset-note(
  ///   stroke: green,
  ///   fill: green.transparentize(95%),
  ///   link: "right-angle",
  ///   link-waypoints: ((40pt, 40pt), "curve", ("body-top-center", -25pt)),
  ///   dx: 6em, dy: 3em,
  /// )[Note mark.][Note body.]
  /// ```
  /// 
  /// -> none | array
  link-waypoints: none,
  /// Defines the exact exit/entry ports for the connector line.
  /// 
  /// ```example
  /// //| sandbox-mode: "page"
  /// #deixis-inset-note(
  ///   stroke: green,
  ///   fill: green.transparentize(95%),
  ///   link: "right-angle",
  ///   link-ports: (mark: bottom, body: top),
  ///   dx: 4em, dy: 3em,
  /// )[Note mark.][Note body.]
  /// ```
  /// 
  /// ```info
  /// The available ports for @deixis-region-mark and any note body are:
  /// - `left` | `right` | `top` | `bottom`.
  /// The available ports for @deixis-inline-mark are:
  /// - If `marker-position: right`: `right` | `top` | `bottom`.
  /// - If `marker-position: left`: `left` | `top` | `bottom`.
  /// 
  /// If `auto`, the ports are automatically selected based on the relative positions of the mark and the body, or based on the first & last waypoint coordinates if `link-waypoints` is provided.
  /// ```
  /// 
  /// 
  /// -> auto | array | dictionary
  link-ports: auto,
  /// The arrowhead style for the connector line. Choices: `"none"` | `"mark"` | `"body"` | `"both"`.
  /// 
  /// See @deixis-set.link-marks.
  /// 
  /// -> auto | str
  link-marks: auto,
  /// The width of the inset note body.
  /// -> auto | length | relative
  /// A custom render function for the inner layout of the body.
  /// 
  /// See @deixis-set.render-single.
  /// 
  /// -> auto | function
  render-single: auto,
  /// A custom container wrapper for the body block.
  /// 
  /// See @deixis-set.container-func.
  /// 
  /// -> auto | function
  container-func: auto,
  /// Positional arguments are parsed in the following order: `[mark][body]`.
  /// - `[mark]`: the marked content to be highlighted.
  /// - `[body]`: the content of the note body.
  /// All named arguments are forwarded along with `stroke`, `fill`, `radius` as styles to the container.
  /// 
  /// ```example
  /// #import "@preview/colorful-boxes:1.4.3": outline-colorbox
  /// 
  /// #let colorbox-container(body, title: none, stroke: none, fill: none, radius: 0pt, centering: false, ..args) = outline-colorbox(
  ///   title: title,
  ///   color: (fill: fill, stroke: stroke.paint),
  ///   radius: radius,
  ///   centering: centering,
  /// )[#body]
  /// 
  /// #deixis-inline-note-body(
  ///   container-func: colorbox-container,
  ///   // all these parameters are passed to colorbox-container
  ///   stroke: blue,
  ///   fill: blue.transparentize(90%),
  ///   title: [Colorful Note],
  ///   centering: true
  /// )[A note with custom conainer.]
  /// ```
  /// 
  /// -> arguments
  ..args,
) = none
