{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    inputs.neomutt-gmail.homeManagerModules.default
  ];

  # Neomutt for Gmail (by jevy)
  # This module provides an out-of-the-box pipeline with lieer and notmuch.
  # 
  # Setup Instructions:
  # 1. Update the 'address' below with your Gmail address.
  # 2. Run 'nixos-rebuild switch' or 'darwin-rebuild switch'.
  # 3. Run 'gmi auth mic@example.com' (using your actual email) to authenticate.
  # 4. Initial sync: 'gmi sync -C ~/Maildir/gmail'
  # 5. Start neomutt: 'neomutt'

  accounts.email.accounts.gmail = {
    address = "micah.leiterman@gmail.com"; # TODO: Update this
    realName = "Micah Leiterman";
    primary = true;
    flavor = "gmail.com";
    maildir.path = "gmail";
  };

  # The jevy module automatically configures:
  # - lieer (Gmail API sync)
  # - notmuch (Indexing & search)
  # - neomutt (Vim-style keybindings, sidebar, etc.)
  # - systemd services for background sync
  # - muttdown for markdown support
  # - mailcap for HTML/PDF previews

  programs.neomutt.enable = true;
  services.lieer.enable = true;
  programs.notmuch.enable = true;

  # Customizations can still be added here
  programs.neomutt.extraConfig = ''
    # Add your own neomutt overrides here
    # Example: set index_format = "%4C %Z %{%Y-%m-%d} %-15.15L %s"
  '';
}
