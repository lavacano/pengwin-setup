#!/bin/bash

source $(dirname "$0")/common.sh "$@"

execname='wlinux.exe'
echo "WSL executable name: ${execname}"
plainname='Pengwin'


# I know we should use plainname instead of Pengwin below but for some reason the icon will only work with Pengwin hard-coded

if (whiptail --title "EXPLORER" --yesno "Would you like to enable Windows Explorer shell integration?" 8 65); then
    echo "Enabling Windows Explorer shell integration."
    createtmp
    cat << EOF >> Install.reg
    Windows Registry Editor Version 5.00
    [HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\\Pengwin]
    @="Open with Pengwin"
    "Icon"="%USERPROFILE%\\AppData\\Local\\Packages\\WhitewaterFoundryLtd.Co.16571368D6CFF_kd1vv0z0vy70w\\LocalState\\rootfs\\usr\\local\\lib\\pengwin.ico"
    [HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\\Pengwin\command]
    @="_PengwinPath_ run \\"cd \\\\\\"\$(wslpath \\\\\\"%V\\\\\\")\\\\\\" && \$(getent passwd \$LOGNAME | cut -d: -f7)\\""
    "Icon"="%USERPROFILE%\\AppData\\Local\\Packages\\WhitewaterFoundryLtd.Co.16571368D6CFF_kd1vv0z0vy70w\\LocalState\\rootfs\\usr\\local\\lib\\pengwin.ico"
    [HKEY_CURRENT_USER\Software\Classes\Directory\shell\\Pengwin]
    @="Open with Pengwin"
    "Icon"="%USERPROFILE%\\AppData\\Local\\Packages\\WhitewaterFoundryLtd.Co.16571368D6CFF_kd1vv0z0vy70w\\LocalState\\rootfs\\usr\\local\\lib\\pengwin.ico"
    [HKEY_CURRENT_USER\Software\Classes\Directory\shell\\Pengwin\command]
    @="_PengwinPath_ run \\"cd \\\\\\"\$(wslpath \\\\\\"%V\\\\\\")\\\\\\" && \$(getent passwd \$LOGNAME | cut -d: -f7)\\""
    "Icon"="%USERPROFILE%\\AppData\\Local\\Packages\\WhitewaterFoundryLtd.Co.16571368D6CFF_kd1vv0z0vy70w\\LocalState\\rootfs\\usr\\local\\lib\\pengwin.ico"
EOF

    fullexec=$(wslpath -m "$(which ${execname})" | sed 's$/$\\\\\\\\$g')
    sed -i "s/_${plainname}Path_/${fullexec}/g" Install.reg
    cp Install.reg $(wslpath "$(cmd.exe /c 'echo %TEMP%' 2>&1 | tr -d '\r')")/Install.reg
    cmd.exe /C "Reg import %TEMP%\Install.reg"
    cleantmp
 else
    echo "Disabling Windows Explorer shell integration."
    createtmp
    cat << EOF >> Uninstall.reg
    Windows Registry Editor Version 5.00
    [-HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\\${plainname}]
    [-HKEY_CURRENT_USER\Software\Classes\Directory\shell\\${plainname}]
EOF
    cp Uninstall.reg $(wslpath "$(cmd.exe /c 'echo %TEMP%' 2>&1 | tr -d '\r')")/Uninstall.reg
    cmd.exe /C "Reg import %TEMP%\Uninstall.reg"
    cleantmp
fi