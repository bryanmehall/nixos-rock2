# TODO not working yet!
{
  # TODO: modify to match: https://github.com/NixOS/nixpkgs/blob/master/pkgs/misc/uboot/default.nix
  lib,
  buildUBoot,
  fetchFromGitHub,
  rkbin-rk3588,
}:
(buildUBoot rec {
  version = "2023.08.27";

  # https://github.com/radxa/u-boot/tree/next-dev-v2024.03
  src = fetchFromGitHub {
    owner = "radxa";
    repo = "u-boot";
    rev = "875ab5399d8fa48412b442e7d5029b69f0363a3e"; # branch - next-dev-v2024.03
    sha256 = "";
  };

  # https://github.com/radxa/u-boot/blob/stable-5.10-rock5/configs/rock-5a-rk3588s_defconfig
  defconfig = "rock-2a-rk3528_defconfig";

  extraMeta.platforms = ["aarch64-linux"];
  BL31 = "${rkbin-rk3588}/rk3588_bl31_v1.38.elf";

  buildPhase = ''
    make -j20 CROSS_COMPILE=aarch64-unknown-linux-gnu- \
      BL31=${rkbin-rk3588}/rk3588_bl31_v1.38.elf \
      spl/u-boot-spl.bin u-boot.dtb u-boot.itb

    tools/mkimage -n rk3588 -T rksd -d \
      ${rkbin-rk3588}/rk3588_ddr_lp4_2112MHz_lp5_2736MHz_v1.11.bin:spl/u-boot-spl.bin \
      idbloader.img
  '';

  filesToInstall = [
    "spl/u-boot-spl.bin"

    "u-boot.itb"
    "idbloader.img"
  ];
})
.overrideAttrs (oldAttrs: {
  patches = []; # remove all patches, which is not compatible with thead-u-boot
})
