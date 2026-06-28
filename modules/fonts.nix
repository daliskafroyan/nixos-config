{ pkgs, ... }:

let
  ioskeleyMono = pkgs.stdenvNoCC.mkDerivation {
    pname = "ioskeley-mono";
    version = "2.0.0";

    src = pkgs.fetchzip {
      url = "https://github.com/ahatem/IoskeleyMono/releases/download/v2.0.0/IoskeleyMono.zip";
      hash = "sha256-EJDlA18XZPq7vhtpw/74n5s1NmTy0/DLu2oYB7OuvbA=";
      stripRoot = false;
    };

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/share/fonts/truetype
      cp $src/Normal/Unhinted/*.ttf $out/share/fonts/truetype/
    '';
  };
in
{
  fonts.packages = with pkgs; [
    ioskeleyMono
    ibm-plex
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    font-awesome
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  fonts.fontconfig.defaultFonts = {
    serif = [ "IBM Plex Serif" "Noto Serif CJK JP" ];
    sansSerif = [ "IBM Plex Sans" "Noto Sans CJK JP" ];
    monospace = [ "Ioskeley Mono" "Symbols Nerd Font Mono" "Noto Sans Mono CJK JP" ];
    emoji = [ "Noto Color Emoji" ];
  };
}
