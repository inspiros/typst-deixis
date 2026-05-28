for f in examples/*.typ; do filename=$(basename "$f" .typ); typst compile "$f" "assets/gallery/${filename}-{p}.svg" --root "."; done
