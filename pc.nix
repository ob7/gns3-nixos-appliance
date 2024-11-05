{ config
, pkgs
, ... }:
{
  users.motd = "GNS3-NixOS-PC";

  networking.usePredictableInterfaceNames = false;
  environment.systemPackages = with pkgs; [
    inetutils
    tcpdump
    dhcpdump
    nethogs
    netcat
    nmap
    iftop
    traceroute
    vim
    dig
    whois
  ];

  imports = [
    ./base.nix
  ];

  networking.firewall.enable = false;
}
