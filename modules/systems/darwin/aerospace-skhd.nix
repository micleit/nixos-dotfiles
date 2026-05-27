{
  lib,
  ...
}:

{
  # Override skhd config to coexist with AeroSpace
  services.skhd.skhdConfig = lib.mkForce ''
    # === Session defaults ===
    ralt + shift - y : skhd --restart-service
    hyper - escape : /usr/bin/osascript -e 'tell application "System Events" to sleep'

    # === launch commands ===
    hyper - v : /usr/bin/open -na /Applications/Visual\ Studio\ Code.app
    hyper - b : /usr/bin/open -na "Brave Browser"
    hyper - f : /usr/bin/open $HOME
    hyper - y : ghostty -e yazi
    hyper - s : /usr/bin/open -na '/System/Applications/System Settings.app'
    hyper - t : /usr/bin/touch /tmp/skhd_test
    hyper - z : /usr/bin/touch /tmp/skhd_z_test

    # mouse emulation
    hyper - k : /opt/homebrew/bin/cliclick "m:+0,-20" #up
    hyper - j : /opt/homebrew/bin/cliclick "m:+0,+20" #down
    hyper - l : /opt/homebrew/bin/cliclick "m:+20,+0" #right
    hyper - h : /opt/homebrew/bin/cliclick "m:-20,+0" #left
    hyper - m : /opt/homebrew/bin/cliclick ku:cmd,ctrl,alt,shift c:. #release all modifiers and click
    hyper - n : /opt/homebrew/bin/cliclick ku:ctrl rc:.  #right click
  '';
}
