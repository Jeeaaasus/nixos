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
    options = "--delete-older-than 7d";
  };

  nix.settings.auto-optimise-store = true;

  nixpkgs.config.allowUnfree = true;

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 32;
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
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC9OScqsLoVi4C/tf3L8f8eU7GtgJlPTckoQH6+pn84c12t9DsLk+3mXFETSRZDKcRP/3+up4X4/J6zAvhqTsYa/2xbYd1PZoBh4v6aGXFWCMGFpxSc5k8VP6m1YWPllbt4DJmIy78QFxrRP0jzusImkI2XOqtfc1cp4nd7pNV6PiX8wx4VDCY1cwJy5fosSJyUWIP21v0fs+owYs+vrlQaZiN6NrkXmLmj9ogaSW5kXfGE4lnI1847QwW3w8v1A4ataOVa8Iyfq7t4Bnkt5ZA8lNEvHlH0Z0Z2gP47FPKIAM9wttV/QMyQMT0VEVor3i/Y9RfoRHfBBukDUFRESO/P desktop"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC4ekww8I9AZBMJqfIskGjd1+UoUfxnt8F86jZc22nSR+kn6JEMQ1ONob7PRZu3BEGYfCc9w3zIJlpCpTgSupxLx1TAKuNOUzPWCHwwMpR5dI5hVzaQJbaBnDAFIfSS/Ccql4iuzdi+vzDrpITZxj84vQZtyQd+Nensou+pVtkNtwLjYLwD8N04xnHGX2XLcTrTaw5OQKKrAXeNJUJUhce/ibSFl46LV2s1hYdgYc9kQCdPI038w+NpkOKFI+WhfUZXBcH0pN0YDbKESoeuLfRgVgATIeV8Vcx80TJxunqN7qL2GUdMhwmLwGdEaf44tu5sTIU/ZaEX8Dm2VeBShoQKgH59Xp53yqzE9x6CjvvwUWPiZzL11CfxBQ7RMQ7gz9CIaK+GfUjJ32nlHsqd1UD1Ayk4bRP/avypbjClmUtVN9TzsEePzxfzkOgjfy/BjetZMZfIxa+JkgUH0tg2s1SRUmG56vEQHuIQHmSoDUAPfKF/f/85GcCKKVnImDSSTEc= mobile"
    ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
    };
  };

  security.sudo.extraRules= [{
    users = [ "${vars.username}" ];
    commands = [{
      command = "/run/current-system/sw/bin/nixos-rebuild";
      options= [ "SETENV" "NOPASSWD" ];
    }];
  }];

  services.xserver.xkb = {
    layout = if (vars ? keyboard-layout) && vars.keyboard-layout != "" then vars.keyboard-layout else "se";
    variant = if (vars ? keyboard-variant) && vars.keyboard-variant != "" then vars.keyboard-variant else "";
  };
  console.keyMap = if (vars ? console-keymap) && vars.console-keymap != "" then vars.console-keymap else "sv-latin1";

  time.timeZone = if (vars ? timezone) && vars.timezone != "" then vars.timezone else "Europe/Stockholm";

  hardware.graphics.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  services.desktopManager.plasma6.enable = true;

  i18n.extraLocaleSettings = {
    LC_ALL = vars.locale-default;
    LC_ADDRESS = if (vars ? locale-address) && vars.locale-address != "" then vars.locale-address else vars.locale-default;
    LC_IDENTIFICATION = if (vars ? locale-identification) && vars.locale-identification != "" then vars.locale-identification else vars.locale-default;
    LC_MEASUREMENT = if (vars ? locale-measurement) && vars.locale-measurement != "" then vars.locale-measurement else vars.locale-default;
    LC_MONETARY = if (vars ? locale-monetary) && vars.locale-monetary != "" then vars.locale-monetary else vars.locale-default;
    LC_NAME = if (vars ? locale-name) && vars.locale-name != "" then vars.locale-name else vars.locale-default;
    LC_NUMERIC = if (vars ? locale-numeric) && vars.locale-numeric != "" then vars.locale-numeric else vars.locale-default;
    LC_PAPER = if (vars ? locale-paper) && vars.locale-paper != "" then vars.locale-paper else vars.locale-default;
    LC_TELEPHONE = if (vars ? locale-telephone) && vars.locale-telephone != "" then vars.locale-telephone else vars.locale-default;
    LC_TIME = if (vars ? locale-time) && vars.locale-time != "" then vars.locale-time else vars.locale-default;
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

    input-remapper = {
      enable = true;
      enableUdevRules = true;
    };

    tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };

    open-webui = {
      enable = true;
      host = "0.0.0.0";
      # package = inputs.pkgs-20250216.legacyPackages.${vars.system}.open-webui;
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
