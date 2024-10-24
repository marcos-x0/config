{
  pkgs,
  lib,
  config,
  ...
}:
let

  basePackages =
    import
      (builtins.path {
        path = ./base-packages.nix;
      })
      {
        pkgs = pkgs;
        lib = lib;
        config = config;
      };
  # homebrewPath = basePackages.homebrewPath;
  # #existingPath = pkgs.lib.getEnv "PATH";
  # existingPath = builtins.getEnv "PATH";
  # homebrewWritableDir = "${config.home.homeDirectory}/.local/share/homebrew";

in

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "mgj";
  home.homeDirectory = "/Users/mgj";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  # home.packages = import "./base-packages.nix" { pkgs = pkgs; };

  home.packages = basePackages.packages;

  # Set Homebrew-specific environment variables globally
  # home.sessionVariables = {
  #   PATH = "${existingPath}:${homebrewPath}/bin:${homebrewPath}/sbin";
  #   HOMEBREW_NO_AUTO_UPDATE = "1";
  #   HOMEBREW_NO_INSTALL_CLEANUP = "1";
  #   HOMEBREW_PREFIX = "${homebrewWritableDir}";
  #   HOMEBREW_CACHE = "${homebrewWritableDir}/Cache";
  #   HOMEBREW_CELLAR = "${homebrewWritableDir}/Cellar";
  #   HOMEBREW_LOCKS = "${homebrewWritableDir}/Locks";
  #   HOMEBREW_LOGS = "${homebrewWritableDir}/Logs";
  #   HOMEBREW_VAR = "${homebrewWritableDir}/Var";
  #   HOMEBREW_TEMP = "${homebrewWritableDir}/Temp";
  # };
  #
  # # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-v.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/mgj/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Add the flake registry command to the zshrc file to ensure it runs in each new shell
  # programs.zsh.initExtra = ''
  #   # Ensure that the nix-darwin flake is added to the registry
  #   if ! nix registry list | grep -q "^mgj-nix-darwin "; then
  #     echo "Registering mgj-nix-darwin flake in the local registry..."
  #     nix registry add mgj-nix-darwin /Users/mgj/.config/nix || echo "Failed to register nix-darwin flake."
  #   else
  #     echo "mgj-nix-darwin flake is already registered."
  #   fi
  # '';
  #
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    #enableLsColors = true;
    #initExtra = ''
    #  source 
    #'';
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/";
        file = "zsh-autosuggestions.zsh";
      }
      {
        #TODO: replace with fast-syntax-highlighting
        name = "zsh-syntax-highlighting";
        src = "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/";
        file = "zsh-syntax-highlighting.zsh";
      }
      {
        name = "zsh-powerlevel10k";
        src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/";
        file = "powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = ../zsh;
        file = "p10k.zsh";
      }
      # {
      #   name = "zsh-vim-mode";
      #   src = ../zsh;
      #   file = "zsh-vim-mode.plugin.zsh";
      # }
    ];
  };

  programs.lsd = {
    settings = builtins.readFile ../lsd/config.yaml;
  };

  # programs.neovim = {
  #   enable = true;
  #   extraLuaPackages = ps: [ ps.magick ];
  #   extraPackages = ps: [ ps.imagemagick ];
  #   # ... other config
  # };

  fonts.fontconfig.enable = true;

  # Symlink the external .zshenv file
  #home.file.".zshenv".source = "${config.home.homeDirectory}/.dotfiles/.zshenv";

  # Symlink the external .zshenv file using builtins.path, relative to the flake directory
  home.file.".zshenv".text = builtins.readFile ../zsh/zshenv;
  home.file.".zshrc".text = builtins.readFile ../zsh/zshrc;
  home.file.".zprofile".text = builtins.readFile ../zsh/zprofile;

  # '';
  home.activation =
    {
    };
  # home.activation.aerospaceApp = lib.mkAfter ''
  #   mkdir -p ~/Applications
  #   cp -r ${pkgs.aerospace}/AeroSpace.app ~/Applications/AeroSpace.app
  # '';

}
