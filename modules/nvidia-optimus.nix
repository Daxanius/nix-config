# https://nixos.wiki/wiki/Nvidia
{ config, lib, pkgs, modulesPath, ... }:

let
  cfg = config.hardware.nvidia-optimus;
in
{
  options.hardware.nvidia-optimus.enable =
    lib.mkEnableOption "Nvidia Optimus support";

  options.hardware.nvidia-optimus = {
    intelBusId = lib.mkOption {
      type = lib.types.str;
      description = "Intel GPU bus ID";
    };

    nvidiaBusId = lib.mkOption {
      type = lib.types.str;
      description = "NVIDIA GPU bus ID";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "gpu-run" ''
        export __NV_PRIME_RENDER_OFFLOAD=1
        export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        export __VK_LAYER_NV_optimus=NVIDIA_only
        exec "$@"
      '')
    ];

    # Enable OpenGL
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = [
      "modesetting"
      "nvidia"
    ];

    hardware.nvidia = {
      # Modesetting is required.
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      # Enable this if you have graphical corruption issues or application crashes after waking
      # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
      # of just the bare essentials.
      powerManagement.enable = false;

      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = false;

      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of 
      # supported GPUs is at: 
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
      # Only available from driver 515.43.04+
      open = true;

      # Enable the Nvidia settings menu,
      # accessible via `nvidia-settings`.
      nvidiaSettings = true;

      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };

        intelBusId = cfg.intelBusId;
        nvidiaBusId = cfg.nvidiaBusId;
      };
    };
  };
}
