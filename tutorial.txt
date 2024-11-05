Create a nix file to your liking, include the base.nix from this repo as it is what enables the hostname generation.

Use nixos-generator to generate the qcow2 file:

nixos-generate -f qcow -c ./your-config.nix

Copy the generated qcow2 ( nixos.qcow2 ) from the nixos store to any R/W directory and rename the image respectively, ie nixos-24-11.qcow2, or pc.qcow2, server.qcow2, etc.

Use the GNS3 appliance for NixOS: https://gns3.com/marketplace/appliances/nixos

or create your own as any other qemu appliance but pass the vm name in advanced options:

-fw_cfg name=opt/vm_hostname,string=%vm-name%

