{pkgs, ...}:
{
 fonts = {
   enableDefaultPackages = true;
 
   packages = with pkgs; [
     pkgs.nerd-fonts.jetbrains-mono
   ];
 
   fontconfig = {
 	enable = true;
 	defaultFonts = {
 		monospace = [ "pkgs.nerd-fonts.jetbrains-mono" ];
 	};
   };
 };
}
