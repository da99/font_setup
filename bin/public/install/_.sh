
# === {{CMD}}  --all
# === {{CMD}}  --list
# === {{CMD}}  siji
# === {{CMD}}  font.zip
install () {
  local +x NAME="$1"; shift

  case "$NAME" in
    *.zip|*.ZIP)
      local +x FILE="$(realpath "$1")"; shift
      unzip "$FILE" -d "$HOME"/.fonts
      fc-cache -fv
      ;;

    --all)
      source "$THIS_DIR"/bin/public/list/_.sh
      local +x IFS=$'\n'
      for NAME in $(list); do
        install "$NAME"
      done
      ;;

    *)
      if [[ -d "$NAME" ]]; then
        local +x DIR="$NAME"
        local +x IFS=$'\n'
        cd "$DIR"
        unzip '*.zip' -d "$HOME"/.fonts
        fc-cache -fv
        exit 0
      fi

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
