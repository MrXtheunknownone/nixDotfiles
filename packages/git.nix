{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
    lazygit
    git-credential-oauth
  ];

  home-manager.users.tim = {
    programs.git = {
      enable = true;

      aliases = {
        adog  = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(white)(%ar)%C(reset) %C(bold green)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all";
        adogs = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'";
        diffh = "diff HEAD --name-status";
        sm    = "!git switch main && git pull origin";
        ac    = ''!f() { git add . && git commit -m "$@"; }; f'';
        acp   = ''!f() { git add . && git commit -m "$@"; git push; }; f'';
        pmp   = ''!git stash -um "Stashing for origin/main into $(git rev-parse --abbrev-ref HEAD)" && git pull origin main && git stash pop'';
      };

      diff.tool  = "nvimdiff";
      merge.tool = "nvimdiff";

      extraConfig = {
        include.path         = "~/.config/git/identity";
        pull.rebase          = false;
        mergetool.keepBackup = false;
        credential.helper    = "oauth";
      };
    };
  };
}
