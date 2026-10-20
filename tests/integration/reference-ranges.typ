#import "../../src/lib.typ": *
#set page(width: 500pt, height: 520pt, margin: 40pt)
#set heading(numbering: "1.")
#show: deixis-setup-notes
#let plain(it) = it
#deixis-set(marker-style: plain)
One#deixis-inline-mark(id: <a1>).
Two#deixis-inline-mark(id: <a2>).
Three#deixis-inline-mark(id: <a3>).

Same: #deixis-ref(<a3>, <a1>, <a2>).
Duplicate: #deixis-ref(<a1>, <deixis-mark-id-a1>, <a1>).
Supplement: #deixis-ref(<a3>, <a1>, <a2>)[Notes].
Empty: #deixis-ref()#deixis-ref[Notes]#deixis-ref(supplement: [Notes]).

#for (i, id) in (<scope-a>, <scope-b>, <scope-c>).enumerate() {
  deixis-block[
    #deixis-update-note-counter(i)
    Scope#deixis-inline-mark(id: id).
  ]
}
Scopes: #deixis-ref(<scope-c>, <scope-a>, <scope-b>).

#for (i, series) in ("first", "second", "third").enumerate() {
  deixis-update-note-counter(i, series: series)
  [Series#deixis-inline-mark(id: label(series), series: series).]
}
Series: #deixis-ref(<first>, <second>, <third>).

#let a(it) = [A#it]
#let b(it) = [B#it]
#let c(it) = [C#it]
#for (id, style) in ((<style-a>, a), (<style-b>, b), (<style-c>, c)) {
  deixis-block(sync-counters-with: "page")[
    #deixis-set(marker-style: (inline-mark: style))
    Styled#deixis-inline-mark(id: id).
  ]
}
Styles: #deixis-ref(<style-a>, <style-b>, <style-c>).
Override: #deixis-ref(<style-a>, <style-b>, <style-c>, marker-style: plain).

#for (id, marker) in ((<manual-a>, "7"), (<manual-b>, "8"), (<manual-c>, "9")) {
  [Manual#deixis-inline-mark(id: id, marker: marker).]
}
Manual: #deixis-ref(<manual-a>, <manual-b>, <manual-c>).

#deixis-endnote(id: <unprinted>)[This body is not collected.]
Unprinted: #deixis-ref(<unprinted>).

= A native heading <heading>
Native: @heading.
