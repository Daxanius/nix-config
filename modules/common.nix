{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  
  nixpkgs.config.allowUnfree = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    lldb
  ];

  services.monado = {
    enable = true;
    defaultRuntime = true; # Register as default OpenXR runtime
  };

  services.wivrn = {
    enable = true;
    openFirewall = true;

    # Run WiVRn as a systemd service on startup
    autoStart = true;

    # If you're running this with an nVidia GPU and want to use GPU Encoding (and don't otherwise have CUDA enabled system wide), you need to override the cudaSupport variable.
    package = (pkgs.wivrn.override { cudaSupport = true; });

    # You should use the default configuration (which is no configuration), as that works the best out of the box.
    # However, if you need to configure something see https://github.com/WiVRn/WiVRn/blob/master/docs/configuration.md for configuration options and https://mynixos.com/nixpkgs/option/services.wivrn.config.json for an example configuration.
  };

  systemd.user.services.monado.environment = {
    STEAMVR_LH_ENABLE = "1";
    XRT_COMPOSITOR_COMPUTE = "1";
    WMR_HANDTRACKING = "0";
  };

  services.udev = {
    packages = with pkgs; [
      via
    ]; # packages
  }; # udev

  services.tuned.enable = true;
  services.upower.enable = true;

  networking.networkmanager = {
    enable = true;
  };
  
  networking.wireless.userControlled = true;
  networking.firewall.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  programs.niri = {
    enable = true;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  services.displayManager.regreet = {
    enable = true;
    cageArgs = [ "-d" "-m" "last" ];
  };
  
  services.greetd = {
    enable = true;
    settings.default_session = {
      user = "daxanius";
    };
  };

  services.printing.enable = false;
  services.udisks2.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

# HOTSPOT??
  services.resolved.enable = true;
  services.mullvad-vpn.enable = true;
  services.mullvad-vpn.gui.enable = true;
  services.tailscale.enable = true;

  users.defaultUserShell = pkgs.fish;

  systemd.network.wait-online.enable = false;

  # Don't forget to set a password with ‘passwd’.
  users.users.daxanius = {
    isNormalUser = true;
    description = "Daxanius";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  programs.firefox.enable = true;

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      function fish_greeting
          set -l gen (readlink /nix/var/nix/profiles/system | string match -r '\d+')
          set -l gen_date (date -d @(stat -c %Y /nix/var/nix/profiles/system) "+%b %d, %H:%M" 2>/dev/null)

          set_color -o cyan
          echo "NixOS"
          set_color normal

          echo "-------------------"

          set_color cyan
          echo -n "  Generation "
          set_color -o white
          echo "#$gen"
          set_color normal

          set_color cyan
          echo -n "  Built      "
          set_color normal
          echo "$gen_date"

          echo "-------------------"
      end
    '';
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = true;
    package = pkgs.steam.override {
    extraProfile = ''
        # Allows Monado/WiVRn to be used
        export PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1
        # Fixes timezones on some apps
        unset TZ
      '';
    };
  };

  programs.gamescope = {
    enable = true;
    enableWsi = true;
    capSysNice = true;
  };

  programs.alvr = {
    enable = true;
    openFirewall = true;
  };

  programs.gamemode.enable = true;

  programs.steam.extraCompatPackages = with pkgs; [
    proton-ge-bin
  ];

  security.sudo.extraConfig = ''
    Defaults pwfeedback
  '';

  environment.systemPackages = with pkgs; [
    xbacklight
    man-pages
    networkmanager
    gdb
    busybox
    iproute2
    iputils
    curl
    wget
    btop-cuda
    sysstat
    htop
    bpftrace
    perf
    dnsutils
    inetutils
    tcpdump
    ethtool
    nftables
    conntrack-tools
    ffmpeg-full
    powertop
    lm_sensors
    wl-clipboard
    nixfmt
    nixd
    brightnessctl
    mangohud
    pipewire
    pulseaudio
    alsa-lib
    direnv
    qmk
    via
    xterm
    ripgrep
    steam-run
    android-tools
    xwayland-satellite
  ];

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
