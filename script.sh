#!/usr/bin/env bash
set -e

# Goal: Script which automatically sets up a new Pop Os Machine after installation

# Test to see if user is running with root privileges.
if [[ "${UID}" -ne 0 ]]
then
 echo 'Deve ser executado com sudo ou como usuário root' >&2
 exit 1
fi

# Ensure system is up to date
echo '
==============================================================
 *** Atualizando lista de pacotes... ***
==============================================================
 '
sudo apt-get update -y --fix-missing

# Upgrade the system
echo '
==============================================================
 *** Instalando novas versões dos pacotes existentes... ***
==============================================================
 '
sudo apt-get upgrade -y

# Install packages
echo '
==============================================================
 *** Instalando novos pacotes... ***
==============================================================
 '
sudo apt install -fy openssh-server unattended-upgrades fail2ban software-properties-common apt-transport-https vim curl git git-lfs zsh konsole tmux neofetch traceroute speedtest-cli code cairo-dock cairo-dock-plug-ins vlc gparted gnome-tweak-tool nautilus-admin fonts-firacode ttf-mscorefonts-installer ffmpeg obs-studio libavcodec-extra libdvd-pkg

# Enable Firewall
echo '
==============================================================
 *** Habilitando porta 22... ***
==============================================================
 '
sudo ufw allow 22
echo '
==============================================================
 *** Habilitando firewall... ***
==============================================================
 '
sudo ufw --force enable

# Configure the firewall
echo '
==============================================================
 *** Habilitando OpenSSH... ***
==============================================================
 '
sudo ufw allow OpenSSH

# Disabling root login
echo '
==============================================================
 *** Desabilitando root login... ***
==============================================================
 '
sudo echo "PermitRootLogin no" >> sudo /etc/ssh/sshd_config
sudo echo "PermitEmptyPasswords no" sudo /etc/ssh/sshd_config

# Automatic downloads of security updates (package: unattended-upgrades)
echo '
==============================================================
 *** Configurando atualizações automáticas de segurança... ***
==============================================================
 '
sudo apt-get install -y unattended-upgrades
echo "Unattended-Upgrade::Allowed-Origins {
#   "${distro_id}:${distro_codename}-security";
#//  "${distro_id}:${distro_codename}-updates";
#//  "${distro_id}:${distro_codename}-proposed";
#//  "${distro_id}:${distro_codename}-backports";

#Unattended-Upgrade::Automatic-Reboot "true"; 
#}; " >> sudo /etc/apt/apt.conf.d/50unattended-upgrades

# Fail2Ban install (package: fail2ban) 
echo '
==============================================================
 *** Configurando fail2Ban... ***
==============================================================
 '
sudo apt-get install -y fail2ban
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

sudo echo "
[sshd]
enabled = true
port = 22
filter = sshd
logpath = /var/log/auth.log
maxretry = 4
" >> sudo /etc/fail2ban/jail.local

# Git install
echo '
==============================================================
 *** Instalando git-lfs... ***
==============================================================
 '
sudo git-lfs install

# ZSH install
echo '
==============================================================
 *** Instalando zsh... ***
==============================================================
 '
# chsh -s $(which zsh)
grep zsh /etc/shells

# Oh-My-Zsh install
echo '
==============================================================
 *** Instalando e configurando oh-my-zsh... ***
==============================================================
 '
echo 'y' | sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
zsh

# Spaceship theme install
sudo git clone https://github.com/denysdovhan/spaceship-prompt.git "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt" --depth=1
sudo ln -s "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt/spaceship.zsh-theme" "$HOME/.oh-my-zsh/custom/themes/spaceship.zsh-theme"
 
# Fast-syntax-highlight
git clone https://github.com/zdharma/fast-syntax-highlighting.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
 
# Auto-suggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-better-npm-completion
git clone https://github.com/lukechilds/zsh-better-npm-completion ~/.oh-my-zsh/custom/plugins/zsh-better-npm-completion

# Zsh-completions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
  
# Create .zshrc
sudo rm $HOME/.zshrc
curl https://gist.githubusercontent.com/CrisMorgantee/23d22693037449cb4d9c0baff6b02b9f/raw/fd0c5ddc0ffdb0f4d76507c8dda6be012f09a8c7/.zshrc > $HOME/.zshrc
source ~/.zshrc

# Vim configs
echo '
==============================================================
 *** Configurando vim... ***
==============================================================
 '
# Create .vimrc
echo '
==============================================================
 *** Criando pasta ~/.vim/plugin/ ***
============================================================== 
 '
mkdir -p ~/.vim/plugin/

echo '
==============================================================
 *** Criando pasta ~/.vim/autoload/ ***
============================================================== 
 '
mkdir -p ~/.vim/autoload/

echo '
==============================================================
 *** Criando arquivo ~/.vimrc ***
============================================================== 
 '
curl https://gist.githubusercontent.com/CrisMorgantee/1feac714c7dde1ca85f23940e3f8adf2/raw/ce1cf910398d7fdecd9a7ed3e1a8ff21d0e98b48/.vimrc > $HOME/.vimrc

# Dracula
echo '
==============================================================
 *** Instalando tema Dracula para o vim... ***
============================================================== 
 '
mkdir -p ~/.vim/pack/themes/opt
cd ~/.vim/pack/themes/opt
git clone https://github.com/dracula/vim.git dracula

# Emmet
echo '
==============================================================
 *** Instalando o plugin Emmet... ***
============================================================== 
 '
git clone https://github.com/mattn/emmet-vim.git
cd emmet-vim/
cp plugin/emmet.vim ~/.vim/plugin/
cp autoload/emmet.vim ~/.vim/autoload/
cp -a autoload/emmet ~/.vim/autoload/

# Auto Pairs
echo '
==============================================================
 *** Instalando o plugin Auto Pairs... ***
============================================================== 
 '
git clone https://github.com/jiangmiao/auto-pairs.git
cd auto-pairs/
cp plugin/auto-pairs.vim ~/.vim/plugin/

# Close Tag
echo '
==============================================================
 *** Instalando o plugin Close Tag... ***
============================================================== 
 '
git clone https://github.com/alvan/vim-closetag.git
cd vim-closetag
cp plugin/closetag.vim ~/.vim/plugin/

#NERDTree
echo '
==============================================================
 *** Instalando o plugin NERDTree... ***
============================================================== 
 '
git clone https://github.com/preservim/nerdtree.git ~/.vim/pack/vendor/start/nerdtree
#vim -u NONE -c "helptags ~/.vim/pack/vendor/start/nerdtree/doc" -c q

# NVM/Node install 
echo '
==============================================================
 *** Instalando nvm e versão estável do node... ***
============================================================== 
 '
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
nvm install --lts

# Yarn install
echo '
==============================================================
 *** Instalando versão estável do yarn... ***
============================================================== 
 '
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install --no-install-recommends yarn


# Java via Openjdk
# sudo apt install -y default-jre default-jdk
# java -version

# SFTP Server / FTP server that runs over ssh
echo '
==============================================================
 *** Configurando SFTP/FTP Server... ***
============================================================== 
 '
echo "
Match group sftp
ChrootDirectory /home
X11Forwarding no
AllowTcpForwarding no
ForceCommand internal-sftp
" >> sudo /etc/ssh/sshd_config

sudo service ssh restart  

# Docker option install 
echo "
######################################################################################################

Do you want to install docker? If so type y / If you dont want to install enter n

######################################################################################################
"
read $docker

if [[ $docker -eq "y" ]] || [[ $docker -eq "yes" ]]; then
    sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
    sudo apt-get update -y
    apt-cache policy docker-ce
    sudo apt install docker-ce -y
    sudo apt-get install docker-compose -y 

    echo " 
    
        Installing Portainer on port 9000

    "

    sudo docker volume create portainer_data
    sudo docker run -d -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer

    echo "
#####################################################################################################    
                            Congrats Docker has been installed
######################################################################################################
"
    docker -v

else 
    echo "Docker was not installed"
 
fi

# Wireguard install
echo "
######################################################################################################

Would you like to install a wireguard VPN Server? If so enter y / If you dont want to install enter n

######################################################################################################
"
read $vpn

if [[ $vpn -eq "y" ]] || [ $vpn -eq "yes" ]] ; then 
    wget https://raw.githubusercontent.com/l-n-s/wireguard-install/master/wireguard-install.sh -O wireguard-install.sh
    bash wireguard-install.sh

elif  [[ $vpn -eq "n" ]] || [ $vpn -eq "no" ]] ; then 
    echo "Wireguard wasnt installed"
else 
    echo "Error Install Aborted!"
    exit 1
fi

# Cleanup
sudo apt autoremove
sudo apt clean 

exit 0

