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
    #   (pkgs.stdenv.mkDerivation {
    #     name = "custom-fonts";
    #     src = ./fonts; # Path to the directory containing your custom font(s)
    #     buildInputs = [ pkgs.fontconfig ];
    #     installPhase = ''
    #       mkdir -p $out/share/fonts
    #       cp -v $src/*.ttf $out/share/fonts/
    #       fc-cache -fv $out/share/fonts
    #
    #     '';
    #   })
  ];
  users.users.mgj.home = "/Users/mgj";
  # Add the activation script here
  system.activationScripts.fontCache = ''
    echo "Updating font cache..."
    fc-cache -fv /usr/share/fonts /nix/store
  '';

  # Auto upgrade nix package and the daemon service.
  #services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # fonts.fontconfig = {
  #   enable = true;
  #   fontDirectories = [
  #     "./fonts" # Add the path to your custom fonts directory here
  #   ];
  # }; # Create /etc/zshrc that loads the nix-darwin environment.
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
