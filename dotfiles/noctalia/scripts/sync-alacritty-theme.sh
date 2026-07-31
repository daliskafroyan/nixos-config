#!/usr/bin/env sh

set -eu

theme_dir="$HOME/.config/alacritty"

rm -f "$theme_dir/theme-current.toml"
cp "$theme_dir/theme-dark.toml" "$theme_dir/theme-current.toml"
