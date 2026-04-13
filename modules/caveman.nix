{ pkgs, lib, ... }:

{
  # Caveman: Token-efficient output formatting for Copilot CLI
  # Reduces output by ~75% while maintaining technical accuracy
  # https://github.com/JuliusBrussee/caveman

  home.packages = with pkgs; [
    nodejs
  ];

  # Install caveman skill via npx
  home.activation.installCaveman = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if ! ${pkgs.nodejs}/bin/npx skills list 2>/dev/null | grep -q caveman; then
      echo "Installing caveman skill..."
      ${pkgs.nodejs}/bin/npx skills add JuliusBrussee/caveman -a github-copilot --no-save
    fi
  '';
}
