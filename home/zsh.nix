{ ... }:
{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;

    autosuggestion.enable     = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch    = {
      enable = true;
      searchUpKey   = [ "^[[A" "^P" ];
      searchDownKey = [ "^[[B" "^N" ];
    };

    history = {
      size       = 10000;
      save       = 10000;
      ignoreDups = true;
      share      = true;
    };

    shellAliases = {
      la      = "ls -la";
      ll      = "ls -l";
      nv      = "nvim";
      rebuild = "sudo nixos-rebuild switch --flake /home/tim/.dotfiles";
    };

    # The Ctrl + Y has to be checked, because it can also mean yank
    initContent = ''
      bindkey '^Y' autosuggest-accept
    '';

  };

  programs.starship = {
    enable = true;
    settings = {
      # Active prompt: two lines
      format = ''
        [╭](fg:#6d748c)[$username$hostname](bg:#1c3c55 fg:#41c4f7)[ ](fg:#1c3c55 bg:#2f3749)[$directory](bg:#2f3749 fg:#d2d5df)[](fg:#2f3749 bg:#2a7193)$git_branch$git_status[](fg:#2a7193)$cmd_duration
        [╰─](fg:#6d748c)$character'';

      username = {
        format      = "[ $user](bg:#1c3c55 fg:#41c4f7)";
        show_always = true;
      };

      hostname = {
        format    = "[@$hostname ](bg:#1c3c55 fg:#41c4f7)";
        ssh_only  = false;
      };

      directory = {
        format            = "[ $path ]($style)";
        style             = "bg:#2f3749 fg:#d2d5df";
        truncation_length = 4;
        truncate_to_repo  = true;
      };

      git_branch = {
        format = "[ $symbol$branch ]($style)";
        symbol = " ";
        style  = "bg:#2a7193 fg:#f3f4f7";
      };

      git_status = {
        format    = "[$all_status$ahead_behind ]($style)";
        style     = "bg:#2a7193 fg:#ff977b";
        ahead     = "⇡$count";
        behind    = "⇣$count";
        diverged  = "⇕⇡$ahead_count⇣$behind_count";
        untracked = "?";
        stashed   = "≡";
        modified  = "!";
        staged    = "+";
        renamed   = "»";
        deleted   = "✘";
      };

      cmd_duration = {
        format   = " [ $duration]($style)";
        style    = "fg:#ff977b";
        min_time = 2000;
      };

      character = {
        success_symbol = "[❯](bold fg:#4daa6e)";
        error_symbol   = "[❯](bold fg:#e7442a)";
      };
    };
  };
}
