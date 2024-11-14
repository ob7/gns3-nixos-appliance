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

  networking.firewall.enable = false;

  services.nginx = {
    enable = true;
    virtualHosts."web.this.lab" = {
      listen = [ { addr = "0.0.0.0"; port = 80; } ];
      locations."/" = {
        extraConfig = ''
          default_type text/html;
          return 200 "<html><body><h1>Hello, NixOS!</h1><p>This page is served directly by Nginx without files.</p></body></html>";
        '';
      };
    };
  };
 
}
