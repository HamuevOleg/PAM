#!/bin/zsh
set -eu
cd "${0:A:h}/../Lab2/server"
if ! command -v node >/dev/null; then
  local_node="$HOME/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin"
  if [[ -x "$local_node/node" ]]; then export PATH="$local_node:$PATH"; fi
fi
if ! command -v node >/dev/null || ! node -e 'process.exit(Number(process.versions.node.split(".")[0]) >= 24 ? 0 : 1)'; then
  echo 'Install Node.js 24 or newer, then run this script again.'
  read 'answer?Press Enter to close.'
  exit 1
fi
if command -v pnpm >/dev/null; then
  runner="$(command -v pnpm)"
else
  runner="$HOME/.cache/codex-runtimes/codex-primary-runtime/dependencies/bin/fallback/pnpm"
fi
if [[ ! -x "$runner" ]]; then
  echo 'Install pnpm 11.25.0, then run this script again.'
  read 'answer?Press Enter to close.'
  exit 1
fi
if [[ ! -d node_modules ]]; then "$runner" install --frozen-lockfile; fi
exec "$runner" start
