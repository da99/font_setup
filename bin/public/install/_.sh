
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
      my_os package --install \
        fontconfig            \
        cairo                 \
        freetype              \
        noto-fonts-ttf        \
        liberation-fonts-ttf

      echo "=== Installing powerline:"
      font_setup install powerline

      echo "=== Installing nerd-fonts:"
      font_setup install nerd-fonts

      echo "=== Installing fontsquirrel fonts:"
      font_setup install fontsquirrel \
        heuristica \
        oswald     \
        signika    \
        felipa     \
        tex-gyre-bonum \
        tex-gyre-schola \
        tex-gyre-pagella \
        courier-prime

      echo "=== Installing fonts from github:"
      font_setup install https://github.com/axilleas/googlefonts gelasio
      font_setup install https://github.com/nellielemonier/Helvetica-Neue helveticaneue
      font_setup install https://github.com/nathanboktae/oauthdevconsole/tree/master/app/fonts weblysleek

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


    nerd-fonts)
      local +x TAG="$(lynx --dump "https://github.com/ryanoasis/nerd-fonts/releases" | grep -iP '^[\d\s\.]+http.+/nerd-fonts/releases/tag/v[\d\.]+$' | rev | cut -d'/' -f1 | rev | sort --version-sort | tail -n 1)"
      local +x DESTDIR="$HOME/.local/share/fonts"
      local +x COUNT="0"
      IFS=$'\n'

      local +x TMP="/tmp/my_font"
      mkdir -p "$TMP"

      for LINE in $(lynx --dump "https://github.com/ryanoasis/nerd-fonts/releases" | grep -iP '^[\d\.\s]+http.+/nerd-fonts/releases/download/'$TAG'/.+\.zip$') ; do
        cd "$TMP"
        local +x URL="${LINE#*.* }"
        local +x NAME="$(basename "$URL" .zip)"
        echo "=== Downloading $NAME:"
        if [[ ! -e "$NAME".zip ]]; then
          wget "$URL" --output-document="$NAME.zip"
          unzip "$NAME.zip" -d "$NAME"
        fi
        cd "$NAME"

        for FILE in $(find . -type f | grep -iP ".(otf|pcf|ttf)"); do
          local +x FILE="$(basename "$FILE")"
          if [[ ! -e "$DESTDIR/$FILE" ]]; then
            cp -i "$FILE" "$DESTDIR"
            COUNT=$(( COUNT + 1 ))
          else
            echo "=== Already installed: $FILE"
          fi
        done

      done # for LINE in releases

      if [[ $COUNT -gt 0 ]]; then
        fc-cache -fv
      fi
      ;;

    *"github"*)
      local +x URL="$NAME"
      local +x NAME="$1"; shift
      local +x FOUND=0
      local +x INSTALLED=0
      local +x DESTDIR="$HOME/.local/share/fonts"

      if font_setup search "$NAME" ; then
        echo "=== Already installed."
        exit 0
      fi

      local +x TMP="/tmp/my_font/$NAME"
      mkdir -p "$TMP"
      cd "$TMP"

      IFS=$'\n'
      for LINE in $(lynx --dump "$URL" | grep -i -P '^ *\d+\. +http.+github.+'$NAME'.*(otf|pcf|ttf)$' ) ; do
        FOUND=$((FOUND + 1))
        LINE="${LINE/\/blob\//\/raw\/}"
        LINE="${LINE#*.* }"
        local +x DOWNLOAD="$LINE"
        local +x FILE_NAME="$(basename "$DOWNLOAD")"


        if [[ ! -e "$DESTDIR"/"$FILE_NAME" ]]; then
          if [[ ! -e "$FILE_NAME" ]]; then
            wget "$DOWNLOAD"
          fi
          cp -i "$FILE_NAME" "$DESTDIR"
          INSTALLED="$(( INSTALLED + 1 ))"
        else
          echo "=== Already installed: $FILE_NAME"
        fi
      done

      if [[ "$FOUND" -lt 1 ]]; then
        echo "!!! No fonts found: $NAME" >&2
        exit 2
      fi

      if [[ "$INSTALLED" -gt 0 ]]; then
        fc-cache -fv
      fi
      ;;

    fontsquirrel)
      local +x IFS=$'\n'
      while [[ ! -z "$@" ]]; do
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
        for FILE in $(find . -type f | grep -iP ".(otf|pcf|ttf)") ; do
          cp -i "$FILE" "$HOME/.local/share/fonts"
        done
      done
      fc-cache -fv
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
