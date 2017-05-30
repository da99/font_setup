
# === {{CMD}}
list () {
  fc-list | cut -d':' -f2 | sort | uniq
  exit 0
  local +x IFS=$'\n'
  for DIR in $(find "$THIS_DIR"/bin/public -maxdepth 1 -mindepth 1 -type d -name "install-font-*"); do
    local +x BASE="$(basename "$DIR")"
    echo ${BASE#install-font-}
  done
} # === end function
