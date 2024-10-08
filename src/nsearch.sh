#!/usr/bin/env bash
CACHE_DIR="${NSEARCH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/nsearch}"
FZF_CMD="${NSEARCH_FZF_CMD:-fzf --multi --preview-window=top,3,wrap}"

program_check() {
  if ! command -v "$1" >/dev/null; then
    echo "[err]  ..... $1 is not installed"
    exit 1
  fi
}

all_checks() {
  program_check "nix"
  program_check "jq"
  program_check "fzf"
}

checks() {
  all_checks
  if [ ! -d "$CACHE_DIR" ]; then
    echo "[err]  ..... Cache directory does not exist"
    mkdir -p "$CACHE_DIR"
    echo "[info] .... Cache directory created"
  fi
  if [ ! -f "$CACHE_DIR/db.json" ]; then
    echo "[err]  ..... db is not available"
    if ! update; then
      echo "[err]  ..... Failed to update db | Check Network!"
      exit 1
    fi
  fi

  if [ $# -eq 1 ]; then
    echo "[info] .... All checks passed"
  fi
}

loading() {
  pid=$!
  i=1
  sp="\|/-"
  printf "%s ..." "$1"
  while ps -p $pid >/dev/null; do
    printf "\b%c" "${sp:i++%4:1}"
    sleep 0.1
  done
  echo ""
}

update() {
  mkdir -p "$CACHE_DIR"
  nix search nixpkgs --json "" 2>/dev/null 1>"$CACHE_DIR/db.json" &
  loading "[info] Updating the local Database"
  echo "[info] .... Database updated"
}

preview_data() {
  attrs="$(jq -r '. | keys[]' <"$CACHE_DIR/db.json" |
    cut -d \. -f 1-2 |
    uniq |
    head -n1)"

  pname="$(jq -r ".\"$attrs.$1\".pname" <"$CACHE_DIR/db.json")"
  description="$(jq -r ".\"$attrs.$1\".description" <"$CACHE_DIR/db.json")"
  version="$(jq -r ".\"$attrs.$1\".version" <"$CACHE_DIR/db.json")"

  cat <<EOF | fold -s -w $COLUMNS
Package Name: $pname
Version: $version
Description: $description
EOF

}

export -f preview_data

search() {
  export CACHE_DIR
  jq -r ". | keys[]" <"$CACHE_DIR/db.json" |
    cut -d \. -f 3- |
    ${FZF_CMD} --preview='bash -c "source <(declare -f preview_data); preview_data {}"' |
    xargs
}

# Argument handler
while [[ "$#" -gt 0 ]]; do
  case "$1" in
  -h | --help)
    help
    exit 0
    ;;
  -u | --update)
    update
    exit 0
    ;;
  -c | --check)
    checks 1
    exit 0
    ;;
  *)
    echo "Unknown option: $1"
    help
    exit 1
    ;;
  esac
done

# Default behavior if no arguments are provided
checks
search
