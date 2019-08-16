#!/bin/bash
#
# This software is provided under under the BSD 3-Clause License.
# See the accompanying LICENSE file for more information.
#
# Miscellaneous aliases and shortcuts
#
# Author:
#  Arris Huijgen
#
# Website:
#  https://github.com/bitsadmin/linuxconfig
#

alias clip="xclip -selection clipboard"
alias open="gvfs-open"
alias ascii='man ascii | grep -m 1 -A 63 --color=never Oct' # print ascii table
alias myip='curl ifconfig.io'

rdp() {
    if [ -z $1 ]
    then
        echo "Usage: rdp [host] [optional: [user] [password]]"
        return -1
    fi
    
    local HOST=$1
    local USER=dummy
    local PASSWORD=dummy
    if [ ! -z $3 ]
    then
        USER=$2
        PASSWORD=$3
        rdesktop -u $USER -p $PASSWORD $HOST -g 1280x800
    else
        rdesktop $HOST -g 1280x800
    fi
}

# Clean all apps
cleangtkapps=(leafpad gedit nautilus firefox burpsuite rdesktop idle)
for item in ${cleangtkapps[@]}
do
    alias $item="hidegtk $item"
done

# Hide GTK errors when launching application
hidegtk() {
    ($* 2>/dev/null &)
}

reset_vmware_tools() {
    pkill vmtoolsd
    sleep 1
    /usr/bin/vmtoolsd -n vmusr &
    /usr/bin/vmtoolsd &
}

# Notepad2-mod
# 1) Install Notepad2-mod from http://xhmikosr.io/notepad2-mod/ using Wine
# 2) Add the folowing lines to ~/.winerc
# [Clipboard]
# ClearAllSelections=1
# PersistentSelection=1
notepad() {
    (wine "$(locate -n 1 Notepad2.exe)" "$(winepath -w $1)" 2>/dev/null &)
}