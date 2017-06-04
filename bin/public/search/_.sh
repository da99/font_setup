
# === {{CMD}}  name
search () {
  local +x NAME="$1"; shift
  local +x SEARCH_NAME="${NAME//-/.*}"

  font_setup list | grep --color=always -i -E "$SEARCH_NAME"
} # === end function
