#!/data/data/com.termux/files/usr/bin/bash
set -u

G="\e[32m"; R="\e[31m"; Y="\e[33m"; C="\e[36m"; N="\e[0m"
SILENT=false

die() { echo -e "\n${R}❌ Error: $1${N}" >&2; exit 1; }
say() { [ "$SILENT" = true ] || echo -e "$@"; }

while getopts "s" opt; do
  case $opt in
    s) SILENT=true ;;
    *) die "Invalid option. Use -s for silent mode." ;;
  esac
done

[ -n "${PREFIX:-}" ] && [ -d "$PREFIX" ] || die "Run this inside Termux."
command -v curl >/dev/null 2>&1 || pkg install curl -y >/dev/null 2>&1 || die "curl is required."

LIST="$PREFIX/etc/apt/sources.list.d/termuxvoid.list"
KEY="$PREFIX/etc/apt/trusted.gpg.d/termuxvoid.gpg"
KEY_URL="https://github.com/termuxvoid/repo/raw/main/assets/termuxvoid.gpg"

step() {
  local desc="$1"; shift
  say "${Y}>> ${desc}...${N}"
  if "$@" >/dev/null 2>&1; then
    say "${G}✅ ${desc} done${N}"
  else
    die "${desc} failed"
  fi
}

add_repo() {
  mkdir -p "$PREFIX/etc/apt/sources.list.d" || return 1
  [ -f "$LIST" ] && cp "$LIST" "$LIST.bak"
  echo 'deb [arch=all] https://termuxvoid.github.io/repo termuxvoid main' > "$LIST"
}

get_key() {
  local tmp
  tmp="$(mktemp)" || return 1
  curl -fsSL "$KEY_URL" -o "$tmp" && [ -s "$tmp" ] || { rm -f "$tmp"; return 1; }
  mv "$tmp" "$KEY"
}

say "${C}TermuxVoid Repository Installer${N}"

if [ ! -f "$PREFIX/etc/apt/sources.list.d/x11.list" ]; then
  say "${Y}>> Installing X11 repo (optional)...${N}"
  apt install x11-repo -y >/dev/null 2>&1 || say "${Y}❗ X11 repo skipped${N}"
fi

step "Adding TermuxVoid repository" add_repo
step "Downloading GPG key" get_key
step "Updating package lists" apt update -y
step "Installing tvpkg" apt install tvpkg -y

say "\n${G}🎉 Setup complete!${N}"
say "Run: ${C}tvpkg${N} (or ${C}tvp${N})"
say "Install tools: pkg install <tool-name>"
say "Telegram: https://telegram.me/nullxvoid/"
