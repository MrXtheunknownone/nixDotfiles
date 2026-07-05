{pkgs, ...}:
{
  programs.zsh = {
	enable = true;
 	enableCompletion = true;
	shellAliases =  {
		la = "ls -la";
  	};
  };
}
