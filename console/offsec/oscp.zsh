alias connect-vpn="pushd ~/.VPN; openvpn --config OS-XXXXX-PWK.ovpn; popd"
alias rdw7="rdesktop -u offsec -p XXXXXXXXXXX 10.11.4.115 -g 1280x800"
alias setip="export LHOST=\`ifconfig tap0 | awk '/inet /{print \$2}'\`;"
alias getip="setip; echo -n \$LHOST|xclip -i; echo Copied \'\$LHOST\' to clipboard and set \\\$LHOST variable"

getvictim() {
    local host=$(pwd|rev|cut -d '/' -f1|rev|cut -d'-' -f1)
    local segment=$(pwd|rev|cut -d'/' -f2|rev)
    local firstoctets="0.0.0."
    case "$segment" in
        Public) firstoctets="10.11.1." ;;
        IT) firstoctets="10.1.1." ;;
        DEV) firstoctets="10.2.2." ;;
        Admin) firstoctets="10.3.3." ;;
    esac
    
    if [[ $firstoctets == "0.0.0." ]]
    then
        echo "Unable to determine IP address"
        return
    fi

    export RHOST="${firstoctets}${host}"
    echo -n $RHOST|xclip
    echo "Copied '$RHOST' to clipboard and set \$RHOST variable"
}