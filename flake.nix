# SPDX-FileCopyrightText: 2026 Jiffly
# SPDX-License-Identifier: MIT OR Apache-2.0

{
  description = "JFU";

  inputs = {
    crane.url = "github:ipetkov/crane";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
  };

  outputs =
    {
      self,
      crane,
      fenix,
      flake-utils,
      nixpkgs,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ fenix.overlays.default ];
        };
        craneLib = (crane.mkLib pkgs).overrideToolchain (
          pkgs.fenix.stable.withComponents [
            "cargo"
            "rustc"
            "rustfmt"
            "clippy"
          ]
        );

        commonArgs = {
          src = pkgs.lib.fileset.toSource {
            root = ./.;
            fileset = pkgs.lib.fileset.unions [
              (craneLib.fileset.commonCargoSources ./.)
            ];
          };
          strictDeps = true;
        };

        cargoArtifacts = craneLib.buildDepsOnly (
          commonArgs
          // {
            cargoExtraArgs = "--workspace";
            pname = "jfu";
          }
        );

        cargoArtifactsDev = cargoArtifacts.overrideAttrs (
          final: prev: {
            CARGO_PROFILE = "dev";
          }
        );

        jfuClippy = craneLib.cargoClippy (
          commonArgs
          // {
            CARGO_PROFILE = "dev";
            cargoArtifacts = cargoArtifactsDev;
            cargoClippyExtraArgs = "--all-targets -- --deny warnings";
          }
        );

        jfuFmt = craneLib.cargoFmt commonArgs;

        jfuTest = craneLib.cargoTest (
          commonArgs
          // {
            CARGO_PROFILE = "dev";
            cargoArtifacts = cargoArtifactsDev;
          }
        );

        jfu = craneLib.buildPackage (
          commonArgs
          // {
            inherit cargoArtifacts;
          }
        );
        cExampleArgs = {
          src = pkgs.lib.fileset.toSource {
            root = ./.;
            fileset = pkgs.lib.fileset.unions [
              ./.clang-format
              ./.clang-tidy
              ./examples/c
            ];
          };
          nativeBuildInputs = [
            pkgs.llvmPackages_21.clang-tools
            pkgs.llvmPackages_21.clang
            pkgs.gcc
            pkgs.gnumake
          ];
        };

        cLint = pkgs.runCommand "jiffly-c-lint" cExampleArgs ''
          make -C "$src/examples/c" lint
          touch "$out"
        '';

        cTest = pkgs.runCommand "jiffly-c-test" cExampleArgs ''
          make -C "$src/examples/c" test CC=gcc BUILD_DIR="$TMPDIR/gcc"
          make -C "$src/examples/c" test CC=clang BUILD_DIR="$TMPDIR/clang"
          touch "$out"
        '';

      in
      {
        checks = {
          clippy = jfuClippy;
          test = jfuTest;
          fmt = jfuFmt;
          c-lint = cLint;
          c-test = cTest;
          reuse =
            pkgs.runCommand "jfu-reuse"
              {
                src = ./.;
                nativeBuildInputs = [ pkgs.reuse ];
              }
              ''
                cd $src
                reuse lint
                touch $out
              '';
        };

        packages = {
          default = jfu;
          ci_fmt = jfuFmt;
          ci_clippy = jfuClippy;
          ci_test = jfuTest;
          ci_c_lint = cLint;
          ci_c_test = cTest;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            pkgs.fenix.stable.toolchain
            just
            reuse
          ];
        };
      }
    );
}
