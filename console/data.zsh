#!/bin/bash
#
# This software is provided under under the BSD 3-Clause License.
# See the accompanying LICENSE file for more information.
#
# Functions to quickly encode and decode data
#
# Author:
#  Arris Huijgen
#
# Website:
#  https://github.com/bitsadmin/linuxconfig
#

# Get input either from first parameter or STDIN
# TODO, check: https://stackoverflow.com/questions/15184358/how-to-avoid-bash-command-substitution-to-remove-the-newline-character
__getinput() {
    declare i=$1
    if [ -z $i ]
    then
        i=`cat`
    fi
    printf "%s" "$i"
}

# Base64 encode
be() {
    printf "%s" "$(__getinput $1)"|base64
}

# Base64 decode
bd() {
    printf "%s" "$(__getinput $1)"|base64 -d
}

# Url encode
ue() {                              
    printf "%s" "$(__getinput $1)"|python -c "import urllib,sys; sys.stdout.write(urllib.quote(sys.stdin.read()))"
}

# Url decode
ud() {
    printf "%s" "$(__getinput $1)"|python -c "import urllib,sys; sys.stdout.write(urllib.unquote(sys.stdin.read()))"
}

# Hex encode
he() {
    printf "%s" "$(__getinput $1)"|python -c "import sys; sys.stdout.write(sys.stdin.read().encode('hex'))"
}

# Hex decode
hd() {
    printf "%s" "$(__getinput $1)"|python -c "import sys; sys.stdout.write(sys.stdin.read().decode('hex'))"
}