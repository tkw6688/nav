#!/usr/bin/env bash
# Regenerate vendor.css and bundle.js from source files.
# Run from repo root: ./tools/bundle.sh
# Safe to re-run; output is deterministic.

set -euo pipefail

# Concatenate files with a guaranteed newline between them, so a missing
# trailing newline cannot merge two source files' boundary lines together.
concat() {
  local out="$1"
  shift
  : > "$out"
  local f
  for f in "$@"; do
    cat "$f" >> "$out"
    printf '\n' >> "$out"
  done
}

# --- vendor.css -------------------------------------------------------------
# Order matters (later files override earlier ones).
concat assets/css/vendor.css \
  assets/css/fonts/linecons/css/linecons.css \
  assets/css/fonts/fontawesome/css/font-awesome.min.css \
  assets/css/bootstrap.css \
  assets/css/xenon-core.css \
  assets/css/xenon-components.css \
  assets/css/xenon-skins.css

# The two icon-font stylesheets originally lived in nested directories, so
# their url(...) paths are written relative to those directories. vendor.css
# sits in assets/css/, so rewrite the font paths to the new location.
sed -i "s|url('../font/|url('fonts/linecons/font/|g" assets/css/vendor.css
sed -i "s|url('../fonts/fontawesome-webfont|url('fonts/fontawesome/fonts/fontawesome-webfont|g" assets/css/vendor.css

# --- bundle.js --------------------------------------------------------------
# Order matters: jQuery is loaded separately, before this bundle.
concat assets/js/bundle.js \
  assets/js/bootstrap.min.js \
  assets/js/TweenMax.min.js \
  assets/js/resizeable.js \
  assets/js/joinable.js \
  assets/js/xenon-api.js \
  assets/js/xenon-toggles.js \
  assets/js/xenon-custom.js \
  assets/js/lozad.js

echo "Regenerated assets/css/vendor.css ($(wc -c < assets/css/vendor.css) bytes) and assets/js/bundle.js ($(wc -c < assets/js/bundle.js) bytes)"
