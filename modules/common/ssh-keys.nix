{ lib, ... }:

let
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKxCjlGFtiU6rrgryYhKmp0u6cbPhXPYm6IRkh9mSGL0 <comment>" # mbp
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM2H3Qy26Y3JV0p5WhpR89pE4hi7tssLbL/BYm+RsKd2 mic@headless-m1" # headlessm1
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIArDsvxPAbb7S2XhflttHFnsv5Sfyb/Z1mZIf+1PGJdn mic@nixos-btw" # desktop
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUGAfMHR2crHkfh6Wo73N0NW7w5VdBk476kEvF4QBxu mic@optiplex-server" # optiplex-server
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG5tnbYe9sVpb0rR30wYKQd3ntNxdG2O+eCb4Y74j3hJ mic@new-optiplex" # new-optiplex
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHgcQZ2TjpwiJAeeOUAywqpZ+xSxIYjeN7FBn0w59zHP mic@acer-nixos" # acer
  ];
in
{
  users.users.mic.openssh.authorizedKeys.keys = lib.mkDefault authorizedKeys;
}
