# This combines together OCF definitions from other derivations.
# https://github.com/ClusterLabs/fence-agents/blob/master/doc/dev-guides/ra-dev-guide.asc
{ stdenv
, lib
, pacemaker
, runCommand
, lndir
, pkgs
, fetchFromGitHub
}:

let
  pacemakerForOCF = pacemaker.override {
    forOCF = true;
  };

  resource-fenceForOCF = stdenv.mkDerivation rec {
    pname = "fence-agents";
#    version = "05fd299e094c6981b4c5b943dee03a29e78ee016";
    version = "HEAD";

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
#      pacemaker
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
#      pacemaker
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

    patchPhase = ''
      # fix path in fence-agents
      ls -alR $NIX_BUILD_TOP/source
      sed -i $NIX_BUILD_TOP/source/tests/test-apc5.py -e 's/\/usr//g' -e 's/\/bin/\/run\/current-system\/sw\/bin/g'
      sed -i $NIX_BUILD_TOP/source/tests/fence_testing.py -e 's/\/usr//g' -e 's/\/bin/\/run\/current-system\/sw\/bin/g'
      sed -i $NIX_BUILD_TOP/source/tests/test-drac4.py -e 's/\/usr//g' -e 's/\/bin/\/run\/current-system\/sw\/bin/g'
      sed -i $NIX_BUILD_TOP/source/lib/tests/test_fencing.py -e 's/\/usr//g' -e 's/\/bin/\/run\/current-system\/sw\/bin/g'
      sed -i $NIX_BUILD_TOP/source/lib/fencing.py.py -e 's/\/usr//g' -e 's/\/bin/\/run\/current-system\/sw\/bin/g'
      sed -i $NIX_BUILD_TOP/source/tests/test-multi-apc2.py -e 's/\/usr//g' -e 's/\/bin/\/run\/current-system\/sw\/bin/g'
      sed -i $NIX_BUILD_TOP/source/tests/test-apc2.py -e 's/\/usr//g' -e 's/\/bin/\/run\/current-system\/sw\/bin/g'
      sed -i $NIX_BUILD_TOP/source/tests/test.py -e 's/\/usr//g' -e 's/\/bin/\/run\/current-system\/sw\/bin/g'
      sed -i $NIX_BUILD_TOP/source/tests/fence_testing_test.py -e 's/\/usr//g' -e 's/\/bin/\/run\/current-system\/sw\/bin/g'
      sed -i $NIX_BUILD_TOP/source/agents/virsh/fence_virsh.py -e 's/\/usr//g' -e 's/\/bin/\/run\/current-system\/sw\/bin/g'
      sed -i $NIX_BUILD_TOP/source/agents/vmware/fence_vmware.py -e 's/\/usr//g' -e 's/\/bin/\/run\/current-system\/sw\/bin/g'
      sed -i $NIX_BUILD_TOP/source/tests/data/metadata/fence_vbox.xml -e 's/\/usr//g' -e 's/\/bin/\/run\/current-system\/sw\/bin/g'
      sed -i $NIX_BUILD_TOP/source/tests/data/metadata/fence_virsh.xml -e 's/\/usr//g' -e 's/\/bin/\/run\/current-system\/sw\/bin/g'
      sed -i $NIX_BUILD_TOP/source/tests/data/metadata/fence_ironic.xml -e 's/\/usr//g' -e 's/\/bin/\/run\/current-system\/sw\/bin/g'
      sed -i $NIX_BUILD_TOP/source/agents/vbox/fence_vbox.py -e 's/\/usr//g' -e 's/\/bin/\/run\/current-system\/sw\/bin/g'
      sed -i $NIX_BUILD_TOP/source/agents/amt/fence_amt.py -e 's/\/usr//g' -e 's/\/bin/\/run\/current-system\/sw\/bin/g'
      sed -i $NIX_BUILD_TOP/source/agents/autodetect/autodetect_test.py -e 's/\/usr//g' -e 's/\/bin/\/run\/current-system\/sw\/bin/g'
      sed -i $NIX_BUILD_TOP/source/agents/autodetect/fence_apc.py -e 's/\/usr//g' -e 's/\/bin/\/run\/current-system\/sw\/bin/g'
      sed -i $NIX_BUILD_TOP/source/agents/autodetect/fence_brocade.py -e 's/\/usr//g' -e 's/\/bin/\/run\/current-system\/sw\/bin/g'
      sed -i $NIX_BUILD_TOP/source/agents/autodetect/fence_ilo_moonshot.py -e 's/\/usr//g' -e 's/\/bin/\/run\/current-system\/sw\/bin/g'
      sed -i $NIX_BUILD_TOP/source/agents/autodetect/fence_bladecenter.py -e 's/\/usr//g' -e 's/\/bin/\/run\/current-system\/sw\/bin/g'
      sed -i $NIX_BUILD_TOP/source/agents/autodetect/autodetect.py -e 's/\/usr//g' -e 's/\/bin/\/run\/current-system\/sw\/bin/g'
      sed -i $NIX_BUILD_TOP/source/agents/autodetect/fencing.py -e 's/\/usr//g' -e 's/\/bin/\/run\/current-system\/sw\/bin/g'
      sed -i $NIX_BUILD_TOP/source/agents/autodetect/fence_lpar.py -e 's/\/usr//g' -e 's/\/bin/\/run\/current-system\/sw\/bin/g'
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
  };

in

# This combines together OCF definitions from other derivations.
# https://github.com/ClusterLabs/resource-agents/blob/master/doc/dev-guides/ra-dev-guide.asc
runCommand "ocf-resource-agents" {} ''
  mkdir -p $out/usr/lib/ocf
  ${lndir}/bin/lndir -silent "${resource-agentsForOCF}/lib/ocf/" $out/usr/lib/ocf
  ${lndir}/bin/lndir -silent "${pacemakerForOCF}/usr/lib/ocf/" $out/usr/lib/ocf
''
