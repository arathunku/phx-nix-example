{
  description = "Build dependencies for phx-nix";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.mixOverlay = {
    url = "github:hauleth/nix-elixir";
    flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, mixOverlay }:
    let
    in flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import mixOverlay) (import ./nix/overlay.nix) ];
        pkgs = import nixpkgs { inherit system overlays; };
        release = import ./nix/release.nix { inherit self pkgs; };
        packages = with pkgs;
          # This is currently optional because nix flake check fails for darwin
          { } // lib.attrsets.optionalAttrs stdenv.isLinux { image = release.image; };
      in rec {
        inherit packages;
        defaultPackage = release.build;
        apps = {
          demo_phx = flake-utils.lib.mkApp {
            drv = release.build;
            name = "demo_phx";
          };
        };
        defaultApp = apps.demo_phx;
        # running this via nix flake check takes a lot of time
        # a single check can be executed via:
        # nix run .#checks.x86_64-linux.shellcheck
        checks = {
          shellcheck = pkgs.runCommand "shellcheck" {
            buildInputs = with pkgs; [ shellcheck ];
          } ''
            mkdir $out
            shellcheck --shell bash ${./bin}/*
          '';
        };

        inherit (pkgs) devShell;
      });
  # TODO: run mix format as check
  # TODO: run mix compile --warnings-as-errors as check
}
