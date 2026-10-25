{ pkgs-unstable, ... }:
{
  environment.systemPackages = with pkgs-unstable; [
    vim
    git
    uv
  ];

  programs.nix-ld.enable = true; # allow
}
