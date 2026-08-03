{pkgs, ...}:
{
  environment.systemPackages = [
    pkgs.kitty
  ];

  users.users.tim.shell = pkgs.zsh;

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
