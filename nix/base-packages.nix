{
  pkgs,
  lib,
  config,
}:
with pkgs;
#let
#in
# Fetch Homebrew repo using Nix's `fetchgit`
# homebrewSource = pkgs.fetchgit {
#   url = "https://github.com/Homebrew/brew.git";
#   rev = "4.4.2"; # Tag to fetch
#   sha256 = "sha256-XbG97es3/k4xeOA2pOE/djgYvYnbx+Po91IXSBeGiS4="; # Replace with the correct hash
# };
# # Define the Homebrew binaries path from the cloned source
# homebrewPath = "${homebrewSource}";
{
  packages = [
    git
    zsh
    fzf
    fd
    bat
    delta
    zoxide
    neovim
    btop
    zsh-powerlevel10k
    zsh-syntax-highlighting
    zsh-autosuggestions
    lsd
    jq
    jqp
    lazygit
    ripgrep
    (nerdfonts.override {
      fonts = [
        "JetBrainsMono"
        "VictorMono"
      ];
    })

    # basic dev env now
    podman
    nodejs
    deno
    ruby
    pnpm
    luarocks
    fd

    # Setup Homebrew in /opt/homebrew
    # (pkgs.runCommand "install-homebrew"
    #   {
    #     buildInputs = [ pkgs.stdenv ];
    #   }
    #   ''
    #     # Copy Homebrew files to /opt/homebrew
    #     cp -r ${homebrewSource}/* /opt/homebrew
    #
    #     # Ensure binaries are in PATH
    #     export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
    #
    #     # Run Homebrew initial setup (if needed)
    #     /opt/homebrew/bin/brew update --force
    #   ''
    # )

    # Install WezTerm via Homebrew (with environment variables already set globally)
    # (pkgs.runCommand "install-wezterm" { } ''
    #   export PATH=${homebrewPath}:$PATH
    #   export HOMEBREW_NO_AUTO_UPDATE=1
    #   export HOMEBREW_NO_INSTALL_CLEANUP=1
    #   ${homebrewRepo}/bin/brew install wezterm
    # '')
  ];
}
