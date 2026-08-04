{
  config,
  pkgs,
  inputs,
  ...
}:

{
  home.username = "daxanius";
  home.homeDirectory = "/home/daxanius";

  programs.git = {
    enable = true;
    settings.user = {
      name = "Daxanius";
      email = "balder.huybreghs@gmail.com";
    };

    settings = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };

    # For Monado:
  # xdg.configFile."openxr/1/active_runtime.json".source = "${pkgs.monado}/share/openxr/1/openxr_monado.json";

  # For WiVRn v0.22 and below:
  # xdg.configFile."openxr/1/active_runtime.json".source = "${pkgs.wivrn}/share/openxr/1/openxr_wivrn.json";

  #xdg.configFile."openvr/openvrpaths.vrpath".text = ''
  #  {
  #    "config" :
  #    [
  #      "${config.xdg.dataHome}/Steam/config"
  #    ],
  #    "external_drivers" : null,
  #    "jsonid" : "vrpathreg",
  #    "log" :
  #    [
  #      "${config.xdg.dataHome}/Steam/logs"
  #    ],
  #    "runtime" :
  #    [
  #      "${pkgs.opencomposite}/lib/opencomposite"
  #    ],
  #    "version" : 1
  #  }
  #'';

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  nixpkgs.config.allowUnfree = true;

  programs.niri.settings = {
    environment."NIXOS_OZONE_WL" = "1";
    outputs."CHANGE-ME-eg-DP-1" = { scale = 1.0; };

    binds = with config.lib.niri.actions; {
      "Mod+Left".action = focus-column-left;
      "Mod+Right".action = focus-column-right;
      "Mod+Up".action = focus-window-up;
      "Mod+Down".action = focus-window-down;
      "Mod+Shift+Left".action = move-column-left;
      "Mod+Shift+Right".action = move-column-right;
      "Mod+Shift+Up".action = move-window-up;
      "Mod+Shift+Down".action = move-window-down;
      "Mod+S".action = spawn "bash" "-c" "grim -g \"$(slurp)\" - | wl-copy";
      "Mod+Return".action = spawn "kitty";
      "Mod+C".action = close-window;
      "Mod+K".action = spawn "hyprpicker" "--autocopy" "--format=hex" "--notify";
      "Mod+Escape".action = quit;
      "Mod+F".action = toggle-window-floating;
      "Mod+R".action = spawn "rofi" "-show" "drun";
      "XF86AudioRaiseVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "1%+";
      "XF86AudioLowerVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "1%-";
      "XF86AudioMute".action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
    };

    spawn-at-startup = [
      { command = [ "uwsm" "app" "--" "nm-applet" "--indicator" ]; }
      { command = [ "systemctl" "--user" "reset-failed" "waybar.service" ]; }
    ];
   };
  
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";

        modules-left = [
          "clock"
          "niri/workspaces"
        ];

        modules-center = [
          "temperature"
          "custom/fan"
          "cpu"
          "custom/gpu"
          "memory"
          "custom/power"
        ];

        modules-right = [
          "privacy"
          "pulseaudio"
          "custom/brightness"
          "battery"
          "tray"
        ];

        clock = {
          format = "󰃰  {:%A, %d %B %R %Y}";
          format-alt = "󰃰  {:%a %d-%m-%Y %T}";
          tooltip-format = "{:%Z %r}";
        };

        temperature = {
          critical-threshold = 80;
          format = " {temperatureC}°C";
          hwmon-path = "/sys/class/hwmon/hwmon4/temp1_input";
        };

        "custom/fan" = {
          format = "󰈐 {} RPM";
          interval = 5;
          exec = "${pkgs.lm_sensors}/bin/sensors | grep 'cpu_fan' | awk '{print $2}'";
        };

        "custom/brightness" = {
          exec = "brightnessctl -m | cut -d, -f4";
          interval = 2;
          format = "󰃠 {}";
          on-scroll-up = "brightnessctl set +5%";
          on-scroll-down = "brightnessctl set 5%-";
        };

        cpu = {
          format = " {usage}%";
        };

        "custom/power" = {
          exec = ''
            if [ "$(cat /sys/class/power_supply/AC*/online 2>/dev/null | head -n1)" = "1" ]; then
              echo "AC: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
            else
              echo "BAT: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
            fi
          '';
          interval = 5;
          format = " {}";
        };

        "custom/gpu" = {
          format = " {text}%";
          interval = 2;
          exec = "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits";
          exec-if = "nvidia-smi";
          tooltip = true;
          on-hover = "nvidia-smi --query-gpu=temperature.gpu,memory.used,power.draw --format=csv,noheader";
        };

        memory = {
          format = " {percentage}%";
        };

        pulseaudio = {
          format = "  {volume}%";
          format-muted = "muted";
          on-click = "pavucontrol";
        };

        battery = {
          format = "󰁹 {capacity}%";
        };

        tray = {
          spacing = 10;
        };
      };
    };

    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font";
        font-size: 16px;
      }

      window#waybar>box {
        padding-left: 10px;
        padding-right: 10px;
      }

      window#waybar {
        background-color: transparent;
        border: none;
      }

      #workspaces button {
        border-radius: 5px;
        margin: 5px;
      }

      #workspaces button.active {
        background: #23a2d5;
      }

      #pulseaudio.muted {
        color: #f38ba8;
      }

      #temperature.critical {
        color: #f38ba8;
      }

      .module {
        padding: 1 10px;
        margin: 0 5px 0px 5px;
      }
    '';
  };

  programs.waybar.systemd.enable = true;
  services.mako.enable = true;

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;

    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    rofi # App launcher
    kdePackages.dolphin # File browser
    kdePackages.kio-admin
    kitty # Kitty terminal emulator
    pavucontrol # Hyprland sound control
    mako # Notification daemon for hyprland
    libnotify # Requirement
    networkmanagerapplet
    fluffychat
    discord
    prismlauncher
    grim
    slurp
    wl-clipboard
    hyprpicker
    papirus-icon-theme
    helix
    zellij
#     bambu-studio
    blender
    jetbrains.idea
    obs-studio
    spotify
    vscode
    thunderbird
    sourcegit
    jetbrains.clion
    jetbrains.rust-rover
    cmakeCurses
    onlyoffice-desktopeditors
    vlc
    geogebra
    baobab
    vesktop
    oculante
    tracy
  ];

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
    ];
  };

  gtk = {
    enable = true;
    gtk4.theme = config.gtk.theme;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      "inode/directory" = "org.kde.dolphin.desktop";
      "x-scheme-handler/file" = "org.kde.dolphin.desktop";

      # Images -> oculante
      "image/png" = "oculante.desktop";
      "image/jpeg" = "oculante.desktop";
      "image/jpg" = "oculante.desktop";
      "image/gif" = "oculante.desktop";
      "image/webp" = "oculante.desktop";
      "image/bmp" = "oculante.desktop";
      "image/tiff" = "oculante.desktop";
      "image/x-icon" = "oculante.desktop";
      "image/svg+xml" = "oculante.desktop";

      # Videos -> vlc
      "video/mp4" = "vlc.desktop";
      "video/x-matroska" = "vlc.desktop";
      "video/webm" = "vlc.desktop";
      "video/quicktime" = "vlc.desktop";
      "video/mpeg" = "vlc.desktop";
      "video/x-msvideo" = "vlc.desktop";
      "video/ogg" = "vlc.desktop";
    };
  };

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
