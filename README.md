Generate QEMU qcow2 VMs using NixOS configuartion.nix for GNS3
Auto populate hostname into NixOS VM based on the GNS3 instance

Requires nixos-generators ( https://github.com/nix-community/nixos-generators )

Settings for VM are in server.nix for example

Create qcow2 VM with:
nixos-generate -f qcow -c ./server.nix

Import into GNS3 via Qemu -> New

VM name is passed into QEMU guest with Advanced Options field entry:
-fw_cfg name=opt/vm_hostname,string=%vm-name%


{ config
, lib
, pkgs
, modulesPath
, ... }:
{
  networking.usePredictableInterfaceNames = false;
  imports = [
  ];
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
  networking.firewall.allowedTCPPorts = [ 23 ];
  environment.shellAliases = {
    "x" = "exit";
    "c" = "clear";
    ".." = "cd ../";
    "..." = "cd ../../";
    "grep" = "grep --color -i";
    "ack" = "ack -Q";
  };

  users.motd = "GNS3-NixOS-Server";
  services.getty.autologinUser = "root";
  security.sudo.wheelNeedsPassword = false;
  networking.hostName = "server"; #default and should be overridden by systemd
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



