{config, pkgs, lib, ...}:
{
programs.git = {
  enable = true;
  settings = {
    user = {
      name = "micah leiterman";
      email = "micah.leiterman@gmail.com";
    };
    init.defaultBranch = "main";
  };
};
}
