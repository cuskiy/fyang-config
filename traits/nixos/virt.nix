{
  traits.virt =
    { pkgs, username, ... }:
    {
      virtualisation = {
        docker = { enable = true; enableOnBoot = true; };
        # Make sure you run this once: "sudo virsh net-autostart default"
        libvirtd = { enable = true; qemu.runAsRoot = true; };
      };

      users.users.${username}.extraGroups = [ "docker" "kvm" "libvirtd" ];
      networking.firewall.trustedInterfaces = [ "virbr0" ];
      hardware.nvidia-container-toolkit.enable = true;

      environment.systemPackages = with pkgs; [
        virt-manager
        qemu_kvm
        virtiofsd
      ];

      # boot.extraModprobeConfig = "options kvm_intel nested=1"; # for intel cpu
      boot.extraModprobeConfig = "options kvm_amd nested=1"; # for amd cpu
    };
}
