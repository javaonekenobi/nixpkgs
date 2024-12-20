let
  pkgs = import <irionixpkgs> {};
  fence = import ./fence-agents.nix { inherit (pkgs) stdenv lib pkgs fetchFromGitHub; };
in
  fence.overrideAttrs (oldAttrs: rec {
    configureFlags = oldAttrs.configureFlags or [] ++ [ "--sysconfdir=$out/etc" ];
  })
