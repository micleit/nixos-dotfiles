{ inputs, ... }:

{
  imports = [
    inputs.slippi.homeManagerModules.default
  ];

  slippi-launcher = {
    enable = true;
  };
}
