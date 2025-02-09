{ config, pkgs, inputs, vars, ... }:

{
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  home.username = "${vars.username}";
  home.homeDirectory = "/home/${vars.username}";

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  home.packages =
    # Unstable user packages
    (with pkgs; [
      #nnn # terminal file manager

      # archives
      zip
      #xz
      unzip
      p7zip
      rar

      # utils
      #ripgrep # recursively searches directories for a regex pattern
      jq # A lightweight and flexible command-line JSON processor
      #yq-go # yaml processor https://github.com/mikefarah/yq
      #eza # A modern replacement for ‘ls’
      #fzf # A command-line fuzzy finder

      # networking tools
      mtr # A network diagnostic tool
      #iperf3
      dnsutils  # `dig` + `nslookup`
      ldns # replacement of `dig`, it provide the command `drill`
      #aria2 # A lightweight multi-protocol & multi-source command-line download utility
      socat # replacement of openbsd-netcat
      nmap # A utility for network discovery and security auditing
      ipcalc  # it is a calculator for the IPv4/v6 addresses

      # misc
      #cowsay
      #file
      #which
      #tree
      #gnused
      #gnutar
      #gawk
      #zstd
      #gnupg

      # productivity
      #hugo # static site generator
      #glow # markdown previewer in terminal

      #btop  # replacement of htop/nmon
      iotop # io monitoring
      iftop # network monitoring

      # system call monitoring
      strace # system call monitoring
      ltrace # library call monitoring
      lsof # list open files

      # system tools
      sysstat
      lm_sensors # for `sensors` command
      ethtool
      pciutils # lspci
      usbutils # lsusb

      discord
      discord-canary
      # plex-desktop
      transgui
      goverlay
      mangohud
      mpv
      yt-dlp
      streamlink
      streamlink-twitch-gui-bin
      spotify
      wl-clipboard
      tailscale
      trayscale
      microsoft-edge
      mouse-actions-gui
      wtype
      dotool
      kubectl
      lutris
      wine
      sqlitebrowser
      kcalc
      mission-center
      nvtopPackages.full
      lact
    ])

    ++

    # Stable user packages
    (with inputs.pkgs-stable.legacyPackages.${vars.system}; [

    ]);
    # ])

    # ++

    # # Pinned user packages
    # (with inputs.pkgs-20250204.legacyPackages.${vars.system}; [

    # ]);

  programs = {

    bash = {
      enable = true;
      enableCompletion = true;
      bashrcExtra = ''
        export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
      '';
      shellAliases = {
        update = ''cd ~/nix && nix flake update --flake . && sudo nixos-rebuild switch --flake path:. && git add flake.lock && git commit -m "$(date +'%Y%m%d')"'';
      };
    };

    vim = {
      enable = true;
      defaultEditor = true;
      settings = {
        shiftwidth = 2;
      };
      extraConfig = ''
        set encoding=utf-8
        set fileencoding=utf-8
        autocmd BufReadPost *
          \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
          \ |   exe "normal! g`\""
          \ | endif
      '';
    };

    git = {
      enable = true;
      userName = "${vars.git-username}";
      userEmail = "${vars.git-email}";
    };

    atuin = {
      enable = true;
      # daemon.enable = true;
      flags = [
        "--disable-up-arrow"
      ];
      settings = {
        sync_address = "https://atuin.${vars.webdomain}";
        auto_sync = true;
        sync_frequency = "5m";
        enter_accept = true;
        filter_mode = "host";
        inline_height = 0;
      };
    };

    firefox = {
      enable = true;
    };

    vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        pkgs.vscode-extensions.bbenoist.nix
      ];
    };

    starship = {
      enable = true;
      settings = {
        format = "$all$nix_shell$nodejs$lua$golang$rust$php$git_branch$git_commit$git_state$git_status\n$username$hostname$directory";
        add_newline = true;
        aws.disabled = true;
        gcloud.disabled = true;
        line_break.disabled = true;
      };
    };

  };

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # home.file.".local.bin".enable = true;
  # home.file.".local.bin/start-streamlink.sh" = {
  #   executable = true;
  #   source = config.lib.file.mkOutOfStoreSymlink "/mnt/nas/storage/alltskräpivärldenmappen/script/start-streamlink.sh";
  # };

  # home.file = {
  #   Downloads.source = config.lib.file.mkOutOfStoreSymlink ./fetchhm.nix;
  #   Downloads.target = "testDownloads";
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';
}
