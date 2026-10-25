{
  lib,
  pkgs-unstable,
  ...
}:
{
  networking.hostName = "rpi4b-poc";

  services.openssh.enable = true; # todo: security settings

  # user config
  users.users.brosin = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "gpio"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7Dc279BL/npkNq8mh6p18nruloGPfni0m0XLLMuwKEXo82t60hCcL2IDRInYqLqwtuUPcqHS6+G1cDL6aMFm1T21QIgCNkyF4nj/QqSsCMtmhlBv9diU53qv2cSwrc+2QFgImzm1M2z7VBXm8P1/7B/1SVY1v+Xq8SwAOMPqJPSrVDl3QAl26B5aaxSW9iaDHW7vg6C8ZDeEH+jDQ2sNs6yGuPcxV87Ch87boFHzvy+33534Amy5B/Qu22Ktg2Iimsjbsx58uU233vr2i/4Vc8VVqNcNA1ydiyyLgi0uqMtDUbKu3RABjK3lc3n9ZBpwDm+u1Dw6Knjpdk1LCtsDRJ0MxoCoyLL60ArpVHamfzx10367CxNxPTAGLP0VKjvkolAVTYft4FpAr2pqbIhJksPdNgHsGA8KSO3gvMtVeBBYrNrVAD5GnhkCZOcC9IEBeRJDiUpMeQEz/Zt8zVpSFy/a9Q4lLZMA05Plhiee9/jKuGUS4OJS4OFKZYqlvZrk= by@luffy"
    ];
    initialPassword = "test123";
  };
  security.sudo.wheelNeedsPassword = false; # remote deploy

  # tailscale
  services.tailscale = {
    package = pkgs-unstable.tailscale;
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "client"; # idk
    authKeyFile = "/boot/firmware/ts-authkey";
  };
  systemd.services.tailscaled.environment = {
    # GOMEMLIMIT = "64MiB";
    GOGC = "50";
  };
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # mount authkey partition on boot
  fileSystems."/boot/firmware".options = lib.mkForce [ "nofail" ];
  systemd.services.tailscaled-autoconnect.unitConfig.RequiresMountsFor = "/boot/firmware";

  # hardware tuning
  hardware.enableRedistributableFirmware = true;
  users.groups.gpio = { };
  services.udev.extraRules = ''
    SUBSYSTEM=="gpio", KERNEL=="gpiochip*", GROUP="gpio", MODE="0660"
    SUBSYSTEM=="gpio", KERNEL=="gpio*", GROUP="gpio", MODE="0660"
  '';

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };
  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=16M
  '';

  # trim the OS for reduced mem usage
  documentation.enable = false;
  documentation.nixos.enable = false;
  programs.command-not-found.enable = false;
  environment.defaultPackages = [ ];
  services.udisks2.enable = false;
  xdg.autostart.enable = false;
  fonts.fontconfig.enable = false;
  boot.enableContainers = false;

  # Simulate low memory availablity (pi zero)
  boot.kernelParams = [ "mem=512M" ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 1;
    "vm.vfs_cache_pressure" = 50;
  };
}
