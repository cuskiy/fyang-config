{
  nodes.nas = {
    traits = [ "base" "desktop" "guest" ];
    schema = {
      base.hostname = "nas";
      hardware.graphics = true;
    };
    includes = [
      ../platform/nas
      ({ pkgs, ... }: {
        nix.settings.trusted-users = [ "david" ];
        users.users.david = {
          home = "/home/david";
          isNormalUser = true;
          shell = pkgs.zsh;
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILb6ayLkxFMHOMDSGcDWu2VgxIyK7Npll8OEBmXLaYGC d@D"
          ];
        };
      })
    ];
  };

  nodes."yang@nas" = {
    traits = [ "shell" "apps" "stylix" ];
  };

  nodes."guest@nas" = {
    traits = [ "shell" ];
    schema.user = { name = "guest"; email = "guest@mail.com"; };
  };

  nodes."david@nas" = {
    traits = [ "shell" "apps" ];
    schema.user = { name = "david"; email = "david@mail.com"; };
  };
}
