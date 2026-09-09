{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.programs.waylandcraft;
  swayConfig = pkgs.writeText "waylandcraft-sway-config" ''
    default_border none
    default_floating_border none
    exec systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP SWAYSOCK
    exec hash dbus-update-activation-environment 2>/dev/null && \
         dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway SWAYSOCK
    exec systemctl --user start sway-session.target
    bindsym Mod4+Shift+e exec swaymsg exit
    exec prismlauncher --launch "${cfg.instanceName}"
  '';

  waylandcraftSession = pkgs.writeShellApplication {
    name = "waylandcraft-session";
    runtimeInputs = [ config.programs.sway.package pkgs.prismlauncher pkgs.xwayland-satellite ];
    text = ''
      export __GL_THREADED_OPTIMIZATIONS=0
      export WLR_SCENE_DISABLE_DIRECT_SCANOUT=1
      export XDG_CURRENT_DESKTOP=sway
      systemctl --user start pipewire pipewire-pulse wireplumber || true
      exec sway --config ${swayConfig}
    '';
  };
  
  waylandcraftDesktopEntry = pkgs.writeTextFile {
    name = "waylandcraft-wayland-session";
    destination = "/share/wayland-sessions/waylandcraft.desktop";
    text = ''
      [Desktop Entry]
      Name=Waylandcraft (experimental!)
      Comment=Minecraft, but it's also your compositor
      Exec=${waylandcraftSession}/bin/waylandcraft-session
      Type=Application
    '';
  };
in
{
  options.programs.waylandcraft = {
    enable = mkEnableOption "waylandcraft as a selectable Wayland session";
    instanceName = mkOption {
      type = types.str;
      default = "Waylandcraft";
      description = "Name of the Prism Launcher instance to launch for the waylandcraft session.";
    };
  };
  
  config = mkIf cfg.enable {
    programs.sway.enable = true; # registers sway-session.target + polkit, etc.

    environment.systemPackages = [
      pkgs.libxkbcommon
      waylandcraftSession
    ];
    
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    xdg.portal.config.sway.default = mkForce [ "wlr" "gtk" ];
    services.displayManager.sessionPackages = [
      (pkgs.symlinkJoin {
        name = "waylandcraft-session-package";
        paths = [ waylandcraftSession waylandcraftDesktopEntry ];
        passthru.providedSessions = [ "waylandcraft" ];
      })
    ];
  };
}
