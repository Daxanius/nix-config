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
        "$mod, K, exec, hyprpicker --autocopy --format=hex --notify"
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

  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";

        modules-left = [
          "clock"
          "hyprland/workspaces"
        ];

        modules-center = [
          "temperature"
          "custom/fan"
          "cpu"
          "custom/gpu"
          "memory"
          "power-profiles-daemon"
        ];

        modules-right = [
          "privacy"
          "pulseaudio"
          "battery"
          "tray"
        ];

        clock = {
          format = "󰃰  {:%A, %d %B %R %Y}";
          format-alt = "󰃰  {:%a %d-%m-%Y %T}";
          tooltip-format = "{:%Z %r}";
        };

        temperature = {
          critical-threshold = 90;
          format = " {temperatureC}°C";
          hwmon-path = "/sys/class/hwmon/hwmon4/temp1_input";
        };

        "custom/fan" = {
          format = "󰈐 {} RPM";
          interval = 5;
          exec = "${pkgs.lm_sensors}/bin/sensors | grep 'cpu_fan' | awk '{print $2}'";
        };

        cpu = {
          format = " {usage}%";
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

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    rofi # App launcher.. for hyprland
    nnn # File browser for hyprland
    kitty # Kitty terminal emulator... for hyprland
    pavucontrol # Hyprland sound control
    mako # Notification daemon for hyprland
    libnotify # Requirement
    networkmanagerapplet
    discord
    bitwarden-desktop
    prismlauncher
    hyprshot
    hyprpicker
    papirus-icon-theme
  ];

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
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
