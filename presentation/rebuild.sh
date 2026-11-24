#!/usr/bin/env bash
# Run from any directory. Set the bundled runtime paths as documented in README.md.
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_dir"
: "${RUNTIME_NODE:?Set RUNTIME_NODE to the artifact runtime node executable}"
: "${RUNTIME_NODE_MODULES:?Set RUNTIME_NODE_MODULES to the bundled node_modules}"
RUNTIME_PYTHON="${RUNTIME_PYTHON:-python3}"
export HUST_BUILD
HUST_BUILD="$(mktemp -d "${TMPDIR:-/tmp}/hust38-rebuild.XXXXXX")"
mkdir -p "$HUST_BUILD/export"
ln -s "$RUNTIME_NODE_MODULES" "$HUST_BUILD/node_modules"
cp presentation/build.mjs presentation/story.mjs "$HUST_BUILD/"
template="Slide/HUST_PPT_template_2022_Blue_16x9.pptx"
base="CSDL_Nhom38_HUST_ThuyetTrinh"
"$RUNTIME_NODE" "$HUST_BUILD/build.mjs"
"$RUNTIME_PYTHON" presentation/apply_template.py "$template" "$HUST_BUILD/native.pptx" \
  "$HUST_BUILD/$base.pptx"
"${SOFFICE:-soffice}" "-env:UserInstallation=file://$HUST_BUILD/lo" \
  --headless --convert-to pdf --outdir "$HUST_BUILD/export" "$HUST_BUILD/$base.pptx"
"$RUNTIME_PYTHON" presentation/check_deck.py "$HUST_BUILD/$base.pptx" "$HUST_BUILD/export/$base.pdf"
printf 'Build output: %s\n' "$HUST_BUILD"
