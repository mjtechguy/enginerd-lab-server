# Enginerding Lab Server

This script installs some basic tools on Ubuntu/Debian or RHEL based systems to make the machine more useful for DevOps work.

## Requirements
- RHEL Based or Debian/Ubuntu Server
- 4vCPU / 8GB RAM (Recommended)
- User with passwordless sudo
- Git installed

## Tested On
- Ubuntu 20/22
- Fedora 36
- Rocky 9
- CentOS Stream 9
- Debian 11

## Installed Components
- OS Updates
- Base Packages (ca-certificates curl gnupg lsb-release unzip haveged zsh jq)
- Docker
- Terraform
- Ansible
- Kubectl
- yq
- ZSH and Oh-My-ZSH
- Much More
- Some dotfiles with aliases and ZSH configs

## How To Install

- Login to server (duh)
- Run `git clone https://github.com/mjtechguy/enginerding-lab-server.git`
- Change into the cloned dir `cd enginerding-lab-server`
- Run the installer `./deploy.sh`

## Connect with MJ

- Github: https://github.com/mjtechguy
- LinkedIn: https://www.linkedin.com/in/mjtechguy/
- YouTube: https://www.youtube.com/channel/UCngu1SJ-pyiNEHMINKlW8Uw
- Twitter (rarely used): https://twitter.com/mjtechguy

