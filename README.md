# GNS3 NixOS QEMU VM Generator

This setup enables the generation of NixOS VMs in qcow2 format for GNS3, using [nixos-generators](https://github.com/nix-community/nixos-generators). It includes automatic hostname configuration for each VM based on the GNS3 instance name. 

## Requirements
- [nixos-generators](https://github.com/nix-community/nixos-generators)

## Steps to Create and Import the VM

1. **Generate qcow2 VM image**

   Use the following command to generate the qcow2 VM image based on your configuration file, `server.nix` (or any other NixOS configuration file you may create):
   
   ```bash
   nixos-generate -f qcow -c ./server.nix
   
2. **Import into GNS3**

   - Go to **GNS3** -> **QEMU** -> **New**.
   - Select the qcow2 image generated in step 1.
   - In **Advanced Options**, pass the VM name to QEMU by setting:
   
     ```text
     -fw_cfg name=opt/vm_hostname,string=%vm-name%
     ```

## Sample `server.nix` Configuration

Below is an example configuration file, `server.nix`, for creating the VM. It includes settings for network tools, shell aliases, and a systemd service to set the hostname dynamically from the GNS3 instance name.  

<sub>*(Reference server.nix, pc.nix, etc directly in this repo for most up to date code examples)*</sub>

```nix
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

```
##
This appliance is also available on the GNS3 marketplace:
https://www.gns3.com/marketplace/appliances/nixos

original gns3-registry pull request:
https://github.com/GNS3/gns3-registry/pull/931
