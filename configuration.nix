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
  networking.timeServers = [ "time.google.com" "time1.google.com" "pool.ntp.org" ];

  # Networking for spotify
  networking.firewall.allowedTCPPorts = [ 57621 ]; #sync local tracks from your filesystem with mobile devices in the same network
  networking.firewall.allowedUDPPorts = [ 5353 ]; #enable discovery of Google Cast devices (and possibly other Spotify Connect devices) in the same network by the Spotify app

  # Timezone
  time.timeZone = "Asia/Bangkok";
  services.timesyncd = {
    enable = true;
    servers = [ "time.google.com" "time1.google.com" "pool.ntp.org" ];
  };

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

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      qt6Packages.fcitx5-configtool
    ];
  };

  #github configs
  programs.git = {
    enable = true;
    config = {
      user = {
        name = "pxzc1";
        email = "tonaok2555@gmail.com";
      };
    };
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
  
  services.asusd.enable = true;
  # services.supergfxd.enable = true; (remove # if want hybrid graphics, iGPU + dGPU)

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    CUDA_PATH = "/run/opengl-driver";
    LD_LIBRARY_PATH = "/run/opengl-driver/lib:/run/opengl-driver-32/lib";
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
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

  # shell aliases
  environment.shellAliases = {
    brightset = "brightnessctl set";
    firefox = "setsid firefox >/dev/null 2>&1 &";
    mute = "pamixer -m";
    unmute = "pamixer -u";
    prism = "setsid prismlauncher >/dev/null 2>&1 &";
    px = "pamixer";
    discord = "setsid discord >/dev/null 2>&1 &";
    spotify = "setsid spotify >/dev/null 2>&1 &";
    sober = "setsid flatpak run org.vinegarhq.Sober >/dev/null 2>&1 &";
    nautilus = "setsid nautilus >/dev/null 2>&1 &";
    davinci = "setsid davinci-resolve >/dev/null 2>&1 &";
    vlc = "setsid vlc >/dev/null 2>&1 &";
    loupe = "f(){ setsid loupe \"$@\" >/dev/null 2>&1 & }; f";
    blender = "setsid blender >/dev/null 2>&1 &";
    obs = "setsid obs >/dev/null 2>&1 &";
    deact = "deactivate"; #only for deactivate from python virtualenv
  };

  services.printing.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;

  # pipewire
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

  # for nautilus file manager to avoid no mount, no trash, slow startup
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  programs.dconf.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    cudaPackages.cudatoolkit
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
    nautilus
    acpi
    tuigreet
    tree
    vlc
    loupe #eog (gnome) / feh (terminal-friendly)
    mako
    libnotify
    blender
    davinci-resolve
    obs-studio
    xxd
    bat
    fastfetch
    grim
    slurp
  ];
  
  # enable polkit (PolicyKit) agent
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
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true; # Merges identical files to save space
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # hides old stuff from the boot menu but keeps them on disk for 7 days.
  boot.loader.systemd-boot.configurationLimit = 5;

  system.stateVersion = "25.05";
}
