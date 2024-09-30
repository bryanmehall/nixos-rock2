# NixOS running on RK3528
Adapted from: https://github.com/ryan4yin/nixos-rk3588

Build for aarch64 from x86_64 host:

`nix build .#sdImage-rock2-cross`

Build for aarch64 from aarch64 host:

`nix build .#sdImage-rock2`