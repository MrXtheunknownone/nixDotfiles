{pkgs, ...}:
{
  programs.zsh = {
	enable = true;
 	enableCompletion = true;
	shellAliases =  {
		la = "ls -la";
    nv = "nvim";
    rebuild = "sudo nixos-rebuild switch --flake /home/tim/.dotfiles";
  	};
  };
}
