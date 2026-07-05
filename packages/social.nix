{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
	mattermost
	discord
  ];
}
