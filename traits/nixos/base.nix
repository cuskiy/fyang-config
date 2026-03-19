{
  schema.base = {
    system = "x86_64-linux";
    stateVersion = "25.05";
    timeZone = "Asia/Tokyo";
    locale = "zh_CN.UTF-8";
    hostname = "nixos";
    username = "yang";
    hashedPassword = "$y$j9T$taWQyCw5HrrBRkx8uNHO50$1DIFg45L4E3A9MhjeI4FenL2xNPHDkT5BBH/NtUwlp0";
    authorizedKeys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCkjhbJRkAagX4N/lMyL/sRvg2qzZHntu4ZHXO+NCI1BetA1kykVSjA0MS5E0jJ5+ACihCeqmivzNiOFoZvQ1quBNKU4XF3b7MnkfW93qH1ET30klzO7kV6+5ycH/hLHENsZB4YEghSUrictxkDADlvlhKORFFoLK/aUVwfHgONaRius9beKevsDmrlnIVBUiuaj//WbyHVWBeJBdRVFaLChvD8qq/bjVEij5vE41u9lZhz1MU2IHEHSp60kXLUILwlR0rr+F+1OXtF9oqOwzNdBs181oJal9fA/G11CPbnCeqjq7I+shA03XAooXuTm9Ni0CPb+FZSzcUeDzTrjGoj yang@NII"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMggbqyvwD9XXdwm/O9/aW8wx4k58hqM/08/gjnChS1b yang"
    ];
  };

  traits.base =
    { lib, pkgs, schema, ... }:
    let
      u = schema.base.username;
      lc = schema.base.locale;
    in
    {
      networking.hostName = schema.base.hostname;
      time.timeZone = lib.mkDefault schema.base.timeZone;

      i18n.defaultLocale = lc;
      i18n.extraLocaleSettings = {
        LC_ADDRESS = lc;
        LC_IDENTIFICATION = lc;
        LC_MEASUREMENT = lc;
        LC_MONETARY = lc;
        LC_NAME = lc;
        LC_NUMERIC = lc;
        LC_PAPER = lc;
        LC_TELEPHONE = lc;
        LC_TIME = lc;
      };

      nixpkgs.config.allowUnfree = lib.mkDefault true;

      nix.gc = {
        automatic = lib.mkDefault true;
        dates = lib.mkDefault "weekly";
        options = lib.mkDefault "--delete-older-than 30d";
      };
      nix.settings = {
        auto-optimise-store = true;
        experimental-features = [ "nix-command" "flakes" ];
        trusted-users = [ u ];
      };
      nix.channel.enable = false;

      services.openssh = {
        enable = true;
        settings = {
          X11Forwarding = true;
          PermitRootLogin = "no";
          PasswordAuthentication = false;
        };
        openFirewall = true;
      };

      security.sudo.enable = false;
      security.doas = {
        enable = true;
        extraRules = [{ groups = [ "wheel" ]; persist = true; keepEnv = true; }];
      };

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
      };

      programs.nix-ld = {
        enable = true;
        libraries = with pkgs; [ stdenv.cc.cc ];
      };
      environment.stub-ld.enable = true;

      environment.systemPackages = with pkgs; [
        doas-sudo-shim home-manager wget curl tree just usbutils
      ];
      environment.shells = with pkgs; [ bashInteractive zsh ];

      programs.vim = { enable = true; defaultEditor = lib.mkDefault true; };
      programs.git = { enable = true; lfs.enable = true; };
      programs.zsh.enable = true;
      programs.mtr.enable = true;
      programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

      users.users.${u} = {
        # mkpasswd
        hashedPassword = schema.base.hashedPassword;
        home = "/home/${u}";
        isNormalUser = true;
        shell = pkgs.bash;
        extraGroups = [ "wheel" "networkmanager" "input" "video" ];
        openssh.authorizedKeys.keys = schema.base.authorizedKeys;
      };

      system.stateVersion = schema.base.stateVersion;
    };
}
