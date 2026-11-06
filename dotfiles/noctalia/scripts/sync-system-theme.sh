#!/usr/bin/env sh

set -eu

mode="$(noctalia msg theme-mode-get)"

case "$mode" in
  dark)
    scheme="prefer-dark"
    gtk_theme="Gruvbox-Dark"
    icon_theme="oomox-gruvbox-dark"
    ;;
  light)
    scheme="prefer-light"
    gtk_theme="Gruvbox-Light"
    icon_theme="Adwaita"
    ;;
  *)
    exit 1
    ;;
esac

schema_dir="$(find "@gsettings-desktop-schemas@" -type f -name gschemas.compiled -printf "%h" -quit)"
gsettings="@glib@/bin/gsettings"

GSETTINGS_SCHEMA_DIR="$schema_dir" "$gsettings" set org.gnome.desktop.interface color-scheme "$scheme"
GSETTINGS_SCHEMA_DIR="$schema_dir" "$gsettings" set org.gnome.desktop.interface gtk-theme "$gtk_theme"
GSETTINGS_SCHEMA_DIR="$schema_dir" "$gsettings" set org.gnome.desktop.interface icon-theme "$icon_theme"
