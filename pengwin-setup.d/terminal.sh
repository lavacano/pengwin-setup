source $(dirname "$0")/common.sh "$@"

function main() {

  local menu_choice=$(

    menu --title "Terminal Menu" --checklist --separate-output "Select the terminals you want to install\n[SPACE to select, ENTER to confirm]:" 14 60 7 \
      "WINTERM" "Windows Terminal" off \
      "WSLTTY" "WSLtty" off \
      "TILIX" "Tilix (requires X Server)" off \
      "GTERM" "Gnome Terminal (requires X Server)" off \
      "XFTERM" "Xfce Terminal (requires X Server)" off \
      "TERMIN" "Terminator (requires X Server)" off \
      "KONSO" "Konsole (requires X Server)" off \

  3>&1 1>&2 2>&3)

  if [[ ${menu_choice} == "CANCELLED" ]] ; then
    return 1
  fi

  if [[ ${menu_choice} == *"WINTERM"* ]] ; then
    echo "WINTERM"
    tmp_win_version=$(wslsys -B -s)
    if [ $tmp_win_version -lt 18362 ]; then
      whiptail --title "Unsupported Windows 10 Build" --msgbox "Windows Terminal requires Windows 10 Build 18362, but you are using $tmp_win_version. Skipping Windows Terminal." 8 56
      return
    fi

    if (whiptail --title "Windows Terminal" --yes-button "Store" --no-button "GitHub" --yesno "Would you like to install the store version or GitHub version?" 8 80) then
      wslview "ms-windows-store://pdp/?ProductId=9n0dx20hk701"
    else
      # NOT WOKRING!
      # Here has two problems:
      # 1. powershell require admin permission to install;
      # 2. dirty powerhsell implementation.
      command_check powershell.exe
      createtmp

      winterminal_url="$(curl -s https://api.github.com/repos/microsoft/terminal/releases | grep 'browser_' | head -1 | cut -d\" -f4)"
      wget --progress=dot "$winterminal_url" -O "WindowsTerminal.msixbundle" 2>&1 | sed -un 's/.* \([0-9]\+\)% .*/\1/p' | whiptail --title "Windows Terminal" --gauge "Downloading Windows Terminal..." 7 50 0
      cp "WindowsTerminal.msixbundle" ${wHome}

      powerhshell.exe -NonInteractive -NoProfile -Command "Add-AppxPackage -Path \"${wHomeWinPath}\\WindowsTerminal.msixbundle"

      cleantmp
    fi
  fi

  if [[ ${menu_choice} == *"WSLTTY"* ]] ; then
    echo "not implement... yet"
    return
  fi

  if [[ ${menu_choice} == *"TILIX"* ]] ; then
    echo "TILIX"
    sudo debconf-apt-progress -- apt-get install tilix libsecret-1-0 -y
    whiptail --title "Tilix" --msgbox "Installation complete. You can start it by running $ tilix" 8 56
  fi

  if [[ ${menu_choice} == *"GTERM"* ]] ; then
    echo "GTERM"
    sudo debconf-apt-progress -- apt-get install gnome-terminal -y
    whiptail --title "GNOME Terminal" --msgbox "Installation complete. You can start it by running $ gnome-terminal" 8 56
  fi

  if [[ ${menu_choice} == *"XFTERM"* ]] ; then
    echo "XFTERM"
    sudo debconf-apt-progress -- apt-get install xfce4-terminal -y
    whiptail --title "Xfce Terminal" --msgbox "Installation complete. You can start it by running $ xfce4-terminal" 8 56
  fi

  if [[ ${menu_choice} == *"TERMIN"* ]] ; then
    echo "TERMIN"
    sudo debconf-apt-progress -- apt-get install dbus-x11 terminator -y
    whiptail --title "Terminator" --msgbox "Installation complete. You can start it by running $ terminator" 8 56
  fi

  if [[ ${menu_choice} == *"KONSO"* ]] ; then
    echo "KONSO"
    sudo debconf-apt-progress -- apt-get install dbus-x11 konsole -y
    whiptail --title "Konsole" --msgbox "Installation complete. You can start it by running $ konsole" 8 56
  fi

  if [[ "${INSTALLED}" == true ]] ; then
    bash "${SetupDir}"/shortcut.sh --yes "$@"
  fi

}

main "$@"