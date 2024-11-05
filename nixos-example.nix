{ config
, pkgs
, ... }:
{
  networking.usePredictableInterfaceNames = false;
  environment.systemPackages = with pkgs; [
    inetutils
    tcpdump
    dhcpdump
    nethogs
    netcat
    iftop
    traceroute
    vim
  ];
  environment.shellAliases = {
    "x" = "exit";
    "c" = "clear";
    ".." = "cd ../";
    "..." = "cd ../../";
    "grep" = "grep --color -i";
    "ack" = "ack -Q";
    "ncat" = "nc";
  };

  networking.firewall.enable = false;

  users.motd = "GNS3-NixOS-Server";
  services.getty.autologinUser = "root";
  security.sudo.wheelNeedsPassword = false;
  networking.hostName = "server"; #default and should get overridden by systemd
  users.extraUsers.cisco = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "cisco";
  };

  #systemd service to set the hostname dynamically
  systemd.services.set-dynamic-hostname = {
    description = "Set hostname dynamically from QEMU fw_cfg";
    after = [ "sysinit.target" ];
    before = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'if [ -f /sys/firmware/qemu_fw_cfg/by_name/opt/vm_hostname/raw ]; then hostname=$(cat /sys/firmware/qemu_fw_cfg/by_name/opt/vm_hostname/raw); echo \"$hostname\" > /proc/sys/kernel/hostname; fi'";
    };
  };
}
