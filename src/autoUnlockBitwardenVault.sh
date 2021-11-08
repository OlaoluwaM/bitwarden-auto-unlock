#!/usr/bin/env bash

rootDir="$(dirname "$(dirname "$0")")"
envFilePath="$rootDir/.env"

if [[ ! -f $envFilePath ]]; then
  echo "Script requires and env file"
  return
fi

set -o allexport
. "$envFilePath"
set +o allexport

# # if [[ -z "$MASTER_PASSWORD" ]]; then
# #   read -t 20 -sp 'Bitwarden master password not set in .env, please provide it: ' MASTER_PASSWORD
# #   [[ -z "$MASTER_PASSWORD" ]] && echo "Script cannot run without bitwarden master password" && exit 1

# #   [ -f "$rootDir/.env" ] && touch "$rootDir/.env"
# #   echo "MASTER_PASSWORD=$MASTER_PASSWORD" >"$rootDir/.env"
# # fi

# [ -f "$rootDir/tmp.txt" ] && rm "$rootDir/tmp.txt"

echo "Unlocking Your Vault 😉"

expect <(
  cat <<EOF
  spawn bw unlock
  expect "Master Password:"
  send "$MASTER_PASSWORD\r"
  interact
EOF
) 2>/dev/null 1>"$rootDir/tmp.txt"

sessionKey=$(grep -o '".*"' "$rootDir/tmp.txt" | sed 's/"//g' | uniq)

rm "$rootDir/tmp.txt"

if [[ -z $sessionKey ]]; then
  echo "Seems like you are yet to log into bitwarden"
  return
fi

export BW_SESSION=$sessionKey

echo "Done ✔️"
