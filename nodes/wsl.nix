{
  nodes.wsl = {
    traits = [ "base" "wsl" ];
    schema.base = {
      hostname = "wsl";
      stateVersion = "23.05";
    };
    includes = [ ../platform/wsl ];
  };

  nodes."yang@wsl" = {
    traits = [ "shell" ];
  };
}
