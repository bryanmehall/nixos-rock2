# TODO: modify to match: https://github.com/NixOS/nixpkgs/blob/master/pkgs/misc/uboot/default.nix
# TODO: add to above repository and import instead of defining here
{
  #buildUBoot,
  fetchFromGitHub,
  #rkbin,
}:
#buildUBoot rec {
rec {
  version = "2023.08.27";
  # https://github.com/radxa/u-boot/tree/next-dev-v2024.03
  src = fetchFromGitHub {
    owner = "radxa";
    repo = "u-boot";
    rev = "875ab5399d8fa48412b442e7d5029b69f0363a3e"; # branch - next-dev-v2024.03
    sha256 = "sha256-1NntZJlE70NEsnkvgCouMERUHUpPs02DtGMayMJSOAc=";
  };
  # https://github.com/radxa/u-boot/blob/875ab5399d8fa48412b442e7d5029b69f0363a3e/configs/rock-2a-rk3528_defconfig#L4
  #defconfig = "rock-2a-rk3528_defconfig";

  #extraMeta.platforms = ["aarch64-linux"];
  # This is defined in pkgs/rkbin/default.nix
  # from https://github.com/armbian/rkbin/tree/master
  # TODO: is armbian the best source or should we use nixpkgs.rkbin? under the hood nixpkgs uses the rockchip-linux repo which looks sketchier.
  #BL31 = "${rkbin}/rk3528_bl31_v1.17.elf";

  # buildPhase = ''
  #   make -j20 CROSS_COMPILE=aarch64-unknown-linux-gnu- \
  #     BL31=${rkbin}/rk3528_bl31_v1.17.elf \
  #     spl/u-boot-spl.bin u-boot.dtb u-boot.itb

  #   tools/mkimage -n rk3528 -T rksd -d \
  #     ${rkbin}/rk3588_ddr_lp4_2112MHz_lp5_2736MHz_v1.11.bin:spl/u-boot-spl.bin \
  #     idbloader.img
  # '';

  # filesToInstall = [
  #   "u-boot.itb"
  #   "idbloader.img"
  # ];
}
