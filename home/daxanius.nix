{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.noctalia.homeModules.default
  ];
  
  home.username = "daxanius";
  home.homeDirectory = "/home/daxanius";

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings.user = {
      name = "Daxanius";
      email = "balder.huybreghs@gmail.com";
    };

    settings = {
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

  programs.noctalia = {
    enable = true;

    # May also be a string path to a toml file
    settings = {
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Catppuccin";
      };

      wallpaper = {
        enabled = true;
        default.path = "${config.home.homeDirectory}/Pictures/wallpapers/default.png";
        fill_mode = "crop";
      };
    };
  };

  programs.niri.settings = {
    prefer-no-csd = true;

    # The nvidia driver crashes when handed a direct scanout
    # causing a visual freeze and then an eventual reset
    debug = {
      disable-direct-scanout = [ ];
      honor-xdg-activation-with-invalid-serial = [ ];
    };

    outputs."Microstep MSI G27C6 0x0000019A" = {
      mode = {
        width = 1920;
        height = 1080;
        refresh = 143.998;
      };
    };
    
    input.focus-follows-mouse = {
      enable = true;
      max-scroll-amount="10%";
    };

    binds = with config.lib.niri.actions; {
      "Mod+Slash".action = show-hotkey-overlay;

      "Mod+Left".action = focus-column-left;
      "Mod+Right".action = focus-column-right;
      "Mod+Up".action = focus-window-up;
      "Mod+Down".action = focus-window-down;
      
      "Mod+Shift+Left".action = move-column-left;
      "Mod+Shift+Right".action = move-column-right;
      "Mod+Shift+Up".action = move-window-up;
      "Mod+Shift+Down".action = move-window-down;

      "Mod+WheelScrollRight" = {
        action = focus-workspace-down;
        cooldown-ms = 100;
      };
      
      "Mod+WheelScrollLeft" = {
        action = focus-workspace-up;
        cooldown-ms = 100;
      };

      "Mod+WheelScrollDown" = {
        action = focus-column-right;
        cooldown-ms = 100;
      };
      
      "Mod+WheelScrollUp" = {
        action = focus-column-left;
        cooldown-ms = 100;
      };

      "Mod+C".action = close-window;
      "Mod+Escape".action = quit;
      "Mod+Tab".action = toggle-overview;
      "Mod+F".action = toggle-window-floating;
      "Mod+E".action = expand-column-to-available-width;
      "Mod+M".action = maximize-column;

      # Other launcher binds
      "Mod+Return".action = spawn "kitty";
      "Mod+K".action = spawn "hyprpicker" "--autocopy" "--format=hex" "--notify";

      # Core noctalia binds
      "Mod+R".action = spawn "noctalia" "msg" "panel-toggle" "launcher";
      "Mod+Space".action = spawn "noctalia" "msg" "panel-toggle" "control-center";
      "Mod+Comma".action = spawn "noctalia" "msg" "settings-toggle";

      # Misc noctalia binds
      "Mod+S".action = spawn "noctalia" "msg" "screenshot-fullscreen";
      "Mod+Shift+S".action = spawn "noctalia" "msg" "screenshot-region";

      # Volume and brightness control
      "XF86AudioRaiseVolume".action = spawn "noctalia" "msg" "volume-up";
      "XF86AudioLowerVolume".action = spawn "noctalia" "msg" "volume-down";
      "XF86AudioMute".action = spawn "noctalia" "msg" "volume-mute";
      
      "XF86MonBrightnessUp".action = spawn "noctalia" "msg" "brightness-up";
      "XF86MonBrightnessDown".action = spawn "noctalia" "msg" "brightness-down";
    };

    spawn-at-startup = [
      { command = [ "noctalia" ]; }
    ];
  };

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;

    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  programs.helix = {
    enable = true;

    settings = {
      theme = "noctalia";
    };
  };
  
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    kdePackages.dolphin # File browser
    kdePackages.kio-admin
    kdePackages.ark                    # archive support: zip/tar/etc
    kdePackages.kio-extras             # network browsing, thumbnails, extra KIO protocols
    kdePackages.kdegraphics-thumbnailers
    kdePackages.ffmpegthumbs           # video thumbnails
    kdePackages.kimageformats  
    kitty # Kitty terminal emulator
    fluffychat
    discord
    prismlauncher
    hyprpicker
    papirus-icon-theme
#     bambu-studio
    blender
    jetbrains-toolbox
    obs-studio
    spotify
    vscode
    thunderbird
    cmakeCurses
    onlyoffice-desktopeditors
    vlc
    geogebra
    baobab
    vesktop
    oculante
    tracy
    unityhub
    godot
    sourcegit
    krita
  ];

  xdg.portal = {
    enable = true;
    config.common.default = "*";
    config.niri = {
      "org.freedesktop.impl.portal.FileChooser" = [ "kde" ]; # or GTK
    };
    
    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
    ];
  };

  xdg.desktopEntries.oculante = {
    name = "Oculante";
    exec = "${pkgs.oculante}/bin/oculante %f";
    type = "Application";
    mimeType = [ "image/png" "image/jpeg" "image/gif" "image/webp" "image/bmp" "image/tiff" "image/x-icon" "image/svg+xml" ];
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "org.kde.dolphin.desktop";
      "x-scheme-handler/file" = "org.kde.dolphin.desktop";

      "image/png" = "oculante.desktop";
      "image/jpeg" = "oculante.desktop";
      "image/jpg" = "oculante.desktop";
      "image/gif" = "oculante.desktop";
      "image/webp" = "oculante.desktop";
      "image/bmp" = "oculante.desktop";
      "image/tiff" = "oculante.desktop";
      "image/x-icon" = "oculante.desktop";
      "image/svg+xml" = "oculante.desktop";

      "video/mp4" = "vlc.desktop";
      "video/x-matroska" = "vlc.desktop";
      "video/webm" = "vlc.desktop";
      "video/quicktime" = "vlc.desktop";
      "video/mpeg" = "vlc.desktop";
      "video/x-msvideo" = "vlc.desktop";
      "video/ogg" = "vlc.desktop";
    };
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
