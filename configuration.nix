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
  # Networking for spotify
  networking.firewall.allowedTCPPorts = [ 57621 ]; #sync local tracks from your filesystem with mobile devices in the same network
  networking.firewall.allowedUDPPorts = [ 5353 ]; #enable discovery of Google Cast devices (and possibly other Spotify Connect devices) in the same network by the Spotify app

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
    packages = with pkgs; [];
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

  # Font configuration
  fonts = {
    packages = with pkgs; [
      ubuntu-classic       # Provides Ubuntu Mono
      noto-fonts   # Thai fallback
    ];

    fontconfig = {
      defaultFonts = {
        # This sets the order of preference for monospace (used by Kitty)
        monospace = [ "Ubuntu Mono" "Noto Sans Thai" ];
        serif     = [ "Ubuntu" "Noto Serif Thai" ];
        sansSerif = [ "Ubuntu" "Noto Sans Thai" ];
      };
    };
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
    discord = "discord & disown";
    spotify = "spotify & disown";
    sober = "flatpak run org.vinegarhq.Sober & disown";
  };

  #git configs
  environment.etc."gitconfig".text = ''
    [user]
      name = phattaraphan
      email = tonaok255@gmail.com
  '';

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
    discord
    spotify
    asusctl
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
    settings = {
      default_session = {
        # Use tuigreet to ask for credentials before starting Hyprland
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter"; 
      };
    };
  };

  # Enable experimental Nix features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.05";
}
