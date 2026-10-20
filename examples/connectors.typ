#import "@preview/deixis:0.2.0": *
#set page(width: 560pt, height: 370pt, margin: (x: 105pt, y: 42pt))
#set text(size: 11pt)
#show: deixis-setup-notes

= Start With A Connector

A single option connects a note to its mark:
#deixis-margin-note(connector: "curve")[A curve with automatic ports and placement.]
#raw("link: \"curve\"", block: true, lang: "typc")

#v(22pt)
Add an arrow when the direction matters:
#deixis-margin-note(connector: (route: "curve", heads: "stealth"))[The arrow points toward the note.]
#raw("connector: (route: \"curve\", heads: \"stealth\")", block: true, lang: "typc")

#v(22pt)
Choose another route just as easily:
#deixis-margin-note(connector: "orthogonal")[An orthogonal route uses horizontal and vertical segments.]
#raw("link: \"orthogonal\"", block: true, lang: "typc")

#v(22pt)
A small dictionary is enough for a different head:
#deixis-margin-note(connector: (route: "curve", heads: (body: "circle")))[A circle at the note end.]
#raw("connector: (route: \"curve\",\n  heads: (body: \"circle\"))", block: true, lang: "typc")
