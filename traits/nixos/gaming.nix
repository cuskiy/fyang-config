{
  traits.gaming =
    { pkgs, ... }:
    {
      programs.steam = {
        enable = true;
        gamescopeSession.enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        package = pkgs.steam.override {
          # https://github.com/NixOS/nixpkgs/issues/279893
          extraProfile = ''
            unset TZ
          '';
        };
      };
      programs.gamemode.enable = true;

      # Duckov: 9050
      networking.firewall.allowedTCPPorts = [ 9050 ];
      networking.firewall.allowedUDPPorts = [ 9050 ];
    };
}
