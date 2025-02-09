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

  home.file = {

    # Input-remapper configuration
    ".config/input-remapper-2/presets/Logitech MX Keys/ctrl-l+alt-l+v-paste-code-block.json" = {
      enable = true;
      force = true;
      source = ./input-remapper/ctrl-l+alt-l+v-paste-code-block.json;
    };

    # Plex configuration - needs to manually be applied to "mpv.conf" as Plex overwrites the symlink on startup
    ".var/app/tv.plex.PlexDesktop/data/plex/mpv2.conf" = {
      enable = true;
      force = true;
      text = ''
        initial-audio-sync=no
        af=lavfi=[loudnorm=I=-16:TP=-3:LRA=4],lavfi=[dynaudnorm=g=8:f=500:r=0.1:p=0.9]
      '';
    };
    # ".var/app/tv.plex.PlexDesktop/data/plex/input.conf" = {
    #   enable = true;
    #   force = true;
    #   text = ''
    #   '';
    # };

  };

  home.packages =

    # Unstable packages
    (with pkgs; [
      #nnn # terminal file manager

      # archives
      zip
      #xz
      unzip
      p7zip
      rar

      # utils
      #ripgrep  # recursively searches directories for a regex pattern
      jq  # A lightweight and flexible command-line JSON processor
      #yq-go  # yaml processor https://github.com/mikefarah/yq
      #eza  # A modern replacement for ‘ls’
      #fzf  # A command-line fuzzy finder

      # networking tools
      mtr  # A network diagnostic tool
      #iperf3
      dnsutils  # `dig` + `nslookup`
      ldns  # replacement of `dig`, it provide the command `drill`
      #aria2  # A lightweight multi-protocol & multi-source command-line download utility
      socat  # replacement of openbsd-netcat
      nmap  # A utility for network discovery and security auditing
      ipcalc   # it is a calculator for the IPv4/v6 addresses

      #btop  # replacement of htop/nmon
      iotop  # io monitoring
      iftop  # network monitoring

      # system call monitoring
      strace  # system call monitoring
      ltrace  # library call monitoring
      lsof  # list open files

      # system tools
      sysstat
      lm_sensors  # for `sensors` command
      ethtool
      pciutils  # lspci
      usbutils  # lsusb

      firefox
      # discord
      discord-canary
      # plex-desktop
      transgui
      goverlay
      mangohud
      yt-dlp
      streamlink
      streamlink-twitch-gui-bin
      spotify
      wl-clipboard
      tailscale
      trayscale
      brave
      mouse-actions-gui
      wtype
      dotool
      kubectl
      lutris
      wine
      sqlitebrowser
      kdePackages.kcalc
      mission-center
      nvtopPackages.full
      lact
      fabric-ai
      obsidian
    ])

    ++

    # Stable packages
    (with inputs.pkgs-stable.legacyPackages.${vars.system}; [
    ]);

  programs = {

    readline = {
      enable = true;
      extraConfig = ''
        set completion-ignore-case on
      '';
    };

    bash = {
      enable = true;
      enableCompletion = true;
      shellAliases = {
        rebuild = ''cd ~/nix && sudo nixos-rebuild switch --flake path:.'';
        update = ''cd ~/nix && nix flake update --flake . && sudo nixos-rebuild switch --flake path:. && git add flake.lock && git commit -m "$(date +'%Y%m%d')"'';
      };
      bashrcExtra = ''
        export PATH="$PATH:$HOME/bin:$HOME/.local/bin"
      '';
      initExtra = ''
        # VSCODE OPEN REMOTE FOLDER
        function coderemote () {
          if [ -z "$1" ]; then echo 'usage: <hostname> [remote-path] (default: your home folder)'; echo 'You need to provide hostname/IP to connect to.'; return 1; fi
          code --remote "ssh-remote+''${1}" "''${2:-~/}"
        }
      '';
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
        set number
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
      signing.format = "ssh";
    };

    atuin = {
      enable = true;
      flags = [
        "--disable-up-arrow"
      ];
      settings = {
        sync_address = "https://atuin.${vars.webdomain}";
        sync_frequency = "5m";
        auto_sync = true;
        workspaces = true;
        enter_accept = true;
        filter_mode = "host";
        inline_height = 0;
      };
    };

    mpv = {
      enable = true;
      config = {
        wayland-present = "yes";
        hwdec = "auto";
        vo = "gpu-next";
        initial-audio-sync = "no";
        fullscreen = "yes";
        autofit-larger = "80%x80%";
        volume = "60";
        volume-max = "200";
        af = "lavfi=[loudnorm=I=-16:TP=-3:LRA=4],lavfi=[dynaudnorm=g=8:f=500:r=0.1:p=0.9]";
        cache = "yes";
        force-seekable = "yes";
        demuxer-seekable-cache = "yes";
        demuxer-donate-buffer = "no";
        demuxer-max-bytes = "20GiB";
        demuxer-max-back-bytes = "512MiB";
        demuxer-force-retry-on-eof = "yes";
      };
      # bindings = {
      # };
      scripts = with pkgs.mpvScripts; [
        mpris
      ];
    };

    vscode = {
      enable = true;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        bbenoist.nix  # Nix language syntax highlighting
        ms-vscode-remote.remote-ssh  # open remote folder via ssh
        ms-python.python  # Python language syntax highlighting
      ];
    };

    thunderbird = {
      enable = true;
      profiles = {
        default = {
          isDefault = true;
        };
      };
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
