#!/usr/bin/env bash

# compile server.nix into nixos.qcow2
nixos-generate -f qcow -c ./server.nix

# compile pc.nix into nixos.qcow2
nixos-generate -f qcow -c ./pc.nix
