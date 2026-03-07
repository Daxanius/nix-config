# Consult the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./nvidia-configuration.nix
      inputs.home-manager.nixosModules.skala
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "skala"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Brussels";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  programs.regreet.enable = true;

  services.greetd.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = false;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  services.resolved.enable = true;
  services.mullvad-vpn.enable = true;

  # Don't forget to set a password with ‘passwd’.
  users.users.daxanius = {
    isNormalUser = true;
    description = "Daxanius";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      discord
      bitwarden-desktop
      prismlauncher
    ];
  };

  programs.firefox.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = true;
  };

  programs.git = {
    enable = true;
    settings = {
      credential.helper = "${
        pkgs.git.override { withLibsecret = true; }
      }/bin/git-credential-libsecret";
      init.defaultBranch = "main";
    };
  };

  nixpkgs.config.allowUnfree = true;

  security.sudo.extraConfig = ''
    Defaults pwfeedback
  '';

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    mullvad-vpn
    wofi
    kdePackages.dolphin
    kitty

    # TODO: build the script based on the devices' graphics configuration
    (writeShellScriptBin "gpu-run" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
      exec "$@"
    '')    
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  xdg.portal = {
    enable = true;
    extraPortals =  with pkgs; [ xdg-desktop-portal-hyprland ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "daxanius" = import ./home.nix;
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
