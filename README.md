# installing MacPorts

- install xcode command line tools

  ```bash
    xcode-select --install
  ```

- visit the [release](https://github.com/macports/macports-base/releases/) page.
- download the pkg for your macOS version
  - for Sequoia (macOS 15) [here](https://github.com/macports/macports-base/releases/download/v2.10.5/MacPorts-2.10.5-15-Sequoia.pkg)
- follow the GUI installer instructions.

## install macports and homebrew packages

```bash
~/.config/install-pkgs.bash
```

```bash
echo (which fish) | sudo tee -a /etc/shells
chsh -s (which fish)
```

<!-- # installing nix -->
<!---->
<!-- ```bash -->
<!-- curl \ -->
<!--   --proto '=https' \ -->
<!--   --tlsv1.2 \ -->
<!--   -sSf \ -->
<!--   -L https://install.determinate.systems/nix \ -->
<!--   | sh -s -- install --determinate -->
<!---->
<!-- ``` -->
<!---->
<!-- ## installing nix-darwin -->
<!---->
<!-- ```bash -->
<!-- sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin -->
<!-- sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin -->
<!-- sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin -->
<!---->
<!-- nix --extra-experimental-features nix-command \ -->
<!--   --extra-experimental-features flakes \ -->
<!--   run nix-darwin -- switch --flake ~/.config/nix -->
<!-- ``` -->
<!---->
<!-- ## #NOTE -->
<!---->
<!-- on reboot the nix-store might lose its password, since its encrypted -->
<!-- go to the keychain and look for disk3 and recover the password from there. -->
<!-- And when saving it check the box to store in the keychain -->
