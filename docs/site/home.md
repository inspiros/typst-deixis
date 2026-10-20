<div class="deixis-cover">
<img class="deixis-wordmark" src="../../assets/logos/deixis-logo-horizontal.svg" width="320" alt="Deixis">
<p class="deixis-kicker">Notes · Highlights · Connections</p>

# The Deixis Guide

<p class="deixis-lead">Mark a passage. Share its explanation. Draw the relationship.</p>

Keep the main argument readable, with explanations where they belong.
Deixis brings footnotes, margin notes, passage highlights, and connections to
Typst documents and presentation slides.

<p class="deixis-edition"><span class="deixis-badge">Development 0.2.0</span> <span class="deixis-badge free">Typst 0.15.0+</span></p>

<div class="deixis-actions">
<a class="deixis-button" href="../guides/getting-started.md">Start Reading</a>
<a class="deixis-button secondary" href="../manual.pdf">Download The Manual</a>
</div>

This guide describes the **unreleased 0.2.0 checkout**. Follow
[installation](../guides/installation.md) before trying its examples;
Typst Universe currently serves 0.1.1.

</div>

## Keep The Detail Close

![Two colored margin notes, a shared explanation, and a native footnote.](../assets/first-notes.svg)

<p class="deixis-caption">One annotation can serve several passages. Each explanation keeps its own identity, number, and accent.</p>

## A First Annotation

```typst
#import "@preview/deixis:0.2.0": *
#show: deixis-setup-notes

A useful result#deixis-footnote[A short explanation.]
is easier to read when its details have a place.
```

A wrapper creates the mark and explanation together. Use a public name when
several passages should share one note, or when you need to refer to it later.

## Choose Your Next Step

<div class="deixis-cards">
<div class="deixis-card">

### Read By Task

Choose a note, share an explanation, set its appearance, or annotate a slide.

[Find a guide](../README.md)

</div>
<div class="deixis-card">

### Compare Examples

See complete source beside real output, from native footnotes to routed drawings.

[Browse worked examples](../examples/README.md)

</div>
<div class="deixis-card">

### Look Up An API

Check signatures, defaults, setup requirements, and links to the relevant guide.

[Open the API reference](../reference/README.md)

</div>
</div>
