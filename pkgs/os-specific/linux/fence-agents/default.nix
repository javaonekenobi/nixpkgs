let
  pkgs = import <nixpkgs> {};
#  fence = import ./fence-agents.nix { inherit (pkgs) stdenv lib lndir fetchFromGitHub autoreconfHook pkg-config python310 glib drbd pacemaker gawk nettools libqb which openiscsi lvm2 nss libxml2 libuuid libxslt libvirt corosync iputils bison flex; };
  fence = import ./fence-agents.nix { inherit (pkgs) stdenv lib pkgs fetchFromGitHub; };
in
  fence.overrideAttrs (oldAttrs: rec {
    configureFlags = oldAttrs.configureFlags or [] ++ [ "--sysconfdir=$out/etc" ];
#   configureFlags = oldAttrs.configureFlags or [] ++ [ "--help" ];
    culo
  })
