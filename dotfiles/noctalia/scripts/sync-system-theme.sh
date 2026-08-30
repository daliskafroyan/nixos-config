#!/usr/bin/env sh

set -eu

mode="$(noctalia msg theme-mode-get)"

case "$mode" in
  dark)
    scheme="prefer-dark"
    ;;
  light)
    scheme="prefer-light"
    ;;
  *)
    exit 1
    ;;
esac


schema_dir="$(find "@gsettings-desktop-schemas@" -type f -name gschemas.compiled -printf "%h" -quit)"
GSETTINGS_SCHEMA_DIR="$schema_dir" "@glib@/bin/gsettings" set org.gnome.desktop.interface color-scheme "$scheme"
