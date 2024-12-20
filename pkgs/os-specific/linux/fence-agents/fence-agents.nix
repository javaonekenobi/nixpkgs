# This combines together OCF definitions from other derivations.
# https://github.com/ClusterLabs/fence-agents/blob/master/doc/dev-guides/ra-dev-guide.asc
{ stdenv
, lib
, pkgs
, fetchFromGitHub
}:

  stdenv.mkDerivation rec {
    pname = "fence-agents";
    version = "05fd299e094c6981b4c5b943dee03a29e78ee016";

    src = fetchFromGitHub {
      owner = "javaonekenobi";
      repo = pname;
      rev = "${version}";
      sha256 = "sha256-44LzxXQbc3NqqAtZgsp6ClTZIPkP9hHffc1DSkT3bCA=";
    };

    nativeBuildInputs = with pkgs; [
      autoreconfHook
      pkg-config
      (python311.withPackages (ps: [
	ps.pexpect
	ps.pycurl
	ps.requests
	ps.logging-journald
      ]))
      gawk
      libqb
      nss
      libxml2.dev
      libuuid
      libossp_uuid
      libxslt
      libvirt
      corosync
      pacemaker
      iputils
      bison
      flex
    ];

    buildInputs = with pkgs; [
      glib
      (python311.withPackages (ps: [
	ps.pexpect
	ps.pycurl
	ps.requests
	ps.logging-journald
      ]))
      gawk
      nettools
      libqb
      libvirt
      corosync
      pacemaker
      iputils
      which
      openiscsi
      lvm2
      nss
      libxml2.dev
      libuuid
      libossp_uuid
      bison
      flex
    ];

#    configureFlags = [ "--sysinitdir=/build/etc" ] ++ oldConfigureFlags;

    postUnpack = ''
      mkdir -pv $out/etc/conf.d
      mkdir -pv $out/etc/sysconfig
      mkdir -pv $out/etc/default
      date +%s > $NIX_BUILD_TOP/${src.name}/source_epoch
      echo "1.0" > $NIX_BUILD_TOP/${src.name}/.tarball-version
    '';

    preConfigure = ''
      export initconfdir=$out/etc
      echo "SOOKAH!! $initconfdir"
    '';

    env.NIX_CFLAGS_COMPILE = toString (lib.optionals (stdenv.cc.isGNU && lib.versionAtLeast stdenv.cc.version "12") [
      # Needed with GCC 12 but breaks on darwin (with clang) or older gcc
      "-Wno-error=maybe-uninitialized"
    ]);

#    postInstall = ''
#      mkdir -p $out/usr/lib/fence
#      ${lndir}/bin/lndir -silent "$out/lib/fence/" $out/usr/lib/fence
#      ${lndir}/bin/lndir -silent "${drbdForOCF}/usr/lib/fence/" $out/usr/lib/fence
#      ${lndir}/bin/lndir -silent "${pacemakerForOCF}/usr/lib/fence/" $out/usr/lib/fence
#    '';

    meta = with lib; {
      homepage = "https://github.com/ClusterLabs/fence-agents";
      description = "Combined repository of fence agents from the RHCS and Linux-HA projects";
      license = licenses.gpl2Plus;
      platforms = platforms.linux;
      maintainers = with maintainers; [ ryantm astro ];
    };
  }

