{ config, pkgs, inputs, ... }:

{
  home.username = "daxanius";
  home.homeDirectory = "/home/daxanius";

  programs.git = {
    enable = true;
    userName = "Daxanius";
    userEmail = "balder.huybreghs@gmail.com";

    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  nixpkgs.config.allowUnfree = true;

  wayland.windowManager.hyprland = {
    systemd.enable = false;
    enable = true;

#    plugins = [
#      inputs.hypr-dynamic-cursors.packages.${pkgs.system}.hypr-dynamic-cursors
#    ];
    
    settings = {
      # Autostart applications correctly
      exec-once = [
        "${pkgs.waybar}/bin/waybar"
        "${pkgs.mako}/bin/mako"
        "uwsm app -- nm-applet --indicator"
      ];
    
      monitor = ",preferred,auto,1";

      "$mod" = "SUPER";

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    
      bind = [
        "$mod, left,  movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up,    movefocus, u"
        "$mod, down,  movefocus, d"

        "$mod SHIFT, left,  movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up,    movewindow, u"
        "$mod SHIFT, down,  movewindow, d"

        "$mod, S, exec, hyprshot -m region --clipboard-only"
        "$mod, Return, exec, kitty"
        "$mod, C, killactive,"
        "$mod, Escape, exit,"
        "$mod, F, togglefloating,"
        "$mod, R, exec, rofi -show drun"
      ] 
      ++ (
        builtins.concatLists (builtins.genList (i:
          let
            ws = i + 1;
          in [
            "$mod, ${toString ws}, workspace, ${toString ws}"
            "$mod SHIFT, ${toString ws}, movetoworkspace, ${toString ws}"
          ]
        ) 9)
      );      

      env = [
        "NIXOS_OZONE_WL,1"
      ];
    };
  };

  programs.waybar.systemd.enable = true;
  services.mako.enable = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    rofi # App launcher.. for hyprland
    nnn # File browser for hyprland
    kitty # Kitty terminal emulator... for hyprland
    waybar # A bar... for hyprland
    pavucontrol # Hyprland sound control
    mako # Notification daemon for hyprland
    libnotify # Requirement
    networkmanagerapplet
    discord
    bitwarden-desktop
    prismlauncher
    hyprshot
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/daxanius/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
