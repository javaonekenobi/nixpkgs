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
, unixtools
, openiscsi
, python311Packages
}:

let
  drbdForOCF = drbd.override {
    forOCF = true;
  };
  pacemakerForOCF = pacemaker.override {
    forOCF = true;
  };

  resource-agentsForOCF = stdenv.mkDerivation rec {
    pname = "resource-agents";
    version = "4.13.0";

    src = fetchFromGitHub {
      owner = "ClusterLabs";
      repo = pname;
      rev = "v${version}";
      sha256 = "sVOuC5bP9Y0tZIod0h+4/URuqCy2oG/B2EAxaRBvzo8=";
    };

    nativeBuildInputs = [
      autoreconfHook
      pkg-config
      python311
      gawk
      libqb
      which
      unixtools.ping
      openiscsi
      python311Packages.logging-journald
    ];

    buildInputs = [
      glib
      python311
      gawk
      nettools
      libqb
      which
      unixtools.ping
      openiscsi
      python311Packages.logging-journald
    ];

    patchPhase = ''
      substituteInPlace heartbeat/ocf-binaries.in \
        --replace "/bin/ping" "ping"
      substituteInPlace heartbeat/ocf-binaries.in \
        --replace "test -x" "echo \"irio bin \$bin\" >> /var/log/pacemaker/pacemaker.log; which \$bin >> /var/log/pacemaker/pacemaker.log 2>&1; echo "irio iscsiadm" >> /var/log/pacemaker/pacemaker.log; which iscsiadm >> /var/log/pacemaker/pacemaker.log 2>&1; test -x"
    '';

    env.NIX_CFLAGS_COMPILE = toString (lib.optionals (stdenv.cc.isGNU && lib.versionAtLeast stdenv.cc.version "12") [
      # Needed with GCC 12 but breaks on darwin (with clang) or older gcc
      "-Wno-error=maybe-uninitialized"
    ]);

    meta = with lib; {
      homepage = "https://github.com/ClusterLabs/resource-agents";
      description = "Combined repository of OCF agents from the RHCS and Linux-HA projects";
      license = licenses.gpl2Plus;
      platforms = platforms.linux;
      maintainers = with maintainers; [ ryantm astro ];
    };
  };

in

# This combines together OCF definitions from other derivations.
# https://github.com/ClusterLabs/resource-agents/blob/master/doc/dev-guides/ra-dev-guide.asc
runCommand "ocf-resource-agents" {} ''
  mkdir -p $out/usr/lib/ocf
  ${lndir}/bin/lndir -silent "${resource-agentsForOCF}/lib/ocf/" $out/usr/lib/ocf
  ${lndir}/bin/lndir -silent "${drbdForOCF}/usr/lib/ocf/" $out/usr/lib/ocf
  ${lndir}/bin/lndir -silent "${pacemakerForOCF}/usr/lib/ocf/" $out/usr/lib/ocf
''
