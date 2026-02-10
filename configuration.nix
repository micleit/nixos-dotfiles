
{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
   # Enable the uinput module
  boot.kernelModules = [ "uinput" ];

  # Enable uinput
  hardware.uinput.enable = true;

  # Set up udev rules for uinput
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
  '';

  # Ensure the uinput group exists
  users.groups.uinput = { };

  # Add the Kanata service user to necessary groups
  systemd.services.kanata-internalKeyboard.serviceConfig = {
    SupplementaryGroups = [
      "input"
      "uinput"
    ];
  };

  services.kanata = {
    enable = true;
    keyboards = {
      internalKeyboard = {
        devices = [
          "dev/input/by-id/usb-VMware_VMware_Virtual_USB_Keyboard-event-kbd"
          "dev/input/by-id/usb-VMware_VMware_Virtual_USB_Keyboard-hidraw"
        ];
        config = ''
;;
;; Colemak Mod-DH keyboard layout for Kanata (ISO keyboards)
;;
;; The Colemak Mod-DH layout is an improved version of Colemak that addresses 
;; the D and H key positions for better comfort on row-staggered keyboards.
;; This ISO version is designed for European/UK keyboards with the extra key.
;; 
;; Visit https://colemakmods.github.io/mod-dh/ for more information.
;;
;; This configuration includes:
;; - Standard Colemak-DH layout for ISO keyboards
;; - Colemak-DHk variant (k and m swapped)
;; - Optional Extend layer for navigation and function keys
;; - Layer switching via Caps Lock + number keys
;;

;; Source layer - defines which keys are intercepted (ISO layout)
(defsrc
  esc     f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12
  grv     1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab     q    w    e    r    t    y    u    i    o    p    [    ]
  caps    a    s    d    f    g    h    j    k    l    ;    '    \    ret
  lsft nubs  z    x    c    v    b    n    m    ,    .    /    rsft
  lctl    lmet lalt           spc            ralt rmet menu rctl
)

;; Colemak Mod-DH main layer (ISO)
(deflayer colemak-dh
  esc     f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12
  grv     1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab     q    w    f    p    b    j    l    u    y    ;    [    ]
  @ext    a    r    s    t    g    m    n    e    i    o    '    \    ret
  lsft    z    x    c    d    v    z    k    h    ,    .    /    rsft
  lctl    lmet lalt           spc            ralt rmet menu rctl
)

;; Colemak-DHk variant for ISO (k and m positions swapped)
(deflayer colemak-dhk
  esc     f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12
  grv     1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab     q    w    f    p    b    j    l    u    y    ;    [    ]
  @ext    a    r    s    t    g    k    n    e    i    o    '    \    ret
  lsft  z    x    c    d    v    nubs m    h    ,    .    /    rsft
  lctl    lmet lalt           spc            ralt rmet menu rctl
)

;; QWERTY layer for comparison/fallback (ISO)
(deflayer qwerty
  esc     f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12
  grv     1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab     q    w    e    r    t    y    u    i    o    p    [    ]
  @ext    a    s    d    f    g    h    j    k    l    ;    '    \    ret
  lsft  nubs z    x    c    v    b    n    m    ,    .    /    rsft
  lctl    lmet lalt           spc            ralt rmet menu rctl
)

;; Extend layer for navigation, function keys, and layer switching
;; Inspired by DreymaR's BigBag extend layer
(deflayer extend
  _       @lq  @lh  @lm  _    _    _    _    _    _    _    _    _
  _       @lq  @lh  @lm  _    _    _    _    _    _    _    _    _    _
  _       esc  @bk  @fnd @fw  ins  pgup home up   end  menu _    slck
  _       lalt lmet lsft lctl ralt pgdn lft  down rght del  caps _    _
  _     @udo @cut @cpy tab  @pst _   pgdn bspc lsft lctl menu _
  _       _    _              ret            _    _    _    _
)

;; Layer switching layer
(deflayer layers
  _       _    _    _    _    _    _    _    _    _    _    _    _
  _       @lq  @lh  @lm  _    _    _    _    _    _    _    _    _    _
  _       _    _    _    _    _    _    _    _    _    _    _    _    _
  _       _    _    _    _    _    _    _    _    _    _    _    _
  _       _    _    _    _    _    _    _    _    _    _    _    _
  _       _    _              _              _    _    _    _
)

;; Aliases for cleaner layer definitions
(defalias
  ;; Extend layer toggle on Caps Lock (tap for Caps, hold for Extend)
  ext  (tap-hold 200 200 caps (layer-toggle extend))
  
  ;; Layer switching aliases
  lq   (layer-switch qwerty)      ;; Switch to QWERTY ISO
  lh   (layer-switch colemak-dh)  ;; Switch to Colemak-DH ISO
  lm   (layer-switch colemak-dhk) ;; Switch to Colemak-DHk ISO

  ;; Common shortcuts for Extend layer
  cpy  C-c   ;; Copy
  pst  C-v   ;; Paste
  cut  C-x   ;; Cut
  udo  C-z   ;; Undo
  all  C-a   ;; Select All
  fnd  C-f   ;; Find
  bk   A-lft ;; Browser back
  fw   A-rght ;; Browser forward
)

        '';
      };
    };
  };

  networking.hostName = "nixos-btw"; # Define your hostname.
  virtualisation.vmware.guest.enable = true;
  hardware.graphics.enable = true;

  networking.networkmanager.enable = true;
  networking.nameservers = ["1.1.1.1" "8.8.8.8"];

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  services.displayManager.ly.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  environment.etc = {
    "resolv.conf".text = "nameserver 1.1.1.1\n";
  };


  

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mic = {
    isNormalUser = true;
    extraGroups = [ "wheel" "uinput"]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    vim 
    wget
    git
    alacritty
    kitty
    open-vm-tools
    foot
    wmenu
    wl-clipboard
    grim
    slurp
    swaybg
    firefox
    keyd
    gtk4
    xwayland
    kanata
  ];


  fonts.packages = with pkgs; [
	nerd-fonts.jetbrains-mono
  ];
 
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.11"; 

}

