{stdenv}: let
  #prebuilt from radxa uboot with the commands:
  # make -j16 SHELL=/nix/store/m001fhkgdgxf1cd46j176bqy51swk51c-bash-interactive-5.2p32/bin/bash DTC=/nix/store/qrkn0sq916qpx0dx8z5v9x69h5p1hnir-dtc-1.7.1/bin/dtc CROSS_COMPILE=aarch64-unknown-linux-gnu- idbloader.img
  #
  #./tools/mkimage -n rk3528 -T rksd -d ../../../rkbin/bin/rk35/rk3528_ddr_1056MHz_v1.09.bin:spl/u-boot-spl.bin idbloader.img
  idbloader_img = ./linux-u-boot-legacy-rock-2a/idbloader.img;
  u_boot_itb = ./linux-u-boot-legacy-rock-2a/u-boot.itb;
in
  stdenv.mkDerivation {
    pname = "u-boot-prebuilt";
    version = "unstable-2023-08-27";

    buildCommand = ''
      install -Dm444 ${idbloader_img} $out/idbloader.img
      install -Dm444 ${u_boot_itb} $out/u-boot.itb
    '';
  }
