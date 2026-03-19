{ inputs, ... }:
{
  traits.stylix = {
    imports = [ inputs.stylix.homeModules.stylix ];
  };
}
