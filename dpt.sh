#!/data/data/com.termux/files/usr/bin/bash
# dpt - simple interactive package manager for Termux
set -u

G="\e[32m"; R="\e[31m"; Y="\e[33m"; C="\e[36m"; B="\e[1m"; N="\e[0m"

need() { command -v "$1" >/dev/null 2>&1 || { echo -e "${R}Missing: $1${N}"; exit 1; }; }
need apt
need pkg

pause() { echo; read -r -p "Press Enter to continue..." _; }

header() {
  clear
  echo -e "${C}${B}========================================${N}"
  echo -e "${C}${B}  dpt - Package Manager${N}"
  echo -e "${C}${B}========================================${N}"
  echo
}

do_search() {
  header
  read -r -p "Search for: " q
  [ -z "$q" ] && return
  echo
  apt-cache search "$q" | sort
  pause
}

do_install() {
  header
  read -r -p "Package name(s) to install: " pkgs
  [ -z "$pkgs" ] && return
  echo
  pkg install $pkgs
  pause
}

do_remove() {
  header
  read -r -p "Package name(s) to remove: " pkgs
  [ -z "$pkgs" ] && return
  echo
  pkg uninstall $pkgs
  pause
}

do_update() {
  header
  echo -e "${Y}Updating package lists and upgrading...${N}"
  pkg update -y && pkg upgrade -y
  pause
}

do_list_installed() {
  header
  pkg list-installed | less
}

do_list_available() {
  header
  pkg list-all | less
}

do_info() {
  header
  read -r -p "Package name: " p
  [ -z "$p" ] && return
  echo
  apt-cache show "$p"
  pause
}

main_menu() {
  while true; do
    header
    echo "1) Search packages"
    echo "2) Install package(s)"
    echo "3) Remove package(s)"
    echo "4) Update & upgrade system"
    echo "5) List installed packages"
    echo "6) List all available packages"
    echo "7) Show package info"
    echo "0) Exit"
    echo
    read -r -p "Choose an option: " choice
    case "$choice" in
      1) do_search ;;
      2) do_install ;;
      3) do_remove ;;
      4) do_update ;;
      5) do_list_installed ;;
      6) do_list_available ;;
      7) do_info ;;
      0) echo -e "${G}Bye!${N}"; exit 0 ;;
      *) echo -e "${R}Invalid option${N}"; sleep 1 ;;
    esac
  done
}

if [ $# -gt 0 ]; then
  cmd="$1"; shift
  case "$cmd" in
    search) apt-cache search "$*" | sort ;;
    install) pkg install "$@" ;;
    remove|uninstall) pkg uninstall "$@" ;;
    update) pkg update -y && pkg upgrade -y ;;
    list) pkg list-installed ;;
    info) apt-cache show "$1" ;;
    *) echo -e "${R}Unknown command: $cmd${N}"; echo "Usage: dpt [search|install|remove|update|list|info] [args]"; exit 1 ;;
  esac
  exit 0
fi

main_menu
