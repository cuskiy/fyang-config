{
  schema.hardware = {
    nvidia = false;
    bluetooth = false;
    graphics = false;
  };

  traits.desktop =
    { config, lib, pkgs, schema, ... }:
    {
      hardware.graphics = lib.mkIf schema.hardware.graphics {
        enable = true;
        enable32Bit = true;
      };

      hardware.nvidia = lib.mkIf schema.hardware.nvidia {
        open = true;
        modesetting.enable = true;
        powerManagement.enable = true;
      };
      services.xserver.videoDrivers = lib.mkIf schema.hardware.nvidia [ "nvidia" ];

      hardware.bluetooth = lib.mkIf schema.hardware.bluetooth {
        enable = true;
        powerOnBoot = true;
      };

      services.displayManager.cosmic-greeter.enable = true;
      services.desktopManager.cosmic.enable = true;
      environment.cosmic.excludePackages = with pkgs; [
        cosmic-edit cosmic-term cosmic-player cosmic-reader
      ];
      environment.sessionVariables = {
        COSMIC_DATA_CONTROL_ENABLED = 1;
        NIXOS_OZONE_WL = 1;
      };
      services.xserver.xkb = { layout = "us"; variant = ""; };

      networking.networkmanager = { enable = true; dns = "none"; };
      networking.nameservers = [
        "1.1.1.1" "2606:4700:4700::1111"
        "8.8.8.8" "2001:4860:4860::8888"
      ];

      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        wireplumber.enable = true;
      };

      fonts = {
        enableDefaultPackages = false;
        fontDir.enable = true;
        packages = with pkgs; [
          noto-fonts-color-emoji material-icons material-design-icons
          font-awesome nerd-fonts.symbols-only maple-mono.variable noto-fonts
          (callPackage ../../assets/fonts { })
        ];
        fontconfig = {
          # https://catcat.cc/post/2021-03-07/
          defaultFonts = {
            serif = [ "TsangerJinKai03" ];
            sansSerif = [ "HarmonyOS Sans" ];
            monospace = [ "Maple Mono" "HarmonyOS Sans" ];
            emoji = [ "Noto Color Emoji" ];
          };
          antialias = true; # 抗锯齿
          hinting.enable = false; # 禁止字体微调 - 高分辨率下没这必要
          subpixel.rgba = "rgb"; # IPS 屏幕使用 rgb 排列
        };
      };

      # https://github.com/NixOS/nixpkgs/issues/119433#issuecomment-1326957279
      system.fsPackages = [ pkgs.bindfs ];
      fileSystems =
        let
          mkRoSymBind = path: {
            device = path;
            fsType = "fuse.bindfs";
            options = [ "ro" "resolve-symlinks" "x-gvfs-hide" ];
          };
          aggregatedFonts = pkgs.buildEnv {
            name = "system-fonts";
            paths = config.fonts.packages;
            pathsToLink = [ "/share/fonts" ];
          };
        in
        {
          "/usr/share/icons" = mkRoSymBind (config.system.path + "/share/icons");
          "/usr/share/fonts" = mkRoSymBind (aggregatedFonts + "/share/fonts");
        };

      services.flatpak.enable = true;
      systemd.services.flatpak-repo = {
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.flatpak ];
        script = ''
          flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
          flatpak remote-modify flathub --url=https://mirror.sjtu.edu.cn/flathub
          flatpak remote-add --if-not-exists cosmic https://apt.pop-os.org/cosmic/cosmic.flatpakrepo
        '';
      };

      # create a fhs environment by command `fhs`, so we can run non-nixos packages in nixos!
      environment.systemPackages = [
        (let base = pkgs.appimageTools.defaultFhsEnvArgs; in
         pkgs.buildFHSEnv (base // {
           name = "fhs";
           targetPkgs = pkgs: (base.targetPkgs pkgs) ++ [ pkgs.pkg-config ];
           profile = "export FHS=1";
           runScript = "bash";
           extraOutputsToInstall = [ "dev" ];
         }))
      ];
    };
}
