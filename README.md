# installing nix

- [installing nix](#installing-nix)
  - [installing nix-darwin](#installing-nix-darwin)
  - [NOTE](#note)

```bash
curl \
  --proto '=https' \
  --tlsv1.2 \
  -sSf \
  -L https://install.determinate.systems/nix \
  | sh -s -- install

```

## installing nix-darwin

```bash
nix run nix-darwin -- switch --flake ~/.config/nix
```

## #NOTE

on reboot the nix-store might lose its password, since its encrypted
go to the keychain and look for disk3 and recover the password from there.
And when saving it check the box to store in the keychain
