{ pkgs, lib, ... }:

{
  # Linux-specific Home Manager packages

  home.packages =
    with pkgs;
    lib.mkIf pkgs.stdenv.hostPlatform.isLinux [
      docker # Docker CLI for NixOS machines
    ];
}
