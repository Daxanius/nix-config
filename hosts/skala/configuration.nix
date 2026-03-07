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

  hardware.nvidia-optimus = {
    enable = true;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };
}
