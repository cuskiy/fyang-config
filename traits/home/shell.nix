{
  schema.user = {
    system = "x86_64-linux";
    name = "yang";
    email = "norepfy@gmail.com";
  };

  traits.shell = {
    imports = [ ./_minimal ];
  };
}
