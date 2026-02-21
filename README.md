My awful NixOS flakes + setup. I'll try to keep this updated as I add more stuff.


I have it setup so hardware-configuration.nix is in an absolute path, so you need --impure when rebuilding. 
The rebuild command looks like :
sudo nixos-rebuild --flake ~/nixos-dotfiles#nixos-btw --impure
