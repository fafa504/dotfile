#!/bin/bash

# Script created on Wed  3 Dec 03:15:26 +07 2025
mkrs() {
    if [ -z "$1" ]; then
        echo "Usage: mkrs <name>"
        return 1
    fi

    local name="$1"
    local file="${name%.rs}.rs"

    if [[ -e "$file" ]]; then
        echo "Error: $file already exists"
        return 1
    fi

    cat >"$file" <<'EOF'
#!/usr/bin/env rust-script

//! ```cargo
//! [dependencies]
//! anyhow = "1"
//! ```

fn main() {
    println!("Hello, world!");
    Ok(())
}
EOF

    chmod +x "$file"
    nvim "$file"
}

mkrs $1
