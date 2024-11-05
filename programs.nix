{ config
, pkgs
, ... }:
{
  environment.systemPackages = with pkgs; [
    inetutils
    tcpdump
    dhcpdump
    nethogs
    netcat
    iftop
    traceroute
    vim
    lynx
    zip unzip p7zip
    tshark wireshark-cli
    speedtest-cli
    bmon
    nethogs
    nload vnstat ifstat-legacy
    iotop
    at
    btop htop gtop
    cifs-utils
    pciutils
    file
    wget
    ncdu
    psmisc
    lsof
    openssl
    nmap
    bc ghc
    whois
    python3
    dig bind
  ];
}
