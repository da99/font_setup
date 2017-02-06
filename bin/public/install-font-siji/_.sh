
# === {{CMD}}
# === Installs the siji font.
install-font-siji () {
  mkdir -p "$THIS_DIR"/progs
  cd "$THIS_DIR"/progs
  if [[ -d "siji" ]]; then
    cd siji
    git pull
  else
    git clone https://github.com/stark/siji
    cd siji
  fi
  ./install.sh
} # === end function
