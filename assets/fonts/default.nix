{ pkgs }:
pkgs.stdenvNoCC.mkDerivation {
  name = "my-custom-fonts";
  src = ./.;
  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    find $src -type f \( -iname "*.ttf" -o -iname "*.otf" \) -exec cp {} $out/share/fonts/truetype/ \;
  '';
}
