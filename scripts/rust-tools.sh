#!/usr/bin/env bash
 
TOOLS=(
    cargo-clean-all
    cargo-nextest
)
 
echo "Installing cargo tools..."
 
for tool in "${TOOLS[@]}"; do
    echo "-> $tool"
    if ! cargo install "$tool"; then
        echo "WARNING: failed to install $tool, skipping"
    fi
done
 
echo "Done!"
