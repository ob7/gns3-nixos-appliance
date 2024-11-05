{ config
, pkgs
, ... }:
{
  users.motd = "GNS3-NixOS-Server";

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

	networking = {
		domain = "lab.local";
		search = [ "lab.local" ];
  };

  networking.firewall.enable = false;
}
