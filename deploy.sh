#!/bin/bash

# This script deploys the Enginerd Lab Server with all necessary components to run the Enginerd labs.

set -e

G="\e[32m"
E="\e[0m"

# Determine OS platform
UNAME=$(uname | tr "[:upper:]" "[:lower:]")
# If Linux, try to determine specific distribution
if [ "$UNAME" == "linux" ]; then
    # If available, use LSB to identify distribution
    if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
        export DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
    # Otherwise, use release info file
    else
        export DISTRO=$(ls -d /etc/[A-Za-z]*[_-][rv]e[lr]* | grep -v "lsb" | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1)
    fi
fi
# For everything else (or if above failed), just use generic identifier
[ "$DISTRO" == "" ] && export DISTRO=$UNAME

# Confirm OS is compatible with script
if [[ "$DISTRO" == *"Ubuntu"* ]] || [[ "$DISTRO" == *"debian"* ]]; then
  echo "This is Ubuntu or Debian. You have clearance Clarence to proceed..."
elif [[ "$DISTRO" == *"centos"* ]] || [[ "$DISTRO" == *"redhat"* ]] || [[ "$DISTRO" == *"rocky"* ]]; then
  echo "This is RHEL Based. You have clearance Clarence to proceed..."
else
  echo "Cannot be run on this systems. Needs to be Debian based (Ubuntu or Debian) or RHEL Based (RHEL, CentOS, Rocky, Fedora, Alma) to proceed. No install for you."
fi

#########################
# Deploy on Debian/Ubuntu
#########################

# Install Updates on Ubuntu/Debian
if [[ "$DISTRO" == *"Ubuntu"* ]] || [[ "$DISTRO" == *"debian"* ]]; then
  echo -e ${G}"Installing OS Updates..."${E}
  sudo apt-get update #> /dev/null 2>&1
  sudo apt upgrade -y #> /dev/null 2>&1
else
  :
fi

if [[ "$DISTRO" == *"Ubuntu"* ]] || [[ "$DISTRO" == *"debian"* ]]; then
  echo -e ${G}"Installing packages..."${E}
  sudo apt-get install ca-certificates curl gnupg lsb-release unzip haveged zsh jq nano git -y
else
  :
fi

## Install Docker
if [[ "$DISTRO" == *"Ubuntu"* ]] || [[ "$DISTRO" == *"debian"* ]]; then
    echo -e ${G}"Installing Docker..."${E}
    sudo mkdir -p /etc/apt/keyrings  > /dev/null 2>&1
    sudo rm -f -- /etc/apt/keyrings/docker.gpg  > /dev/null 2>&1
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg  > /dev/null 2>&1
    echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update  > /dev/null 2>&1
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y  > /dev/null 2>&1
    sudo usermod -aG docker $USER  > /dev/null 2>&1
else
  :
fi

## Install Terraform
if [[ "$DISTRO" == *"Ubuntu"* ]] || [[ "$DISTRO" == *"debian"* ]]; then
    echo -e ${G}"Installing Terraform..."${E}
    sudo apt-get update  > /dev/null 2>&1
    sudo apt-get install -y gnupg software-properties-common curl  > /dev/null 2>&1
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -  > /dev/null 2>&1
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"  > /dev/null 2>&1
    sudo apt-get update > /dev/null 2>&1
    sudo apt-get install terraform  > /dev/null 2>&1
else
  :
fi

######################
# Deploy on RHEL Based
######################

# Install Updates on RHEL Based
if [[ "$DISTRO" == *"centos"* ]] || [[ "$DISTRO" == *"redhat"* ]] || [[ "$DISTRO" == *"rocky"* ]]; then
  echo -e ${G}"Installing OS Updates..."${E}
  sudo dnf upgrade --refresh -y
else
  :
fi

# Installing EPEL, yum-utils, dnf-plugins-core
if [[ "$DISTRO" == *"centos"* ]] || [[ "$DISTRO" == *"redhat"* ]] || [[ "$DISTRO" == *"rocky"* ]]; then
  echo -e ${G}"Installing EPEL, yum-utils, dnf-plugins-core..."${E}
  sudo dnf install epel-release yum-utils dnf-plugins-core -y
else
  :
fi

# Install prereq packages
if [[ "$DISTRO" == *"centos"* ]] || [[ "$DISTRO" == *"redhat"* ]] || [[ "$DISTRO" == *"rocky"* ]]; then
  echo -e ${G}"Installing prereq packages..."${E}
  sudo dnf update
  sudo dnf install ca-certificates curl gnupg unzip haveged zsh jq nano git util-linux-user -y
  update-ca-trust enable
  update-ca-trust extract
else
  :
fi

# Install Docker
if [[ "$DISTRO" == *"centos"* ]] || [[ "$DISTRO" == *"redhat"* ]] || [[ "$DISTRO" == *"rocky"* ]]; then
    echo -e ${G}"Installing Docker..."${E}
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sed -i -e 's/baseurl=https:\/\/download\.docker\.com\/linux\/\(fedora\|rhel\)\/$releasever/baseurl\=https:\/\/download.docker.com\/linux\/centos\/$releasever/g' /etc/yum.repos.d/docker-ce.repo
    sudo dnf install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER
else
  :
fi

# Install Terraform
if [[ "$DISTRO" == *"centos"* ]] || [[ "$DISTRO" == *"redhat"* ]] || [[ "$DISTRO" == *"rocky"* ]]; then
    echo -e ${G}"Installing Terraform..."${E}
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
    sudo yum -y install terraform -y
else
  :
fi

#############################
# Install on any Linux System
#############################

## Install Ansible
echo -e ${G}"Installing Ansible..."${E}
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py  > /dev/null 2>&1
python3 get-pip.py --user  > /dev/null 2>&1
python3 -m pip install --user ansible  > /dev/null 2>&1
export PATH=$HOME/.local/bin:$PATH > /dev/null 2>&1
echo 'PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc  > /dev/null 2>&1

## Install Kubectl
echo -e ${G}"Installing Kubectl..."${E}
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"  > /dev/null 2>&1
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl  > /dev/null 2>&1

## Install yq
echo -e ${G}"Installing yq..."${E}
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 > /dev/null 2>&1
sudo chmod a+x /usr/local/bin/yq > /dev/null 2>&1

## Make ZSH Default Shell
echo -e ${G}"Making ZSH the default shell..."${E}
sudo chsh -s /bin/zsh $USER  > /dev/null 2>&1

## Install oh-my-zsh
echo -e ${G}"Installing oh-my-zsh..."${E}
DIR1=~/.oh-my-zsh
if [ -d "$DIR1" ]; then
    echo -e ${G} "$DIR1 exists. No need to install oh-my-zsh again."${E}
else 
    echo -e ${G} "$DIR1 does not exist. Installing oh-my-zsh."${E}
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended  > /dev/null 2>&1
fi

## Install ZSH things
echo -e ${G}"Installing ZSH things..."${E}
DIR2=~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
if [ -d "$DIR2" ]; then
    echo -e ${G} "$DIR2 exists. No need to install plugins again."${E}
else
    echo -e ${G} "$DIR2 does not exist. Installing plugins."${E}
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting  > /dev/null 2>&1
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions  > /dev/null 2>&1
fi

## Copy files
echo -e ${G}"Copying dotfiles..."${E}
cp .aliases ~/.aliases  > /dev/null 2>&1
cp .zshrc ~/.zshrc  > /dev/null 2>&1

## Install complete
echo -e ${G}"Install complete...."${E}
echo -e ${G}"Some possible next steps:"${E}
echo -e " - Install a new theme on Oh-My-ZSH like PowerLevel10k: https://github.com/romkatv/powerlevel10k"
echo -e " - Install additional ZSH plugins: https://github.com/unixorn/awesome-zsh-plugins"
echo -e " - Update the ~/.aliases file with your own aliases"
echo -e ${G}"Install complete. Have a great day!!"${E}
cd ~
zsh