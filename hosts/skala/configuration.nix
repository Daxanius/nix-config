# Consult the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/nvidia-optimus.nix
      ../../modules/common.nix
    ];

  # Device specific configuration settings
  networking.hostName = "skala";

  # What if I have devices in different countries with with different locales?
  # Thus pushing this to hosts makes sense.
  time.timeZone = "Europe/Brussels";
  i18n.defaultLocale = "en_US.UTF-8";

  powerManagement.enable = true;
  powerManagement.powertop.enable = true;

  zramSwap = {
    enable = true;
    priority = 100;
    algorithm = "lz4";
    memoryPercent = 100; # Compress up to x percent if memory is needed
  };

  services.thermald.enable = true;

  hardware.nvidia-optimus = {
    enable = true;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Privacy = "device";
        JustWorksRepairing = "always";
        Class = "0x000100";
        FastConnectable = "true";
      };
    };
  };

  # hardware.xpadneo.enable = true;

  hardware.keyboard.qmk = {
    enable = true;
    keychronSupport = true;
  };
}
