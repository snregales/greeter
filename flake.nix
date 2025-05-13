{
  description = "A Rust CLI greeting application with system date/time info";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    naersk.url = "github:nix-community/naersk/master";
    utils.url = "github:numtide/flake-utils";
    git-hooks.url = "github:cachix/git-hooks.nix";
  };

  outputs = {
    self,
    nixpkgs,
    naersk,
    utils,
    git-hooks,
  }:
    utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      package = (pkgs.callPackage naersk {}).buildPackage ./.;
      pre-commit-check = git-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          typos.enable = true;
          alejandra.enable = true;
          rustfmt.enable = true;
          clippy = {
            enable = true;
            packageOverrides = {
              inherit (pkgs) cargo clippy;
            };
            settings.allFeatures = true;
          };
          eclint.enable = true;
        };
        settings.rust.check.cargoDeps = pkgs.rustPlatform.importCargoLock {
          lockFile = ./Cargo.lock;
        };
      };
    in {
      packages.default = package;
      devShells.default = pkgs.mkShell {
        inherit (pre-commit-check) shellHook;
        buildInputs = pre-commit-check.enabledPackages;
      };
      checks = {inherit pre-commit-check;};

      apps.default = {
        type = "app";
        program = "${package}/bin/greeter";
        meta = (pkgs.lib.importTOML ./Cargo.toml).package;
      };
    });
}
