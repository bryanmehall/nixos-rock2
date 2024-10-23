# NixOS running on RK3528
Adapted from: https://github.com/ryan4yin/nixos-rk3588

## Build instructions
1. If you don't already have nix installed, install it: https://nixos.org/download/
2. The package can either be cross compiled form an `x86_64` host or compiled on the target architecture (`aarch64`)
    * Build from `x86_64` host:
    `nix build .#sdImage-rock2-cross`
    * Build from `aarch64` host:
    `nix build .#sdImage-rock2`

3. Nix will create the image in the `result/sd-image` directory when the build is complete

# TODO:
This package is currently incomplete. 
1. test on hardware
2. build u-boot from source by using the nixpkgs.uboot package and adding the changes from here: https://github.com/rockchip-linux/u-boot/commit/c6f7c1a39273d4a2c47f6a2c847984ada1bc6ce3 to uboot upstream
3. remove unneeded drivers from kernal config
4. clean up nix expressions and imports
