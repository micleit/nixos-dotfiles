{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    (neovim.override {
      withPython3 = true;
      extraPython3Packages =
        p: with p; [
          pynvim
        ];
    })

    # Essential Language Servers & Formatters
    nil
    nixd
    nixfmt
    lua-language-server
    stylua

    # Utilities
    lazygit
    neovim-remote
    python3Packages.pynvim
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
