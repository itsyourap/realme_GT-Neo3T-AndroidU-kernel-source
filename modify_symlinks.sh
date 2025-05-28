#!/bin/bash

ROOT_DIR="${1:-.}"
REPLACEMENT="realme_GT-Neo3T-AndroidU-vendor-source"

find "$ROOT_DIR" -type l | while read -r symlink; do
    target=$(readlink "$symlink")

    # Skip if target doesn't contain /vendor/
    if [[ "$target" != *"/vendor/"* || "$target" != ../* ]]; then
        continue
    fi

    # Extract part before '/vendor/'
    prefix="${target%%/vendor/*}"
    suffix="${target#*/vendor/}"

    # Count how many ../ in the prefix
    count=$(grep -o '\.\./' <<< "$prefix" | wc -l)

    # Remove the final ../ before vendor and insert the replacement
    new_prefix=$(echo "$prefix" | awk -F'../' -v c=$((count - 1)) -v rep="../$REPLACEMENT" '{
        for (i = 1; i <= NF; i++) {
            if (i == c + 1) printf rep "/";
            else if (i < NF) printf "../"
        }
    }')

    new_target="${new_prefix%/}/vendor/$suffix"

    if [[ "$new_target" != "$target" ]]; then
        echo "Updating $symlink"
        echo "  Old → $target"
        echo "  New → $new_target"
        ln -snf "$new_target" "$symlink"
    fi
done

# Techpack symlinks
for dir in ../realme_GT-Neo3T-AndroidU-vendor-source/kernel/msm-4.19/techpack/*/; do
    ln -sfn "../$dir" "./techpack/$(basename "$dir")"
done