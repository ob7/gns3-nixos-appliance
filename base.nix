{ config
, pkgs
, ... }:
{
  networking.usePredictableInterfaceNames = false;
  environment.systemPackages = with pkgs; [
  ];
  imports = [
    ./imports/vm-nogui.nix  #for resizing console based on actual size, triggers at login
  ];
  boot.readOnlyNixStore = false; #make nix store writable so we can override things like hostname at boot
  environment.shellAliases = {
    "x" = "exit";
    "c" = "clear";
    ".." = "cd ../";
    "..." = "cd ../../";
    "grep" = "grep --color -i";
    "ack" = "ack -Q";
    "ncat" = "nc";
  };

  services.getty.autologinUser = "root";
  security.sudo.wheelNeedsPassword = false;
  #networking.hostName = "server"; #default and should get overridden by systemd
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
      ExecStart = pkgs.writeScript "set-hostname" ''
      #!${pkgs.bash}/bin/bash
      if [ -f /sys/firmware/qemu_fw_cfg/by_name/opt/vm_hostname/raw ]; then
        hostname=$(cat /sys/firmware/qemu_fw_cfg/by_name/opt/vm_hostname/raw)
        ## Set kernel hostname
        echo "$hostname" > /proc/sys/kernel/hostname
        echo "$hostname" > /etc/hostname
      fi
    '';
    };
  };
}
