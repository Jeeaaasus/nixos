{ pkgs, vars, pkgs_stable, pkgs_20260414,... }:

{
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  home.username = "${vars.username}";
  home.homeDirectory = "/home/${vars.username}";

  home.file = {

    # Input-remapper configuration
    ".config/input-remapper-2/presets/Logitech MX Keys/ctrl-l+alt-l+v-paste-code-block.json" = {
      enable = true;
      force = true;
      source = ./input-remapper/ctrl-l+alt-l+v-paste-code-block.json;
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
      nixfmt                     # Nix formatting library
      caligula                   # disk imaging CLI tool
      mission-center             # general resource overview application
      amdgpu_top                 # graphics resource overview application
      cpu-x                      # system information overview application
      firefox                    # web browser application
      brave                      # web browser application
      vesktop                    # third-party Discord application
      obsidian                   # notes application
      transgui                   # Transmission management application
      spotify                    # music player application
      streamlink                 # Twitch viewing CLI tool
      streamlink-twitch-gui-bin  # Twitch viewing application
      yt-dlp                     # YouTube download CLI tool
      oniux                      # Tor CLI tool
      pangolin-cli               # VPN client
      # fabric-ai
      # goverlay
      # mangohud
      # wtype
      # mouse-actions-gui
      # dotool
      # lact
    ])

    ++

    (with pkgs_stable; [
    ])

    ++

    (with pkgs_20260414; [
      jellyfin-desktop           # media player application
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
        update = ''cd ~/nix && sudo nh os boot --bypass-root-check --update --ask path:. && git add flake.lock && git commit -m "$(date +'%Y%m%d')" -m "$(nix shell nixpkgs#nvd -c nvd diff $(ls -dt /nix/var/nix/profiles/* | head -3 | tail -2 | tac) | tail +3 | awk '{gsub(/-${vars.hostname}/, sprintf("%${toString (builtins.stringLength vars.hostname + 1)}s", "")); print}')"'';
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
          echo | nix shell nixpkgs#openssl -c openssl s_client -connect "''${1}:''${2:-443}" 2> /dev/null | nix shell nixpkgs#openssl -c openssl x509 -noout -subject -dates -text | awk '
          /^subject=/ { print }
          /^notBefore=/ { print }
          /^notAfter=/ { print }
          /Subject Alternative Name/ {
            getline
            gsub(/^[ \t]+/, "", $0)
            print "Subject Alternative Names: " $0
          }'
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
      settings = {
        user = {
          name = "${vars.git-username}";
          email = "${vars.git-email}";
        };
      };
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
        strip_trailing_whitespace = false;
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
        force-window = "yes";
        volume = "60";
        volume-max = "200";
        af = "lavfi=[loudnorm=I=-16:TP=-3:LRA=4],lavfi=[dynaudnorm=g=8:f=500:r=0.1:p=0.9]";
        cache = "yes";
        force-seekable = "yes";
        demuxer-seekable-cache = "yes";
        demuxer-donate-buffer = "no";
        demuxer-max-bytes = "32GiB";
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
      #   KP_MULTIPLY             set speed 2
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

    zed-editor = {
      enable = true;
      extensions = [
        "nix"
      ];
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
