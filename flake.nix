{
  description = "vad devshell";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # localstack is broken right now (2023-01-25) in unstable, due to a missing dependency
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in
      {
        devShells.default = pkgs.mkShell rec {
          packages = with pkgs; [
            ffmpeg
            libxcrypt
            netcat
            hatch
            python3
            python3.pkgs.requests
            python3.pkgs.python-lsp-server
            portaudio
            zlib
            bashInteractive
            envsubst
          ];
          shellHook = ''
             # Tells pip to put packages into $PIP_PREFIX instead of the usual locations.
             # See https://pip.pypa.io/en/stable/user_guide/#environment-variables.
             export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath packages}:$LD_LIBRARY_PATH"
             export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib.outPath}/lib:$LD_LIBRARY_PATH"
             export PIP_PREFIX=$(pwd)/_build/pip_packages
             export PYTHONPATH="$PIP_PREFIX/${pkgs.python3.sitePackages}:$PYTHONPATH"
             export PATH="$PIP_PREFIX/bin:$PATH"
             unset SOURCE_DATE_EPOCH
             python -m venv .venv
             source .venv/bin/activate
             pip install -r requirements.txt
          '';
        };
      });
}
