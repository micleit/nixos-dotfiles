{ config, lib, pkgs, ... }:

{
  # Enable uinput kernel module
  boot.kernelModules = [ "uinput" ];
  hardware.uinput.enable = true;

  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
  '';

  users.groups.uinput = { };

  # Give kanata service access to input/uinput
  systemd.services.kanata-internalKeyboard.serviceConfig = {
    SupplementaryGroups = [
      "input"
      "uinput"
    ];
  };

  services.kanata = {
    enable = true;

    keyboards.internalKeyboard = {
      devices = [
        "dev/input/by-id/usb-VMware_VMware_Virtual_USB_Keyboard-event-kbd"
        "dev/input/by-id/usb-VMware_VMware_Virtual_USB_Keyboard-hidraw"
      ];

      config = builtins.readFile ./colemak.kbd;
    };
  };
}

