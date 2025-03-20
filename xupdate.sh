#/bin/bash

if (( $(ps aux | grep -c systemd) == 1 )); then
  echo "xupdate should not be run from docker."
  exit 1
fi

# idiomatic parameter and option handling in sh
while test $# -gt 0
do
    case "$1" in
        stash)
            STASH=YES
            ;;
        merge)
            MERGE=YES
            ;;
#        --*) echo "bad option $1"
#            ;;
        *) echo "argument $1"
            ;;
    esac
    shift
done

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# echo "xupdate is in ${SCRIPT_DIR}"
cd ${SCRIPT_DIR}

CURRENT_BRANCH=$(git branch --show-current)
if [ "$STASH" == "YES" ]; then
  git stash
elif (( $(git status | wc -l) > 1 )); then
  # TODO: add flags to prompt to discard changes or discard automatically
  echo "You have uncommitted changes; aborting"
  git st
  exit 1
fi

# TODO: error checking!
. ssha
# TODO: add option, merge main into current branch instead of this
git co main
git pull
# TODO: count levels to home
cd ..
phome.sh go
cd ${SCRIPT_DIR}
git co ${CURRENT_BRANCH}
if [ "$STASH" == "YES" ]; then
# TODO: check that we stashed something
  echo "popping stash..."
  git stash pop
fi
