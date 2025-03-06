#/bin/bash

if (( $(ps aux | grep -c systemd) == 1 )); then
  echo "xupdate should not be run from docker."
  exit 1
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# echo "xupdate is in ${SCRIPT_DIR}"
cd ${SCRIPT_DIR}

if (( $(git st | wc -l) > 1 )); then
  # TODO: add flags to prompt to discard changes or discard automatically
  echo "You have uncommitted changes; aborting"
  exit 1
fi

# TODO: error checking!
. ssha
# TODO: remember current branch
git co main
git pull
# TODO: count levels to home
cd ..
phome.sh go
