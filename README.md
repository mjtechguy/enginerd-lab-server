# Enginerding Lab Server

Welcome **Enginerds**!

This script installs some basic tools on Ubuntu/Debian or RHEL based systems to make the machine more useful for trainings I post on [YouTube](https://www.youtube.com/channel/UCngu1SJ-pyiNEHMINKlW8Uw) and Udemy and DevSecOps work in general.

---

## Requirements
- RHEL Based or Debian/Ubuntu Server
- 4vCPU / 8GB RAM (Recommended)
- User with passwordless sudo
- Git installed

---

## Tested On
- Ubuntu 20/22 (Recommended)
- Rocky 9 (Recommended)
- Fedora 36
- CentOS Stream 9
- Debian 11

---

## Recommended Cloud Providers (Referral Links):

If you use these links to sign up for one of these services, I get a small kickback and you will get some free credits. No additional cost to you and it helps me out tremendously. It's a win-win!

- Hetzner (my favorite for price): https://hetzner.cloud/?ref=JRGtolHM4Qdb
- DigitalOcean: https://m.do.co/c/4904904f3ee0

---

## Installed Components
- OS Updates
- Base Packages
- Docker
- Terraform
- Ansible
- Kubectl
- ZSH and Oh-My-ZSH
- Some dotfiles with aliases and ZSH configs
- Some other packages and misc things to make this work

---

## How To Install

- Login to server (duh)
- Run `git clone https://github.com/mjtechguy/enginerding-lab-server.git`
- Change into the cloned dir `cd enginerding-lab-server`
- Copy `.vars.dist` to `.vars` and update the `VSCODE_PASSWORD`
- Run the installer `./deploy.sh`

---

## About MJ

My name is Mike Johnson. You can call me MJ. I have been working in technology for over 22 year and have a vast amount of experience in many areas of technology, mostly from the Infrastructure and Operations side.

I have some container certs, a few cloud certs, and spend most of my time these days building robust cloud, container and cybersecurity automation tooling.

Feel free to connect with me and I look forward to hearing from you.

- **Github:** https://github.com/mjtechguy
- **Youtube:** https://www.youtube.com/channel/UCngu1SJ-pyiNEHMINKlW8Uw
- **LinkedIn:** https://www.linkedin.com/in/mjtechguy/
- **Website:** https://mjtechguy.com

