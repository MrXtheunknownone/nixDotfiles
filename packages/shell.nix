{pkgs, ...}:
{
  environment.systemPackages = [
    pkgs.kitty
  ];

  programs = {
    zsh = {
	    enable = true;
 	    enableCompletion = true;
	    shellAliases =  {
	    	la = "ls -la";
        nv = "nvim";
        rebuild = "sudo nixos-rebuild switch --flake /home/tim/.dotfiles";
      	};
    };
    foot = {
      enable = true;
    };
  };
}
