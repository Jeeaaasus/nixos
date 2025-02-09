{ config, pkgs, inputs, vars, ... }:

{
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  home.username = "${vars.username}";
  home.homeDirectory = "/home/${vars.username}";

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 32;
    "Xft.dpi" = 172;
  };

  home.file = {

    # Input-remapper configuration
    ".config/input-remapper-2/presets/Logitech MX Keys/ctrl-l+alt-l+v-paste-code-block.json" = {
      enable = true;
      force = true;
      source = ./input-remapper/ctrl-l+alt-l+v-paste-code-block.json;
    };

    # Plex configuration
    ".var/app/tv.plex.PlexDesktop/data/plex/mpv.txt" = {  # needs to manually be copied into "mpv.conf" as flatpak Plex dislikes symlinks
    # ".local/share/plex/mpv.conf" = {
      enable = true;
      force = true;
      text = ''
        include="~~/profiles.conf"
        af-pre=@dynaudnorm:lavfi=[dynaudnorm=g=8:f=500:r=0.1:p=0.9]
      '';
    };
    ".var/app/tv.plex.PlexDesktop/data/plex/input.txt" = {  # needs to manually be copied into "input.conf" as flatpak Plex dislikes symlinks
    # ".local/share/plex/input.conf" = {
      enable = true;
      force = true;
      text = ''
        # Video frame - Position
        Ctrl+Alt+left   add video-pan-x +0.01
        Ctrl+Alt+right  add video-pan-x -0.01
        Ctrl+Alt+up     add video-pan-y +0.01
        Ctrl+Alt+down   add video-pan-y -0.01

        # Video frame - Flip
        Ctrl+f          cycle-values vf hflip !hflip
        Alt+f           cycle-values vf vflip !vflip
        Ctrl+Alt+f      cycle-values vf hflip,vflip !hflip,!vflip

        # Video frame - Zoom
        Ctrl+Alt++      add video-zoom  +0.1
        Ctrl+Alt+-      add video-zoom  -0.1
        Ctrl+Alt+0      set video-zoom 0 ; set video-pan-x 0 ; set video-pan-y 0

        # Audio
        Alt+0           set audio-delay 0
        Alt++           add audio-delay +0.01
        Alt+-           add audio-delay -0.01

        # Playback
        Ctrl+right      frame-step
        Ctrl+left       frame-back-step
        0               set speed 1
        *               set speed 1.75
        +               add speed +0.1
        -               add speed -0.1

        # Other
        I                       script-binding stats/display-stats-toggle
      '';
    };
    ".var/app/tv.plex.PlexDesktop/data/plex/profiles.txt" = {  # needs to manually be copied into "profiles.conf" as flatpak Plex dislikes symlinks
    # ".local/share/plex/profiles.conf" = {
      enable = true;
      force = true;
      text = ''
        [HDR]
        profile-cond=hdr_metadata or (video-params/primaries == "bt.2020" and video-params/gamma == "pq")
        target-trc=pq
        target-peak=1000
        d3d11-output-csp=pq
        target-prim=bt.2020
        hdr-compute-peak=yes
        target-contrast=auto
        video-output-levels=full
        target-colorspace-hint=yes
        d3d11-output-format=rgba32f

        [2ch-audio-settings]
        profile-cond=get("audio-params/channel-count") < 3
        profile-restore=copy-equal
        af-pre=@loudnorm:lavfi=[loudnorm=I=-16:TP=-3:LRA=4]

        [streams]
        profile-cond=p["estimated-vf-fps"]>58
        # profile-cond=require 'mp.utils'.join_path(working_directory, path):match('\\nas-ssd\\')
        profile-restore=copy-equal
        initial-audio-sync=no
        speed=1.75
      '';
    };

    # Jellyfin global media keys support
    ".local/share/jellyfinmediaplayer/scripts/mpris.so" = {
      source = builtins.fetchurl {
        url = "https://github.com/hoyon/mpv-mpris/releases/download/1.0/mpris.so";
        sha256 = "0zqk3p9g3lbxdzc1i8pm0m08wzp2yrws4gxqn1ra8pc7zkyc7jz0";
      };
    };

  };

  home.packages =

    # Unstable packages
    (with pkgs; [
      # (package.overrideAttrs (oldAttrs: rec { version = "app_version"; src = fetchPypi { inherit version; pname = "package"; hash = ""; }; }))  # version override example
      nh                         # NixOS management CLI tool
      screen                     # terminal multiplexer CLI tool
      zip                        # archive management library
      unzip                      # archive management library
      p7zip                      # archive management library
      rar                        # archive management library
      wl-clipboard               # clipboard management library
      playerctl                  # media player control library
      kdePackages.kcalc          # calculator application
      nixd                       # Nix LSP library
      nixfmt-rfc-style           # Nix formatting library
      caligula                   # disk imaging CLI tool
      mission-center             # general resource overview application
      nvtopPackages.full         # graphics resource overview application
      firefox                    # web browser application
      brave                      # web browser application
      discord-canary             # chat application
      obsidian                   # notes application
      transgui                   # Transmission management application
      jellyfin-media-player      # media player application
      spotify                    # music player application
      streamlink                 # Twitch viewing CLI tool
      streamlink-twitch-gui-bin  # Twitch viewing application
      yt-dlp                     # YouTube download CLI tool
      wine                       # Windows emulation library
      lutris                     # Windows games emulation application
      tailscale                  # VPN CLI tool
      trayscale                  # Tailscale VPN application
      oniux                      # Tor CLI tool
      # fabric-ai
      # goverlay
      # mangohud
      # wtype
      # mouse-actions-gui
      # dotool
      # lact
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
        rebuild = ''cd ~/nix && sudo nh os switch --bypass-root-check path:.'';
        update = ''cd ~/nix && sudo nh os switch --bypass-root-check --update --ask path:. && git add flake.lock && git commit -m "$(date +'%Y%m%d')" -m "$(nix shell nixpkgs#nvd -c nvd diff $(ls -dt /nix/var/nix/profiles/* | head -3 | tail -2 | tac) | tail +3 | awk '{gsub(/-${vars.hostname}/, sprintf("%${builtins.toString (builtins.stringLength vars.hostname + 1)}s", "")); print}')"'';
        dev = ''nix develop'';
        gs = ''git status'';
        jq = ''nix shell nixpkgs#jq -c jq'';
        nslookup = ''nix shell nixpkgs#dig -c nslookup'';
        ncdu = ''nix shell nixpkgs#ncdu -c ncdu'';
      };
      bashrcExtra = ''
        export PATH="$PATH:$HOME/bin:$HOME/.local/bin"
      '';
      initExtra = ''
        # REMOVE HOST FROM KNOWN_HOSTS FILE
        function rm-known_hosts () {
          ssh-keygen -R "$(echo "$1" | cut -d '@' -f 2)"
        }
        # CHECK REMOTE SSL CERTIFICATE
        function ssl-check () {
          if [ -z "$1" ]; then echo 'usage: ssl-check <url> [port] (default: 443)'; echo 'You need to provide a URL to connect to.'; return 1; fi
          echo | nix shell nixpkgs#openssl -c openssl s_client -connect "''${1}:''${2:-443}" 2> /dev/null | nix shell nixpkgs#openssl -c openssl x509 -subject -noout -dates
        }
        # VSCODE OPEN REMOTE FOLDER
        function code-remote () {
          if [ -z "$1" ]; then echo 'usage: code-remote <hostname> [remote-path] (default: your home folder)'; echo 'You need to provide hostname/IP to connect to.'; return 1; fi
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
        gpu-context = "wayland";
        hwdec = "auto";
        vo = "gpu-next";
        # gpu-api = "opengl";
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
        demuxer-max-bytes = "16GiB";
        demuxer-max-back-bytes = "512MiB";
        # demuxer-force-retry-on-eof = "yes";
      };
      # bindings = {  # TODO: convert
      #   # Basics
      #   SPACE                   cycle pause
      #   MBTN_RIGHT              cycle pause
      #   ENTER                   cycle fullscreen
      #   MBTN_LEFT_DBL           cycle fullscreen
      #   right                   no-osd seek +30
      #   left                    no-osd seek -10
      #   Alt+x                   quit
      #   1                       cycle border
      #   Ctrl+t                  cycle ontop
      #   k                       cycle-values keep-open yes no

      #   # Video frame - Position
      #   Ctrl+left               add video-pan-x +0.01
      #   Ctrl+right              add video-pan-x -0.01
      #   Ctrl+up                 add video-pan-y +0.01
      #   Ctrl+down               add video-pan-y -0.01

      #   # Video frame - Zoom
      #   Ctrl+Alt+KP_ADD         add video-zoom  +0.1
      #   Ctrl+Alt+KP_SUBTRACT    add video-zoom  -0.1
      #   Ctrl+Alt+KP0            set video-zoom 0 ; set video-pan-x 0 ; set video-pan-y 0

      #   # Video frame - Flip
      #   Ctrl+f                  cycle-values vf hflip !hflip
      #   Alt+f                   cycle-values vf vflip !vflip
      #   Ctrl+Alt+f              cycle-values vf hflip,vflip !hflip,!vflip

      #   # Audio
      #   Ctrl+a                  cycle_values audio-device "auto"
      #   m                       cycle mute
      #   up                      add volume +10
      #   down                    add volume -10
      #   WHEEL_UP                add volume +10
      #   WHEEL_DOWN              add volume -10
      #   Alt+KP0                 set audio-delay 0
      #   Alt+KP_ADD              add audio-delay +0.01
      #   Alt+KP_SUBTRACT         add audio-delay -0.01

      #   # Video playback
      #   Ctrl+right              frame-step
      #   Ctrl+left               frame-back-step
      #   KP0                     set speed 1
      #   KP_MULTIPLY             set speed 1.75
      #   KP_ADD                  add speed +0.1
      #   KP_SUBTRACT             add speed -0.1

      #   # Other
      #   I                       script-binding stats/display-stats-toggle
      #   Ctrl+e                  loadfile "${path}"
      # };
      scripts = with pkgs.mpvScripts; [
        mpris
      ];
    };

    vscode = {
      enable = true;
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          jnoortheen.nix-ide           # Nix language syntax highlighting
          ms-vscode-remote.remote-ssh  # open remote folder via ssh
          ms-python.python             # Python language syntax highlighting
        ];
        userSettings = {
          "extensions.autoCheckUpdates" = false;
          "update.mode" = "none";
          "editor.tabSize" = 2;
          "nix.serverPath" = "nixd";
          "nix.enableLanguageServer" = true;
          "nix.serverSettings" = {
            "nixd" = {
              "formatting" = {
                "command" = [ "nixfmt" ];
              };
            };
            # "options" = {
            #   "nixos" = {
            #     "expr" = "(builtins.getFlake \"/PATH/TO/FLAKE\").nixosConfigurations.CONFIGNAME.options";
            #   };
            # };
          };
        };
      };
    };

    thunderbird = {
      enable = false;
      profiles = {
        vars.username = {
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
