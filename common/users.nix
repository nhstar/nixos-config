{ pkgs, ... }:

{
  users.users.star = {
    isNormalUser = true;
    description = "Star";
    createHome = true;
    home = "/home/star";
    shell = pkgs.zsh;
    
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "libvirtd" "docker"];
  };
}
