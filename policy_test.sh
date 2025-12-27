#!/bin/bash

cd rust-bitcoin

#crates=("units" "primitives")
violations=false

#for crate in "${crates[@]}"; do
    violations=$(git diff "origin/master" '*.rs' | grep "^+" | grep -E "pub use self::" || true)
    if [[ -n "$violations" ]]; then
        echo "invalid import statement: '${violations:1}'"
    fi
#done

cd ..