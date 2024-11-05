{ config
, pkgs
, ... }:
{
  users.motd = "GNS3-NixOS-DNS-Server";

  imports = [
    ./base.nix
    ./programs.nix
  ];

  # Enable BIND DNS server
  services.bind = {
    enable = true;
    
    # Listen on all interfaces
    listenOn = [ "any" ];
    
    # Allow queries from anywhere, like a real DNS server
    extraOptions = ''
      recursion yes;
    '';
    
    zones = {
      "lab.local" = {
        master = true;
        file = pkgs.writeText "lab.local" ''
          $TTL 86400
          @       IN      SOA     ns1.lab.local. admin.lab.local. (
                                  2024110201      ; Serial
                                  3600            ; Refresh
                                  1800            ; Retry
                                  604800          ; Expire
                                  86400 )         ; Minimum TTL

                  IN      NS      ns1.lab.local.
          ns1     IN      A       192.168.1.53

          ; Add your lab devices below
          router1 IN      A       192.168.1.1
          switch1 IN      A       192.168.1.2
          host1   IN      A       192.168.1.10
          host2   IN      A       192.168.1.11
        '';
      };
      
      # Reverse lookup zone for 192.168.1.0/24 network
      "1.168.192.in-addr.arpa" = {
        master = true;
        file = pkgs.writeText "1.168.192.rev" ''
          $TTL 86400
          @       IN      SOA     ns1.lab.local. admin.lab.local. (
                                  2024110201      ; Serial
                                  3600            ; Refresh
                                  1800            ; Retry
                                  604800          ; Expire
                                  86400 )         ; Minimum TTL

                  IN      NS      ns1.lab.local.

          ; Reverse records
          53      IN      PTR     ns1.lab.local.
          1       IN      PTR     router1.lab.local.
          2       IN      PTR     switch1.lab.local.
          10      IN      PTR     host1.lab.local.
          11      IN      PTR     host2.lab.local.
        '';
      };
    };
  };

  # Configure networking
  networking = {
    # Set a static IP - adjust according to your network
    interfaces.eth0.ipv4.addresses = [{
      address = "192.168.1.53";
      prefixLength = 24;
    }];
    # Add default gateway - adjust this to your lab's router IP
    defaultGateway = "192.168.1.1";
    
    # Optional: Set DNS server as its own resolver
    nameservers = [ "127.0.0.1" ];
  };

  # Open DNS ports in firewall
  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };

}
