{ inputs, ... }:
{
  traits.wsl =
    { lib, username, ... }:
    {
      imports = [ inputs.nixos-wsl.nixosModules.default ];

      wsl = {
        enable = true;
        wrapBinSh = false; # https://github.com/microsoft/vscode-remote-release/issues/10375
        useWindowsDriver = true; # required by nvidia-container-toolkit-cdi-generator
        defaultUser = username;
      };

      environment.sessionVariables.LD_LIBRARY_PATH = [ "/usr/lib/wsl/lib" ];
      time.timeZone = lib.mkForce null;
      services.automatic-timezoned.enable = true;
    };
}
