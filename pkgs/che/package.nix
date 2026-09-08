{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  installShellFiles,
  rust-jemalloc-sys,
  imagemagick,
  # Runtime dependencies
  file,
  jq,
  poppler-utils,
  _7zz,
  ffmpeg,
  fd,
  ripgrep,
  resvg,
  fzf,
  zoxide,
  chafa,
}:

let
  version = "26.8.28";
  src = fetchFromGitHub {
    owner = "aroum";
    repo = "che";
    rev = "cba87b60f23322444a2ee36b4a833deda592cbc2";
    hash = "sha256-kptGgMXZSToe1mRa7bspUlSK8IRY0c6G4qPCEpjtDE4=";
  };

  che-unwrapped = rustPlatform.buildRustPackage {
    pname = "che-unwrapped";
    inherit version src;

    cargoLock = {
      lockFile = "${src}/Cargo.lock";
    };

    env = {
      VERGEN_GIT_SHA = "cba87b60f23322444a2ee36b4a833deda592cbc2";
      VERGEN_BUILD_DATE = "2026-08-28";
    };

    nativeBuildInputs = [
      installShellFiles
      imagemagick
    ];

    buildInputs = [
      rust-jemalloc-sys
    ];

    meta = with lib; {
      description = "Fast dual-pane terminal file manager written in Rust, based on Yazi";
      homepage = "https://github.com/aroum/che";
      license = licenses.mit;
      mainProgram = "che";
    };
  };
in
stdenv.mkDerivation {
  pname = "che";
  inherit version;

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    ln -s ${che-unwrapped}/bin/che $out/bin/che
    ln -s ${che-unwrapped}/bin/ch $out/bin/ch
    wrapProgram $out/bin/che \
      --prefix PATH : "${lib.makeBinPath [
        file
        jq
        poppler-utils
        _7zz
        ffmpeg
        fd
        ripgrep
        resvg
        fzf
        zoxide
        imagemagick
        chafa
      ]}"
  '';
}
