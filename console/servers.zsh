#!/bin/bash
#
# This software is provided under under the BSD 3-Clause License.
# See the accompanying LICENSE file for more information.
#
# Oneliners to start different type of filesharing servers
#
# Author:
#  Arris Huijgen
#
# Website:
#  https://github.com/bitsadmin/linuxconfig
#

srv_ftp() {
    local USER=twistd
	local PASSWORD=password

	if [[ ! -z $1 && ($1 = "--help" || $1 = "-h") ]]
	then
        echo "Launch FTP server in /home/[user] directory"
		echo "Usage: srv_ftp [optional: [user, default: $USER] [password, default: $PASSWORD]]"
		return -1
	fi
	
	if [ ! -z $2 ]
	then
		USER=$1
		PASSWORD=$2
	fi
	
	mkdir /home/$USER > /dev/null 2>&1
	echo "FTP root directory: /home/$USER"
	echo "Url: ftp://$USER:$PASSWORD@$LHOST"
	twistd -n ftp -p 21 --auth=memory:$USER:$PASSWORD
}

srv_http() {
    if [[ ! -z $1 && ($1 = "--help" || $1 = "-h") ]]
	then
        echo "Launch HTTP server in current directory"
		echo "Usage: srv_http [optional: [port, default: 80]]"
		return -1
	fi

	local PORT=80
	if [ ! -z $1 ]
	then
		PORT=$1
	fi
	python -m SimpleHTTPServer $PORT
}

srv_smb() {
    if [[ ! -z $1 && ($1 = "--help" || $1 = "-h") ]]
	then
        echo "Launch anonymous SMB server in current directory"
		echo "Usage: srv_smb"
		return -1
	fi

	echo "Sharing current directory on \\\\$LHOST\\Share\\"
	python /usr/share/doc/python-impacket/examples/smbserver.py -comment 'My share' Share ./
}
