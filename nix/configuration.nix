{
  pkgs,
  ...
}:
{

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    #skhd
    #yabai
    #sketchybar
    nixfmt-rfc-style
    # aerospace
    #   neovim
    #   btop
    #   #curl
    #   #gitAndTools.gitFull
    #   #mg
    #   #mosh
  ];
  users.users.mgj.home = "/Users/mgj";

  # Auto upgrade nix package and the daemon service.
  #services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina

  # programs.neovim = {
  #   enable = true;
  #   extraLuaPackages = ps: [ ps.magick ];
  #   extraPackages = ps: [ ps.imagemagick ];
  #   # ... other config
  # };

  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  nix.configureBuildUsers = true;
  services.nix-daemon.enable = true;
  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # sudo with touch id
  security.pam.enableSudoTouchIdAuth = true;

}
