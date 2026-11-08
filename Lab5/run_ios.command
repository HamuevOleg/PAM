#!/bin/zsh
set -eu
cd "${0:A:h}/../Lab2/run_baza"
if command -v flutter >/dev/null; then
  runner="$(command -v flutter)"
else
  runner="$HOME/development/flutter/bin/flutter"
fi
if [[ ! -x "$runner" ]]; then
  echo 'Install Flutter and add it to PATH, then run this script again.'
  read 'answer?Press Enter to close.'
  exit 1
fi
"$runner" pub get --enforce-lockfile
open -a Simulator
exec "$runner" run "$@"
