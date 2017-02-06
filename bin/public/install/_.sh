
# === {{CMD}}  --all
# === {{CMD}}  --list
# === {{CMD}}  siji
install () {
  local +x NAME="$1"; shift
  case "$NAME" in
    --all)
      source "$THIS_DIR"/bin/public/list/_.sh
      local +x IFS=$'\n'
      for NAME in $(list); do
        install "$NAME"
      done
      ;;

    *)
      local +x DIR="$THIS_DIR"/bin/public/install-font-"$NAME"
      if [[ ! -d "$DIR" ]]; then
        echo "!!! Invalid name for font: $NAME" >&2
        echo "!!! Use 'list' to get names."     >&2
        exit 2
      fi
      source "$DIR"/_.sh
      install-font-"$NAME"
      ;;
  esac
} # === end function
