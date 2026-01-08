{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Timezone
  time.timeZone = "Asia/Bangkok";

  # Locales
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "th_TH.UTF-8";
    LC_IDENTIFICATION = "th_TH.UTF-8";
    LC_MEASUREMENT = "th_TH.UTF-8";
    LC_MONETARY = "th_TH.UTF-8";
    LC_NAME = "th_TH.UTF-8";
    LC_NUMERIC = "th_TH.UTF-8";
    LC_PAPER = "th_TH.UTF-8";
    LC_TELEPHONE = "th_TH.UTF-8";
    LC_TIME = "th_TH.UTF-8";
  };

  # Users
  users.users.phattaraphan = {
    isNormalUser = true;
    description = "Phattaraphan";
    extraGroups = [ "networkmanager" "wheel" "video" ]; # added video for NVIDIA
    packages = with pkgs; [
      discord
    ];
  };

  # Allow unfree packages (required for NVIDIA, VSCode)
  nixpkgs.config.allowUnfree = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    config.common.default = "hyprland";
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  #aliases
  environment.shellAliases = {
    brightset = "brightnessctl set";
    firefox = "firefox & disown";
    mute = "pamixer -m";
    unmute = "pamixer -u";
    prism = "prismlauncher & disown";
    px = "pamixer";
  };

  #pipewire
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    vscode
    kitty
    firefox
    gcc
    cmake
    gdb
    ninja
    python313
    python313Packages.pip
    git
    neofetch
    home-manager
    hyprpaper
    polkit_gnome
    brightnessctl
    prismlauncher
    unzip
    btop
    pamixer
  ];
  
  #enable polkit (PolicyKit) agent
  security.polkit.enable = true;

  # Kernel & NVIDIA
  boot.kernelParams = [
    "nvidia-drm.modeset=1" 
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    powerManagement.enable = true;
  };

  # Greetd login manager with session choice
  services.greetd = {
    enable = true;
    settings.default_session = {
        user = "phattaraphan";
        command = "Hyprland";
    };
    #greeter not specify
  };

  # Enable experimental Nix features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.05";
}
