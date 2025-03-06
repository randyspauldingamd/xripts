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
  git st
  exit 1
fi

# TODO: error checking!
. ssha
CURRENT_BRANCH=$(git branch --show-current)
# TODO: add option, merge main into current branch instead of this
git co main
git pull
# TODO: count levels to home
cd ..
phome.sh go
cd ${SCRIPT_DIR}
git co ${CURRENT_BRANCH}

