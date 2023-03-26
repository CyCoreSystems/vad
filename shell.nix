let
  pkgs = import <nixpkgs> {};
in pkgs.mkShell rec {
  buildInputs = [
    pkgs.ffmpeg
    pkgs.netcat
    pkgs.hatch
    pkgs.python3
    pkgs.python3.pkgs.requests
    pkgs.portaudio
    pkgs.zlib
  ];
  shellHook = ''
    # Tells pip to put packages into $PIP_PREFIX instead of the usual locations.
    # See https://pip.pypa.io/en/stable/user_guide/#environment-variables.
    export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath buildInputs}:$LD_LIBRARY_PATH"
    export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib.outPath}/lib:$LD_LIBRARY_PATH"
    export PIP_PREFIX=$(pwd)/_build/pip_packages
    export PYTHONPATH="$PIP_PREFIX/${pkgs.python3.sitePackages}:$PYTHONPATH"
    export PATH="$PIP_PREFIX/bin:$PATH"
    unset SOURCE_DATE_EPOCH
    python -m venv
    source .venv/bin/activate
    pip install -r requirements.txt
  '';
}
