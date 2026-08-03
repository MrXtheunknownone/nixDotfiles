{ pkgs, ... }: {
  virtualisation.docker = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    # Nvim
    luarocks
    tree-sitter
    ast-grep
    prettier
    xmlformat

    # Languages
    gcc
    rustc
    cargo
    mdbook
    python3
    javacc
    jdk
    dart
    nodejs

    # Tools
    claude-code
    lazygit
  ];

  environment.sessionVariables = {
    PATH = [ "$HOME/.cargo/bin" ];
  };
}
