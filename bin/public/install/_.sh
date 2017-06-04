
# === {{CMD}}        # Currently, defaults to powerline
# === {{CMD}}  siji
# === {{CMD}}  font.zip
# === {{CMD}}  powerline
install () {
  #  NOTE: $HOME/.fonts path is deprecated:
  #        https://wiki.archlinux.org/index.php/font_configuration#Font_paths
  local +x DESTDIR="$HOME/.local/share/fonts"
  mkdir -p "$DESTDIR"

  if [[ -z "$@" ]]; then
    local +x NAME="default"
  else
    local +x NAME="$1"; shift
  fi

  PATH="$PATH:$THIS_DIR/../my_os/bin"
  PATH="$PATH:$THIS_DIR/../my_fs/bin"

  case "$NAME" in
    default)
      my_os package --install fontconfig cairo freetype google-fonts-ttf
      echo "=== Installing powerline:"
      font_setup install powerline

      case "$(my_os name)" in
        "rolling_void")
          local +x AVAIL="/usr/share/fontconfig/conf.avail"
          local +x INSTALLED="/etc/fonts/conf.d"
          my_fs link "$AVAIL/11-lcdfilter-default.conf" "$INSTALLED"
          my_fs link "$AVAIL/10-sub-pixel-rgb.conf"     "$INSTALLED"
          my_fs link "$AVAIL/10-hinting-slight.conf"    "$INSTALLED"
          my_fs link "$THIS_DIR/config/local.conf"      "/etc/fonts"
          ;;
        *)
          echo "!!! Unknown OS: $(my_os name)" >&2
          exit 1
          ;;
      esac
      ;;

    powerline)
      cd "$THIS_DIR"
      scripts/install-powerline
      ;;

    fontsquirrel)
      local +x NAME="$1"; shift
      local +x SEARCH_NAME="${NAME//-/.*}"
      local +x URL="https://www.fontsquirrel.com/fonts/download/$NAME"

      if font_setup search "$NAME" ; then
        echo "=== Already installed."
        exit 0
      fi

      cd /tmp
      mkdir -p my_font
      cd my_font
      if [[ ! -s "$NAME.zip" ]]; then
        wget "$URL" --output-document "$NAME.zip"
      fi
      if [[ ! -d "$NAME" ]]; then
        unzip "$NAME.zip" -d "$NAME"
      fi

      cd "$NAME"
      IFS=$'\n'
      for FILE in $(find . -type f | grep -iP ".(otf|pcf|ttf)") ; do
        cp -i "$FILE" "$HOME/.local/share/fonts"
      done
      fc-cache -fv
      font_setup list | grep --color=always -i -E "$SEARCH_NAME"
      ;;

    alternatives)
      font_setup install fontsquirrel heuristica
      font_setup install fontsquirrel oswald
      font_setup install fontsquirrel signika
      font_setup install fontsquirrel felipa
      font_setup install fontsquirrel tex-gyre-bonum
      font_setup install fontsquirrel tex-gyre-schola
      font_setup install fontsquirrel tex-gyre-pagella
      font_setup install fontsquirrel courier-prime

      # scripts/download "noto             noto-fonts-ttf"
      # scripts/download "liberation       liberation-fonts-ttf"

      # scripts/download "gelasio*.ttf     https://github.com/axilleas/googlefonts"
      # scripts/download "helvetica-*.tff  https://github.com/adampash/Lifehacker.me/tree/master/fonts"
      # scripts/download "helvetica-*.tff  https://github.com/nellielemonier/Helvetica-Neue"
      # scripts/download "weblysleek*.ttf  https://github.com/nathanboktae/oauthdevconsole/tree/master/app/fonts"

      ;;

    *.zip|*.ZIP)
      local +x FILE="$(realpath "$NAME")"
      unzip "$FILE" -d "$DESTDIR"
      fc-cache -fv
      ;;

    raleway)
      mkdir -p /tmp/google-fonts
      cd       /tmp/google-fonts

      for FILE in $(lynx --dump https://github.com/google/fonts/tree/master/ofl/raleway  | grep -P '\]Raleway.*.ttf' | cut -d']' -f2 | cut -d'[' -f1); do
        wget -O "$FILE" "https://github.com/google/fonts/blob/master/ofl/raleway/${FILE}?raw=true"
      done
      cp -f *.ttf "$DESTDIR"
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

      mkdir -p "$DESTDIR"
      cp -f *.otf "$DESTDIR"
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
      cp bitmap/$NAME/**/*.$EXT "$DESTDIR" -f ||
      cp bitmap/$NAME/*.$EXT "$DESTDIR" -f
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

    *)
      if [[ -d "$NAME" ]]; then
        local +x DIR="$NAME"
        local +x IFS=$'\n'
        cd "$DIR"
        unzip '*.zip' -d "$DESTDIR"
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
