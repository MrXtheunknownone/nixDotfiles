{ pkgs, ...}:
{
  programs.keepassxc = {
    enable = true;
    autostart = true;
    settings = {
      Browser = {
        Enabled = true;
        UseCustomBrowser = true;
        CustomBrowserType = 3; # Vivaldi
      };
      GUI = {
        AdvandecSettings = true;
        ApplicationTheme = "dark";
      };
    };
  };
}
