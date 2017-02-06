
# === {{CMD}}  NAME
font-select () {
  local +x NAME="$1"; shift

  case "$NAME" in
    *siji)
      local +x DIR="$THIS_DIR"/progs/siji
      cd "$DIR" || { $0 install-siji-font && cd "$DIR"; }
      ./view.sh
      ;;
    *)
      echo "!!! Invalid name for font: $@" >&2
      exit 2
      ;;
  esac

} # === end function
