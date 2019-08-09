# This derivation can work either lorri or nix-shell
# → https://github.com/target/lorri

let
  myNixpkgsUrl = https://github.com/NixOS/nixpkgs.git;
  myNixpkgsRef = "master";
  # Look here for information about pinning Nixpkgs
  # → https://nixos.wiki/wiki/FAQ/Pinning_Nixpkgs
  pinnedVersion = builtins.fromJSON (builtins.readFile tools/nixpkgs-version.json);
  potpourri-dotfiles = builtins.fetchGit {
    url = https://github.com/Potpourri/dotfiles.git;
    rev = "75cf709077d51bb44d3fcc50360ba7440bda2053";
  };
  pinnedPkgs = import (builtins.fetchGit {
    inherit (pinnedVersion) url rev;
    ref = myNixpkgsRef;
  }) {
    # my overlay with latest versions of dependencies
    overlays = [ (import (potpourri-dotfiles + "/nixos/nixpkgs/overlays/potpourri-overlay.nix")) ];
  };
in

# This allows overriding pkgs by passing `--arg pkgs ...`
{ pkgs ? pinnedPkgs }:

with pkgs;

stdenv.mkDerivation rec {
  name = "lorri-shell";
  phases = [ "nobuildPhase" ];

  buildInputs = [
    # build dependencies
    # runtime dependencies
    ffmpeg_4
    imagemagick7
    # optional dependencies
    # developing tools
    git
    nix-prefetch-git
  ];

  PROJECT_ROOT = toString ./.;
  #WORKAROUND: lorri don't set runtime path to opengl drivers
  LD_LIBRARY_PATH = "/run/opengl-driver/lib";
  MY_NIXPKGS_URL = myNixpkgsUrl;
  MY_NIXPKGS_REF = myNixpkgsRef;

  nobuildPhase = ''
    echo
    echo "This derivation is not meant to be built, aborting"
    echo
    exit 1
  '';
}
