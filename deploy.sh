#!/bin/bash

# This script deploys the Enginerd Lab Server with all necessary components to run the Enginerd labs.

set -e
G="\e[32m"
Y="\e[33m"
R="\e[31m"
E="\e[0m"

FILE=.vars
if test -f "$FILE"; then
    echo -e ${G}"$FILE exists. Clear to proceed..."${E}
else
    echo -e ${R}"Whoops! $FILE does not exist. Please create the $FILE from $FILE.dist before proceeding. Details in the README.md"${E}
    exit 1
fi

source .vars

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

## Install Docker on Ubuntu
if [[ "$DISTRO" == *"Ubuntu"* ]]; then
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

## Install Docker on Debian
if [[ "$DISTRO" == *"debian"* ]]; then
    echo -e ${G}"Installing Docker on Debian..."${E}
    sudo mkdir -p /etc/apt/keyrings  > /dev/null 2>&1
    sudo rm -f -- /etc/apt/keyrings/docker.gpg  > /dev/null 2>&1
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
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

## Install VSCode Server
if [[ "$DISTRO" == *"Ubuntu"* ]] || [[ "$DISTRO" == *"debian"* ]]; then
    echo -e ${G}"Installing VSCode-Server..."${E}
    sudo mkdir -p /enginerding-labs
    sudo mkdir -p /$USER/misc/code-server/User
    curl -fsSL -o /tmp/code-server_${VSCODE_VERSION}_amd64.deb https://github.com/coder/code-server/releases/download/v${VSCODE_VERSION}/code-server_${VSCODE_VERSION}_amd64.deb
    sudo dpkg -i /tmp/code-server_${VSCODE_VERSION}_amd64.deb
    systemctl stop code-server@$USER
    rm /lib/systemd/system/code-server@.service
    cat >> /lib/systemd/system/code-server@.service<< EOF
    [Unit]
    Description=code-server
    After=network.target

    [Service]
    User=$USER
    Group=$USER
    Type=exec
    Environment=PASSWORD=$VSCODE_PASSWORD
    ExecStart=/usr/bin/code-server --bind-addr 0.0.0.0:8080 --user-data-dir /$USER/misc/code-server --auth password /enginerding-labs
    Restart=always

    [Install]
    WantedBy=default.target
EOF
    cp assets/settings.json /$USER/misc/code-server/User/settings.json
    sudo systemctl enable --now code-server@$USER
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
if [[ "$DISTRO" == *"centos"* ]] || [[ "$DISTRO" == *"rocky"* ]]; then
  echo -e ${G}"Installing EPEL, yum-utils, dnf-plugins-core..."${E}
  sudo dnf install epel-release yum-utils dnf-plugins-core -y
else
  :
fi

# Installing RPM Fusion, yum-utils, dnf-plugins-core on Fedora
if [[ "$DISTRO" == *"fedora"* ]]; then
  echo -e ${G}"Installing EPEL, yum-utils, dnf-plugins-core..."${E}
  sudo dnf upgrade --refresh -y
  sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm -y
  sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
  sudo dnf install yum-utils dnf-plugins-core -y
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
if [[ "$DISTRO" == *"centos"* ]] || [[ "$DISTRO" == *"rocky"* ]]; then
    echo -e ${G}"Installing Docker..."${E}
    sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo dnf install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER
else
  :
fi

# Install Docker on Fedora
if [[ "$DISTRO" == *"fedora"* ]]; then
    echo -e ${G}"Installing Docker on Fedora..."${E}
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER
else
  :
fi

# Install Terraform
if [[ "$DISTRO" == *"centos"* ]] || [[ "$DISTRO" == *"rocky"* ]]; then
    echo -e ${G}"Installing Terraform..."${E}
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
    sudo yum -y install terraform -y
else
  :
fi

# Install Terraform on Fedora
if [[ "$DISTRO" == *"fedora"* ]]; then
    echo -e ${G}"Installing Terraform on Fedora..."${E}
    sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
    sudo dnf install terraform -y
else
  :
fi

## Install VSCode Server
if [[ "$DISTRO" == *"fedora"* ]] || [[ "$DISTRO" == *"centos"* ]] || [[ "$DISTRO" == *"rocky"* ]]; then
    echo -e ${G}"Installing VSCode-Server..."${E}
    sudo mkdir -p /enginerding-labs
    sudo mkdir -p /$USER/misc/code-server/User
    curl -fsSL -o /tmp/code-server_${VSCODE_VERSION}_amd64.rpm https://github.com/coder/code-server/releases/download/v${VSCODE_VERSION}/code-server-${VSCODE_VERSION}-amd64.rpm
    sudo rpm -iv --replacepkgs /tmp/code-server_${VSCODE_VERSION}_amd64.rpm
    systemctl stop code-server@$USER
    rm /lib/systemd/system/code-server@.service
    cat >> /lib/systemd/system/code-server@.service<< EOF
    [Unit]
    Description=code-server
    After=network.target

    [Service]
    User=$USER
    Group=$USER
    Type=exec
    Environment=PASSWORD=$VSCODE_PASSWORD
    ExecStart=/usr/bin/code-server --bind-addr 0.0.0.0:8080 --user-data-dir /$USER/misc/code-server --auth password /enginerding-labs
    Restart=always

    [Install]
    WantedBy=default.target
EOF
    cp assets/settings.json /$USER/misc/code-server/User/settings.json
    sudo systemctl enable --now code-server@$USER
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

## Install K3d
echo -e ${G}"Installing k3d..."${E}
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

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
cp assets/.aliases ~/.aliases  > /dev/null 2>&1
cp assets/.zshrc ~/.zshrc  > /dev/null 2>&1

## Install complete
touch ./server-details.txt
echo -e ${G}"Install complete...."${E}
echo -e ${G}-----Code Server Details-----${E}
echo -e ${G}Code Server UI:${E}http://THI-SERVER-IP:8080 | tee -a ./server-details.txt
echo -e ${G}Code Server Login${E}$VSCODE_PASSWORD | tee -a ./server-details.txt
echo -e ${G}"------------------------------------------"${E}
echo -e ${Y}"Details above are saved to the file at enginerding-lab-server/server-details.txt"${E}
echo -e ${Y}"IT IS HIGHLY RECOMMENDED YOU REBOOT THIS SYSTEM BEFORE USE."${E}
echo -e ${G}"------------------------------------------"${E}
echo -e ${G}"Install complete. Have a great day!!"${E}
