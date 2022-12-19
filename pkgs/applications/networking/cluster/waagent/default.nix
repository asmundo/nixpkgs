{ coreutils,
  findutils,
  gnugrep,
  gawk,
  iproute2,
  iptables,
  makeWrapper,
  nettools, # for hostname
  openssh,
  openssl,
  parted,
  procps, # for pidof,
  shadow, # for useradd, usermod
  util-linux, # for (u)mount, fdisk, sfdisk, mkswap
  python3,
  lib,
  fetchFromGitHub,
}:

let
  inherit (lib) makeBinPath;
  inherit (python3.pkgs)
    pythonPackages
    distro
  ;

in
python3.pkgs.buildPythonPackage rec {
  pname = "waagent";
  version = "2.8.0.11";
  src = fetchFromGitHub {
    owner = "Azure";
    repo = "WALinuxAgent";
    rev = "04ded9f0b708cfaf4f9b68eead1aef4cc4f32eeb";
    sha256 = "0fvjanvsz1zyzhbjr2alq5fnld43mdd776r2qid5jy5glzv0xbhf";
  };
  doCheck = false;

  buildInputs = [ distro ];
  nativeBuildInputs = [
    makeWrapper
    pythonPackages.wrapPython
  ];
  runtimeDeps = [
    coreutils
    findutils
    gawk
    gnugrep
    iproute2
    iptables
    nettools # for hostname
    openssh
    openssl
    parted
    procps # for pidof
    shadow # for useradd, usermod
    util-linux # for (u)mount, fdisk, sfdisk, mkswap
  ];

  fixupPhase = ''
     mkdir -p $out/sbin/
     WAAGENT=$(find $out -name waagent | grep sbin)
     cp $WAAGENT $out/sbin/waagent
     wrapProgram "$out/sbin/waagent" \
         --prefix PYTHONPATH : $PYTHONPATH \
         --prefix PATH : "${makeBinPath runtimeDeps}"
     patchShebangs --build "$out/sbin/"
  '';

  meta = {
    description = "The Microsoft Azure Linux Agent (waagent)
                   manages Linux provisioning and VM interaction with the Azure
                   Fabric Controller";
    homepage = "https://github.com/Azure/WALinuxAgent";
    license = with lib.licenses; [ asl20 ];
  };

}
