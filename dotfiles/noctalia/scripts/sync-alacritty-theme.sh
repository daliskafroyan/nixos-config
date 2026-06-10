#!/usr/bin/env sh

set -eu

theme_dir="$HOME/.config/alacritty"
mode="${NOCTALIA_THEME_MODE:-dark}"

case "$mode" in
  light)
    source_file="$theme_dir/theme-light.toml"
    ;;
  *)
    source_file="$theme_dir/theme-dark.toml"
    ;;
esac

rm -f "$theme_dir/theme-current.toml"
cp "$source_file" "$theme_dir/theme-current.toml"
