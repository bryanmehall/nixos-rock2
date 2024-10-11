# NixOS running on RK3528
Adapted from: https://github.com/ryan4yin/nixos-rk3588

Build for aarch64 from x86_64 host:

`nix build .#sdImage-rock2-cross`

Build for aarch64 from aarch64 host:

`nix build .#sdImage-rock2`

# TODO: 
1. test on hardware
2. build u-boot from source my using the nixpkgs.uboot package and adding the changes from here: https://github.com/rockchip-linux/u-boot/commit/c6f7c1a39273d4a2c47f6a2c847984ada1bc6ce3 to uboot upstream
3. remove unneeded drivers from kernal config
4. clean up nix expressions and imports
