#import "@preview/deixis:0.2.0": *
#set page(width: 350pt, height: 285pt, margin: 20pt)
#set text(size: 10pt)
#show: deixis-setup-notes
= Choosing A Routing Policy

#v(14pt)
#grid(columns: (50pt, 70pt, 55pt), column-gutter: 55pt,
  deixis-attach(id: <source>)[#rect(width: 50pt, height: 40pt)[Source]],
  deixis-attach(behavior: "avoid", rect(width: 35pt, height: 100pt,
    fill: luma(230), stroke: none)),
  deixis-attach(id: <target>)[#rect(width: 55pt, height: 40pt)[Target]],
)

#show: deixis-routing.with(policy: "manual")
#deixis-connect(from: (node: <source>), to: (node: <target>),
  connector: (stroke: red + 1pt, heads: "triangle"))

#show: deixis-routing.with(policy: "avoid")
#deixis-connect(from: (node: <source>), to: (node: <target>),
  connector: (stroke: blue + 2pt, heads: "triangle"))

#show: deixis-routing.with(policy: "separate")
#deixis-connect(from: (node: <source>), to: (node: <target>),
  connector: (stroke: orange + 0.6pt, heads: "triangle"))

Each show rule selects the policy for subsequent declarations. Red uses native
geometry, blue avoids registered objects, and orange also enables separation
from connectors in its group. Separate scopes plan independently: orange can
still overlap blue. Bind a reusable policy with `deixis-routing.with(...)`.
