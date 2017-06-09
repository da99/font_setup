
# === {{CMD}}  name
search () {
  PATH="$PATH:$THIS_DIR/../sh_string/bin"

  local +x NAME="$1"; shift
  local +x SEARCH_NAME="${NAME//-/.*}"
  local +x SPACED="$(sh_string insert-space-between-uppercase "$SEARCH_NAME")"
  local +x ALT=""

  case "$NAME" in
    FiraCode)
      ALT="|Fira"
      ;;
    helveticaneue)
      ALT="|Helvetica Neue"
      ;;
    Hermit)
      ALT="|Hurmit"
      ;;
    LiberationMono)
      ALT="|Literation Mono"
      ;;
    ShareTechMono)
      ALT="|ShureTechMono|Shure Tech Mono"
      ;;
    SourceCodePro)
      ALT="|Sauce Code Pro"
      ;;
    Terminus)
      ALT="|Terminess"
      ;;
  esac
  font_setup list | grep --color=always -i -E "$SEARCH_NAME|$SPACED$ALT"
} # === end function
