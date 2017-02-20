
# === {{CMD}}  a1b2
# === More info: https://github.com/jaagr/polybar/issues/45
copy () {
  local +x CODE="$1"
  if ! (echo "$CODE" | grep -E "^[a-zA-Z0-9]{4}$"); then
    echo "!!! Invalid code: $CODE"
    exit 2
  fi

  echo -ne "\u${CODE}" | xclip -selection clipboard
} # === end function
