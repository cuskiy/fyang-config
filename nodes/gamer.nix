{
  nodes.gamer = {
    traits = [ "base" "desktop" "virt" "gaming" "guest" ];
    schema = {
      base.hostname = "gamer";
      hardware = { nvidia = true; bluetooth = true; graphics = true; };
    };
    includes = [ ../platform/gamer ];
  };

  nodes."yang@gamer" = {
    traits = [ "shell" "apps" "stylix" ];
  };
}
