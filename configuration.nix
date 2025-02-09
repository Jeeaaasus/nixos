{ config, pkgs, inputs, vars, ... }:

{
  system.stateVersion = "24.11";

  imports = [
    ./hardware-configuration.nix
    ./ceph.nix
  ];

  nix.gc = {
    automatic = true;
    dates = "19:00";
    options = "--delete-older-than 14d";
  };

  nix.settings.auto-optimise-store = true;

  nixpkgs.config.allowUnfree = true;

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 16;  # Limit the number of generations displayed on boot
  };

  boot.kernelParams = [
    "ipv6.disable=1"
  ];

  networking.hostName = "${vars.hostname}";

  networking.networkmanager.enable = true;

  users.users.${vars.username} = {
    isNormalUser = true;
    description = "${vars.username}";
    extraGroups = [ "networkmanager" "wheel" "input" ];
  };

  security.sudo.extraRules= [{
    users = [ "${vars.username}" ];
    commands = [{
      command = "/run/current-system/sw/bin/nixos-rebuild";
      options= [ "SETENV" "NOPASSWD" ];
    }];
  }];

  services.xserver.xkb = {
    layout = "${vars.keyboard-layout}";
    variant = "${vars.keyboard-variant}";
  };
  console.keyMap = "${vars.console-keymap}";

  time.timeZone = "${vars.timezone}";

  hardware.graphics.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  services.desktopManager.plasma6.enable = true;

  i18n.defaultLocale = "${vars.locale-default}";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "${vars.locale-address}";
    LC_IDENTIFICATION = "${vars.locale-identification}";
    LC_MEASUREMENT = "${vars.locale-measurement}";
    LC_MONETARY = "${vars.locale-monetary}";
    LC_NAME = "${vars.locale-name}";
    LC_NUMERIC = "${vars.locale-numeric}";
    LC_PAPER = "${vars.locale-paper}";
    LC_TELEPHONE = "${vars.locale-telephone}";
    LC_TIME = "${vars.locale-time}";
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;  # OR media-session.enable = true;
  #  jack.enable = true;  # If you want to use JACK applications
  };
  security.rtkit.enable = true;

  environment.systemPackages =
    # Unstable system packages
    (with pkgs; [
    ])

    ++

    # Stable system packages
    (with inputs.pkgs-stable.legacyPackages.${vars.system}; [
      vim
      git
      ceph-client
    ]);

  services = {

    flatpak = {
      enable = true;
    };

    # clamav = {
    #   daemon.enable = true;
    #   updater.enable = true;
    #   clamonacc.enable = true;
    #   daemon.settings = {
    #       OnAccessPrevention = true;
    #       OnAccessIncludePath = "/home/${vars.username}";
    #       OnAccessIncludePath = "${vars.ceph-directory1}/download";
    #   };
    # };

    duplicati = {
      enable = true;
      user = "root";
    };

    tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };

    open-webui = {
      enable = true;
      host = "0.0.0.0";
      package = inputs.pkgs-20250204.legacyPackages.${vars.system}.open-webui;
    };

    ollama = {
      enable = true;
      acceleration = "rocm";
      rocmOverrideGfx = "11.0.0";
    };
  };

  programs = {

    gamemode = {
      enable = true;
    };

    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
  };
}
