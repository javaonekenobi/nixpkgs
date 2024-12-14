# This combines together OCF definitions from other derivations.
# https://github.com/ClusterLabs/resource-agents/blob/master/doc/dev-guides/ra-dev-guide.asc
{ stdenv
, lib
, runCommand
, lndir
, fetchFromGitHub
, autoreconfHook
, pkg-config
, python311
, glib
, drbd
, pacemaker
, gawk
, nettools
, libqb
, which
, openiscsi
, python311Packages
, lvm2
}:

let
  drbdForOCF = drbd.override {
    forOCF = true;
  };
  pacemakerForOCF = pacemaker.override {
    forOCF = true;
  };

  resource-agentsForOCF = stdenv.mkDerivation rec {
    pname = "fence-agents";
    version = "05fd299e094c6981b4c5b943dee03a29e78ee016";


    src = fetchFromGitHub {
#      owner = "ClusterLabs";
      owner = "javaonekenobi";
      repo = pname;
#      rev = "v${version}";
      rev = "${version}";
      sha256 = "edfcc6c15371308fce3601674b926fde43004fb4a4d34dfc7bc81be7f85b0b97";
    };

    nativeBuildInputs = [
      autoreconfHook
      pkg-config
      python311
      gawk
      libqb
    ];

    buildInputs = [
      glib
      python311
      gawk
      nettools
      libqb
      which
      openiscsi
      python311Packages.logging-journald
      lvm2
    ];

    env.NIX_CFLAGS_COMPILE = toString (lib.optionals (stdenv.cc.isGNU && lib.versionAtLeast stdenv.cc.version "12") [
      # Needed with GCC 12 but breaks on darwin (with clang) or older gcc
      "-Wno-error=maybe-uninitialized"
    ]);

    meta = with lib; {
      homepage = "https://github.com/ClusterLabs/fence-agents";
      description = "Combined repository of fence agents from the RHCS and Linux-HA projects";
      license = licenses.gpl2Plus;
      platforms = platforms.linux;
      maintainers = with maintainers; [ ryantm astro ];
    };
  };

in

# This combines together fence definitions from other derivations.
# https://github.com/ClusterLabs/resource-agents/blob/master/doc/dev-guides/ra-dev-guide.asc
runCommand "fence-agents" {} ''
  mkdir -p $out/usr/lib/fence
  ${lndir}/bin/lndir -silent "${fence-agentsForOCF}/lib/fence/" $out/usr/lib/fence
  ${lndir}/bin/lndir -silent "${drbdForOCF}/usr/lib/fence/" $out/usr/lib/fence
  ${lndir}/bin/lndir -silent "${pacemakerForOCF}/usr/lib/fence/" $out/usr/lib/fence
''
