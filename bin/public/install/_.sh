
# === {{CMD}}  --all
# === {{CMD}}  --list
# === {{CMD}}  siji
# === {{CMD}}  font.zip
install () {
  local +x NAME="$1"; shift
  local +x PATH="$PATH:$THIS_DIR/bin"

  case "$NAME" in
    *.zip|*.ZIP)
      local +x FILE="$(realpath "$NAME")"
      unzip "$FILE" -d "$HOME"/.fonts
      fc-cache -fv
      ;;

    raleway)
      mkdir -p /tmp/google-fonts
      cd       /tmp/google-fonts

      for FILE in $(lynx --dump https://github.com/google/fonts/tree/master/ofl/raleway  | grep -P '\]Raleway.*.ttf' | cut -d']' -f2 | cut -d'[' -f1); do
        wget -O "$FILE" "https://github.com/google/fonts/blob/master/ofl/raleway/${FILE}?raw=true"
      done
      cp -f *.ttf $HOME/.fonts
      fc-cache -fv
      ;;

    SanFrancisco|"San Francisco"*)
      cd /tmp
      local +x SF_FONTS="https://github.com/AppleDesignResources/SanFranciscoFont"
      if [[ -d "SanFranciscoFont" ]]; then
        cd SanFranciscoFont
        git pull
      else
        git clone "$SF_FONTS"
        cd SanFranciscoFont
      fi

      mkdir -p "$HOME/.fonts"
      cp -f *.otf "$HOME/.fonts"
      fc-cache -fv
      ;;

    tecate-bitmap-font)
      local +x NAME="$1"; shift
      local +x EXT="$1"; shift
      cd /tmp
      if [[ -d bitmap-fonts ]]; then
        cd bitmap-fonts
        git pull
      else
        git clone https://github.com/Tecate/bitmap-fonts
        cd bitmap-fonts
      fi
      cp bitmap/$NAME/**/*.$EXT "$HOME"/.fonts -f ||
      cp bitmap/$NAME/*.$EXT "$HOME"/.fonts -f
      fc-cache -fv
      ;;

    zevv-peep)
      font_setup install tecate-bitmap-font $NAME bdf
      ;;

    knxt)
      echo "NOTE: $NAME font best used at size 20 medium/normal" >&2
      font_setup install tecate-bitmap-font $NAME {bdr,pcf}
      ;;

    ctrld-font)
      echo "NOTE: $NAME font best used at size 13 medium/normal" >&2
      font_setup install tecate-bitmap-font $NAME bdf
      ;;

    boxxy)
      echo "NOTE: boxxy font best used at size 14 medium/normal" >&2
      font_setup install tecate-bitmap-font $NAME bdf
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
