#!/bin/bash
#
# This software is provided under under the BSD 3-Clause License.
# See the accompanying LICENSE file for more information.
#
# Functions useful for red teaming
#
# Author:
#  Arris Huijgen
#
# Website:
#  https://github.com/bitsadmin/linuxconfig
#

function rto_new_identity() {
    if [ -z $3 ]
    then
        echo "Usage: rto_new_identity [interface] [hostname prefix] [number of digits] [optional: startmac]"
        echo "- interface: network interface to use, i.e. tap4"
        echo "- hostname prefix: hostname prefix to use in DHCP request, i.e. WRPDC"
        echo "- number of digits: number of random digits to add behind hostname, i.e. 3"
        echo "- startmac: have MAC address start with these 3 hexidecimal digits, i.e. c8:cb:b8"
        return
    fi

    # 1 = interface
    # 2 = hostname prefix
    # 3 = number of digits
    # 4 = startmac
    
    newmac=$(cat /dev/urandom|head -c 5|md5sum|sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\)\(..\).*$/\1:\2:\3:\4:\5:\6/')
    if [ ! -z $4 ]
    then
        prefix=$(echo $4|sed 's/[:-]//g')
        newmac=$(echo "$prefix$(cat /dev/urandom|head -c 5|md5sum)"|sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\)\(..\).*$/\1:\2:\3:\4:\5:\6/')
    fi

    tmpfile=$(mktemp)
    t="tee -a $tmpfile"
    
    echo "\e[91m=> Updating mac of $1 to \"$newmac\"\e[39m"
    ip link set $1 down|&eval $t
    macchanger -m $newmac $1|&eval $t
    if [ ! $? = 0 ]
    then
        echo "Updating MAC address failed"
    return
    fi
    ip link set $1 up|&eval $t
    echo "Press enter to continue"
    read

    hostname="$2$(tr -c -d 0-9 < /dev/urandom | head -c $3)"
    echo -e "\n\e[91m=> Updating hostname to \"$hostname\"\e[39m"
    sed -i "s/^send host-name .*$/send host-name \"$hostname\";/g" /etc/dhcp/dhclient.conf|&eval $t
    if [ $? = 0 ]
    then
        echo "Successfully updated hostname"
    else
        echo "Problem updating hostname"
        return
    fi
    echo "Press enter to continue"
    read

    echo -e "\e[91m\n=> Obtaining new DHCP lease\e[39m"
    dhclient -v $1|&eval $t

    echo -e "\e[91m\n\nSummary\e[39m"
    echo "Interface: $1"
    echo "Hostname: $hostname"
    echo "MAC address: $newmac"
    echo "IP address: $(awk '/bound to /{print $3}' $tmpfile)"

    echo -e "\nMake sure to restart the traffic capture if needed!"
}

function rto_capture_traffic() {
    if [ -z $1 ]
    then
        echo "Usage: rto_capture_traffic [interface]"
        return
    fi
    
    md $HOME/Logging/$(date +"%Y%m%d")/Network
    tcpdump -s0 -n -i $1 -w $HOME/Logging/$(date +"%Y%m%d")/Network/$(date +"%Y%m%d_%H%M%S")_$1.pcap
}

function rto_update_time() {
    echo "\e[91mUpdating time..."
    echo "Current time: $(date)\e[39m"
    ntpd -gq
    echo "\e[91mUpdated time: $(date)\e[39m"
}

alias rto_copy_cobaltstrike="mkdir $HOME/Logging/$(date +"%Y%m%d")/CobaltStrike; cp -Rv /root/Tools/cobaltstrike38/logs/$(date +"%y%m%d")/* $HOME/Logging/$(date +"%Y%m%d")/CobaltStrike"
