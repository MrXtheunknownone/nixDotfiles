{ pkgs, ...}:
{
  programs.keepassxc = {
    enable = true;
    autostart = true;
    settings = {
      # Browser integration only needs to be enabled here — the native
      # messaging manifest below is what actually wires up the browser.
      Browser.Enabled = true;
      GUI = {
        AdvancedSettings = true;
        ApplicationTheme = "dark";
      };
    };
  };

  # Native messaging host so the KeePassXC-Browser extension in Vivaldi can
  # reach KeePassXC via keepassxc-proxy. Chromium looks up native hosts by
  # "<host-name>.json"; the allowed_origins are the Chrome/Edge store IDs of
  # the KeePassXC-Browser extension (verified against KeePassXC source).
  xdg.configFile."vivaldi/NativeMessagingHosts/org.keepassxc.keepassxc_browser.json".text =
    builtins.toJSON {
      name = "org.keepassxc.keepassxc_browser";
      description = "KeePassXC integration with native messaging support";
      type = "stdio";
      path = "${pkgs.keepassxc}/bin/keepassxc-proxy";
      allowed_origins = [
        "chrome-extension://pdffhmdngciaglkoonimfcmckehcpafo/"
        "chrome-extension://oboonakemofpalcgghocfoadofidjkkk/"
      ];
    };
}
