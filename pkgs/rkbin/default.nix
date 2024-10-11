{
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "3";
  version = "0.0.1";

  # https://github.com/armbian/rkbin/tree/master
  src = fetchFromGitHub {
    owner = "armbian";
    repo = "rkbin";
    rev = "12657ed7c65f16f89e6bd5ea82ca670d3324fc70";
    sha256 = "sha256-1NntZJlE70NEsnkvgCouMERUHUpPs02DtGMayMJSOAc=";
  };

  installPhase = ''
    mkdir $out && cp rk35/rk3528* $out/
  '';
}
