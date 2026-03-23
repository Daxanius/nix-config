{ config, pkgs, inputs, ... }:

{
  imports =
    [
      inputs.home-manager.nixosModules.home-manager
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  networking.networkmanager.enable = true;
  networking.wireless.userControlled.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  fonts.packages = with pkgs; [
    font-awesome_4
  ];

  programs.regreet.enable = true;

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd \"uwsm start default\"";
      user = "daxanius";
    };
  };

  services.printing.enable = false;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.resolved.enable = true;
  services.mullvad-vpn.enable = true;

  users.defaultUserShell = pkgs.fish;

  # Don't forget to set a password with ‘passwd’.
  users.users.daxanius = {
    isNormalUser = true;
    description = "Daxanius";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  programs.firefox.enable = true;
  programs.fish.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = true;
  };

  security.sudo.extraConfig = ''
    Defaults pwfeedback
  '';

  environment.systemPackages = with pkgs; [
    helix
    mullvad-vpn
    tuigreet
    ffmpeg-full
    powertop
    lm_sensors
  ];

  xdg.portal = {
    enable = true;
    extraPortals =  with pkgs; [ xdg-desktop-portal-hyprland ];
  };

  home-manager = {
    backupFileExtension = "back";
    extraSpecialArgs = { inherit inputs; };
    users = {
      "daxanius" = import ../home/daxanius.nix;
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
