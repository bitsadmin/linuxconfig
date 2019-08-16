#!/bin/bash
#
# This software is provided under under the BSD 3-Clause License.
# See the accompanying LICENSE file for more information.
#
# Miscellaneous functions useful for hacking
#
# Author:
#  Arris Huijgen
#
# Website:
#  https://github.com/bitsadmin/linuxconfig
#

# Open searchsploit result easily using leafpad
llp() {
	if [[ -z $1 ]]
	then
		echo "Usage: llp [path]\n"
		echo "Example: "
		echo "$ searchsploit diskboss"
		echo "$ llp exploits/windows/remote/43478.py"
		return
	fi
	
	leafpad $(locate $(echo $1|sed 's/\.\//\//g'))
}

# Netcat listen
ncl() {
	local PORT=7777
	if [ ! -z $1 ]
	then
		PORT=$1
	fi
	nc -lvvp $PORT
}

# Hashcat
hc() {
	declare -A a; a["md5"]=0; a["sha1"]=100; a["ntlm"]=1000; a["sha256"]=1400; a["sha512"]=1700; a["lm"]=3000;
	
	if [ -z $2 ]
	then
        echo "Launches hashcat using the rockyou.txt wordlist"
		echo "hc [algorithm] [hash|file]"
		echo "- Algorithms: md5, sha1, ntlm, sha256, sha512, lm"
		return -1
	fi
	
	local ALGORITHM=$a["$1"]
	local HASH=$2
	
	if [ ! -z $ALGORITHM ]
	then
		hashcat --force -m $ALGORITHM $HASH /usr/share/wordlists/rockyou.txt
	else
		echo Unknown algorithm: $1
	fi
}
