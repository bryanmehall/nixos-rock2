{
  description = "A minimal NixOS configuration for the Radxa Rock2 (RK3528A)";

  inputs = {
    nixpkgs.url = "git+file:../nixpkgs"; #"github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # For CI checks
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        flake-compat.follows = "";
      };
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    pre-commit-hooks,
    ...
  }: let
    # Local system's architecture, the host you are running this flake on.
    localSystem = "x86_64-linux";
    # The native system of the target SBC.
    aarch64System = "aarch64-linux";
    pkgsNative = import nixpkgs {system = aarch64System;};

    # Cross-compilation toolchain for building on the local system.
    pkgsCross = import nixpkgs {
      inherit localSystem;
      crossSystem = aarch64System;
    };
  in
    {
      nixosModules = {
        # Rock 2 Model A SBC
        rock2 = {
          core = import ./modules/boards/rock2.nix;
          sd-image = ./modules/sd-image/rock2.nix;
        };
      };

      nixosConfigurations =
        # sdImage - boot via U-Boot - fully native
        (builtins.mapAttrs (name: board:
          nixpkgs.lib.nixosSystem {
            system = aarch64System; # native or qemu-emulated
            specialArgs.rk3588 = {
              inherit nixpkgs;
              pkgsKernel = pkgsNative;
            };
            modules = [
              ./modules/configuration.nix
              board.core
              board.sd-image

              {
                networking.hostName = name;
                sdImage.imageBaseName = "${name}-sd-image";
              }
            ];
          })
        self.nixosModules)
        # sdImage - boot via U-Boot - fully cross-compiled
        // (nixpkgs.lib.mapAttrs'
          (name: board:
            nixpkgs.lib.nameValuePair
            (name + "-cross")
            (nixpkgs.lib.nixosSystem {
              system = localSystem; # x64
              specialArgs.rk3588 = {
                inherit nixpkgs;
                pkgsKernel = pkgsCross;
              };
              modules = [
                ./modules/configuration.nix
                board.core
                board.sd-image

                {
                  networking.hostName = name;
                  sdImage.imageBaseName = "${name}-sd-image";

                  # Use the cross-compilation toolchain to build the whole system.
                  nixpkgs.crossSystem.config = "aarch64-unknown-linux-gnu";
                }
              ];
            }))
          self.nixosModules);
      # UEFI system, boot via edk2-rk3588 - fully native
      # // (nixpkgs.lib.mapAttrs'
      #   (name: board:
      #     nixpkgs.lib.nameValuePair
      #     (name + "-uefi")
      #     (nixpkgs.lib.nixosSystem {
      #       system = aarch64System; # native or qemu-emulated
      #       specialArgs.rk3588 = {
      #         inherit nixpkgs;
      #         pkgsKernel = pkgsNative;
      #       };
      #       modules = [
      #         board.core
      #         ./modules/configuration.nix
      #         {
      #           networking.hostName = name;
      #         }

      #         nixos-generators.nixosModules.all-formats
      #       ];
      #     }))
      #   self.nixosModules);
    }
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      packages = {
        # sdImage aarch64 host
        sdImage-rock2 = self.nixosConfigurations.rock2.config.system.build.sdImage;

        # sdImage x86_64 host
        sdImage-rock2-cross = self.nixosConfigurations.rock2-cross.config.system.build.sdImage;

        # UEFI raw image
        rawEfiImage-rock2 = self.nixosConfigurations.rock2-uefi.config.formats.raw-efi;
      };

      devShells.fhsEnv =
        # the code here is mainly copied from:
        #   https://nixos.wiki/wiki/Linux_kernel#Embedded_Linux_Cross-compile_xconfig_and_menuconfig
        (pkgs.buildFHSUserEnv {
          name = "kernel-build-env";
          targetPkgs = pkgs_: (with pkgs_;
            [
              # we need theses packages to make `make menuconfig` work.
              pkg-config
              ncurses
              # arm64 cross-compilation toolchain
              pkgsCross.gccStdenv.cc
              # native gcc
              gcc
            ]
            ++ pkgs.linux.nativeBuildInputs);
          runScript = pkgs.writeScript "init.sh" ''
            # set the cross-compilation environment variables.
            export CROSS_COMPILE=aarch64-unknown-linux-gnu-
            export ARCH=arm64
            export PKG_CONFIG_PATH="${pkgs.ncurses.dev}/lib/pkgconfig:"
            exec bash
          '';
        })
        .env;

      devShells.default = pkgs.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
      };

      checks.pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          # nix
          deadnix.enable = true;
          alejandra.enable = true;
          statix.enable = true;
        };
      };
    });
}
