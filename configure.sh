#!/bin/bash
#
# This software is provided under under the BSD 3-Clause License.
# See the accompanying LICENSE file for more information.
#
# Update Kali and tweak Kali configuration
#
# Author:
#  Arris Huijgen
#
# Website:
#  https://github.com/bitsadmin/linuxconfig
#

# Wait for other apt updates to finish
# To prevent apt from failing
while fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do
    tput rc
    echo -n "Waiting for other software managers to finish..."
    sleep 1s
done

# Configure apt to be silent
export DEBIAN_FRONTEND=noninteractive

# Update the full system
apt-get update
apt-get -yq upgrade

# Configure NTP
timedatectl set-timezone Europe/Amsterdam

# Configure Gnome
# Disable updates
gsettings set org.gnome.software download-updates false
# Disable automatic installation of security upgrades
apt-get -yq purge unattended-upgrades
# Disable automatic timezone & date/time
gsettings set org.gnome.desktop.datetime automatic-timezone false
timedatectl set-ntp 0
# Disable lock screen
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.desktop.lockdown disable-lock-screen true
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 0
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'

# Disable screensaver
dconf write /org/gnome/desktop/screensaver/lock-enabled false
# Configure Alt-Tab behavior
gnome-shell-extension-tool -e alternate-tab@gnome-shell-extensions.gcampax.github.com
# Add shortkey to minimize all windows (Winkey + D)
gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Super>d']"
# Dash-to-dock no autohide
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed true

# Configure Nautilus
gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'
gsettings set org.gnome.nautilus.list-view default-zoom-level 'small'

# Install latest Firefox
wget 'https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US' -O /tmp/firefox.tar.bz2
tar jxvf /tmp/firefox.tar.bz2 -C /usr/lib
cat <<EOT > /usr/share/applications/firefox.desktop
[Desktop Entry]
Name=Firefox
Comment=Browse the World Wide Web
GenericName=Web Browser
X-GNOME-FullName=Firefox Web Browser
Exec=/usr/lib/firefox/firefox %u
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=firefox
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;
StartupWMClass=Firefox
StartupNotify=true
EOT
update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/lib/firefox/firefox 100
update-alternatives --set x-www-browser /usr/lib/firefox/firefox
rm /usr/bin/firefox
ln -s /usr/lib/firefox/firefox /usr/bin/firefox
cat <<EOT > /usr/lib/firefox/defaults/pref/local-settings.js
pref("general.config.obscure_value", 0);
pref("general.config.filename", "mozilla.cfg");
EOT
cat <<EOT > /usr/lib/firefox/mozilla.cfg
pref("general.warnOnAboutConfig", false);
pref("signon.rememberSignons", false);
pref("toolkit.telemetry.reportingpolicy.firstRun", false);
pref("browser.startup.homepage", "about:blank");
EOT

# Install FoxyProxy
wget https://addons.mozilla.org/firefox/downloads/latest/foxyproxy-standard/addon-2464-latest.xpi -O /tmp/addon-2464-latest.xpi
mkdir /usr/lib/firefox/browser/extensions
unzip /tmp/addon-2464-latest.xpi -d /usr/lib/firefox/browser/extensions/foxyproxy@eric.h.jung

# Add to Gnome Favorites
gsettings set org.gnome.shell favorite-apps "['terminator.desktop', 'firefox.desktop', 'kali-burpsuite.desktop', 'org.gnome.Nautilus.desktop', 'mousepad.desktop', 'gnome-system-monitor.desktop']"

# IDLE Python as default editor
apt-get -yq install idle
sed -i 's|text/x-python=org.gnome.gedit.desktop|text/x-python=idle.desktop|g' /usr/share/applications/gnome-mimeapps.list
sed -i 's|application/x-python=org.gnome.gedit.desktop|application/x-python=idle.desktop|g' /usr/share/applications/gnome-mimeapps.list

# Remove default directories
rmdir Documents  Music Pictures Public Templates Videos

# Mousepad - LeafPad alternative
apt-get -yq install mousepad

# Tracing tools
apt-get -yq install ltrace strace

# Eyewitness
apt-get -yq install eyewitness

# crackmapexec
apt-get -yq install crackmapexec

# Basic calculator
apt-get -yq install bc

# wmic for Linux
apt-get -yq install wmis

# Update BurpSuite
rm /usr/bin/burpsuite.old
mv /usr/bin/burpsuite /usr/bin/burpsuite.old
wget https://portswigger.net/burp/releases/download\?product=free\&type=jar -O /usr/bin/burpsuite
chmod +x /usr/bin/burpsuite

# VIM
# Manage runtime path: https://github.com/tpope/vim-pathogen/
mkdir -p ~/.vim/autoload ~/.vim/bundle && curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
cat >~/.vimrc << EOL
execute pathogen#infect()
syntax on
filetype plugin indent on
EOL
# Syntax highlighting
# > PowerShell
mkdir -p ~/.vim/bundle
cd ~/.vim/bundle
git clone https://github.com/PProvost/vim-ps1

# Initialize Metasploit
update-rc.d postgresql enable
service postgresql start
msfdb init
# apt-get install metasploit-framework (msfupdate): has already been performed by apt-get upgrade
msfconsole -x "db_rebuild_cache; sleep 600; exit" &

#### Exploitation ####
mkdir ~/Tools
cd ~/Tools

#### Post-exploitation frameworks ####
# => PowerShell
mkdir ~/Tools/PowerShell && cd ~/Tools/PowerShell
# PowerSploit
git clone https://github.com/PowerShellMafia/PowerSploit
# Empire
export STAGING_KEY=RANDOM
git clone https://github.com/EmpireProject/Empire
cd ./Empire/setup/ && ./install.sh && cd ../..
# Nishang
git clone https://github.com/samratashok/nishang
# CimSweep
git clone https://github.com/PowerShellMafia/CimSweep
# PowerLurk
git clone https://github.com/Sw4mpf0x/PowerLurk
# PowerMemory
git clone https://github.com/giMini/PowerMemory
# PowerShell-Suite
git clone https://github.com/FuzzySecurity/PowerShell-Suite
# Autoruns
git clone https://github.com/p0w3rsh3ll/AutoRuns

# => CSharp
mkdir ~/Tools/CSharp && cd ~/Tools/CSharp
# NoPowerShell
curl -s https://api.github.com/repos/bitsadmin/nopowershell/releases/latest | grep browser_download_url | cut -d '"' -f 4 | wget -i -
unzip NoPowerShell_trunk.zip -d NoPowerShell
rm NoPowerShell_trunk.zip
# SharpUp - TODO: compile
git clone https://github.com/GhostPack/SharpUp
# SharpWeb
wget https://github.com/djhohnstein/SharpWeb/releases/download/v1.2/SharpWeb.exe -O SharpWeb46.exe
wget https://github.com/djhohnstein/SharpWeb/releases/download/v1.1/SharpWeb.exe -O SharpWeb45.exe
wget https://github.com/djhohnstein/SharpWeb/releases/download/v1.0/SharpWeb.exe -O SharpWeb20.exe
# WireTap - TODO: compile
git clone https://github.com/djhohnstein/WireTap
# SharpSploit - TODO: compile
git clone https://github.com/cobbr/SharpSploit

#### Other tools ####
cd ~/Tools
# ReVBShell
git clone https://github.com/bitsadmin/revbshell

# Dirsearch
git clone https://github.com/maurosoria/dirsearch

# Web shells and more
git clone https://github.com/fuzzdb-project/fuzzdb

# EmPyre
git clone https://github.com/adaptivethreat/EmPyre
cd ./EmPyre/setup/ && ./install.sh && cd ../..

# Shellter binary obfuscator
wget https://www.shellterproject.com/Downloads/Shellter/Latest/shellter.zip
unzip shellter.zip
rm shellter.zip

# Windows Exploit Suggester
git clone https://github.com/GDSSecurity/Windows-Exploit-Suggester
pip install xlutils
cd Windows-Exploit-Suggester
python windows-exploit-suggester.py --update
cd ..

# Linux Exploit Suggester
git clone https://github.com/PenturaLabs/Linux_Exploit_Suggester

# unix-privesc-check
git clone https://github.com/pentestmonkey/unix-privesc-check

# Latest impacket tools
cd /tmp
git clone https://github.com/CoreSecurity/impacket
cd impacket
python setup.py install
cd ~

#### Miscellaneous ####
# Unpack rockyou wordlist
gzip -d /usr/share/wordlists/rockyou.txt.gz

# TODO: Add additional rules
#wget http://contest-2010.korelogic.com/rules.txt -O /usr/share/john/korelogic.conf

# TODO: Set rockyou as default password list for John
# In /etc/john/john.conf
# Default wordlist file name. Will fall back to standard wordlist if not
# defined.
#Wordlist = $JOHN/password.lst

# Python
pip install --upgrade pip
pip install pwntools
pip install beautifulsoup4

# Proper terminal experience
apt-get -yq install terminator zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | grep -v "env zsh -l")"
# Enable infinite scrollback
mkdir ~/.config/terminator/
cat <<EOT > ~/.config/terminator/config
[profiles]
  [[default]]
    scrollback_infinite = True
EOT
# Disable update check
sed -i 's/# DISABLE_AUTO_UPDATE="true"/DISABLE_AUTO_UPDATE="true"/g' ~/.zshrc
# powerlevel9k theme
wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
mv PowerlineSymbols.otf /usr/share/fonts/X11/misc
fc-cache -vf /usr/share/fonts/X11/misc
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
sed -i 's|ZSH_THEME=".*"|ZSH_THEME="powerlevel9k/powerlevel9k"|g' ~/.zshrc
cat <<EOT >> ~/.zshrc
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(time dir)
POWERLEVEL9K_DISABLE_RPROMPT=true
POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
POWERLEVEL9K_SHORTEN_DELIMITER=""
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_from_right"
POWERLEVEL9K_TIME_FORMAT='%D{%H:%M}'
EOT
# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
sed -i 's|^plugins=[(]\(\w*\)[)]|plugins=\(\1 zsh-autosuggestions\)|g' ~/.zshrc
# Ctrl + space for autocomplete
cat <<EOT >> ~/.zshrc
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^ ' autosuggest-accept
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
EOT

# Oracle JRE
echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/apt/sources.list
echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" >> /etc/apt/sources.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
apt-get update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
apt-get -yq install oracle-java8-installer

# Cleanup apt
apt -yq autoremove

# Update locate db
updatedb

# Request password change
echo "Please change your password if you haven't done so already"

# Wait for msfconsole
echo "Waiting for msfconsole -> db_rebuild_cache to finish..."
wait

# Cleanup bash history
history -c

# Finished
echo "Done!"