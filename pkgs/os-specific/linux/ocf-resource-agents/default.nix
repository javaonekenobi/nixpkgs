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
, fence-agents
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
  fenceForOCF = fence-agents.override {
    forOCF = true;
  };

  resource-agentsForOCF = stdenv.mkDerivation rec {
#stdenv.mkDerivation rec {
    pname = "resource-agents";
#    version = "4.13.0";
#    version = "5f89f0942f17733c79de8bc9e9ce8e602ba03e7a";
    version = "6830df7dc32cc2cb2bf21527fd8a0fef29bfc5f9";


    src = fetchFromGitHub {
      owner = "ClusterLabs";
#      owner = "javaonekenobi";
      repo = pname;
      rev = "${version}";
      sha256 = "l8doEoqYx9l6sWiyQtEOjf6mBASuvkDvVyV3HSK5Hwc=";
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

    preConfigure = ''
      ./autogen.sh --prefix="$out"
    '';

    configureFlags = [
      "--localstatedir=/var"
    ];

    patchPhase = ''
# fix path in ocf-binaries
  sed -i heartbeat/ocf-binaries.in -e 's/PATH=".*"/PATH="\/run\/current-system\/sw\/bin:\/run\/current-system\/sw\/sbin:\/run\/current-system\/sw\/libexec:\/run\/wrappers\/bin"/'
# fix for "stray backspace before white space error in pacemaker.log"
  sed -i heartbeat/IPsrcaddr -e 's/\\ / /g'
  sed -i heartbeat/lxd.in -e 's/"Running"/"RUNNING"/'
  sed -i heartbeat/VirtualDomain -e 's/-f qcow2/& -F qcow2/'
  for i in $(find heartbeat -type f -exec grep -l '#!/bin/sh' {} \;); do sed -i $i -e 's/\/bin\/sh/\/usr\/bin\/env bash/'; done
#  sed -i configure.ac -e 's/^HA_RSCTMPDIR=.*/HA_RSCTMPDIR=\$out\/var\/run\/resource-agents/'
    '';

    preInstall = ''
  sed -i Makefile -e 's/\$(INSTALL) -d -m 1755 \$(DESTDIR)$(HA_RSCTMPDIR)//' 
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
#  }

in

# This combines together OCF definitions from other derivations.
# https://github.com/ClusterLabs/resource-agents/blob/master/doc/dev-guides/ra-dev-guide.asc
runCommand "ocf-resource-agents" {} ''
  mkdir -p $out/usr/lib/ocf
  mkdir -p $out/sbin
  ${lndir}/bin/lndir -silent "${resource-agentsForOCF}/lib/ocf/" $out/usr/lib/ocf
  ${lndir}/bin/lndir -silent "${drbdForOCF}/usr/lib/ocf/" $out/usr/lib/ocf
  ${lndir}/bin/lndir -silent "${pacemakerForOCF}/usr/lib/ocf/" $out/usr/lib/ocf
  ${lndir}/bin/lndir -silent "${fenceForOCF}/bin" $out/sbin
  ln -s ${pacemakerForOCF}/sbin/fence_watchdog $out/sbin
''
