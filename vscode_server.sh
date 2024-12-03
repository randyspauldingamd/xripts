#!/bin/bash

#if (( $(ps aux | grep -c systemd) == 1 )); then
#  echo "Usage: $0 <commit>"
#  echo "Where <commit> corresponds to the commit ID in Windows (Help | About)"
#  echo "Error: this script should not be run from docker."
#  exit 1
#fi

commit_id=f1a4fb101478ce6ec82fe9627c43efbf9e98c813

if [ $# -eq 0 ]; then
  echo "Usage: $0 <commit>|1"
  echo "  Where <commit> corresponds to the commit ID in Windows (Help | About)"
  echo "  Note: '$0 1' will install version $commit_id"
  exit 0
fi

if [ "$1" != "1" ]; then
  commit_id=$1
fi

wget "https://update.code.visualstudio.com/commit:${commit_id}/server-linux-x64/stable" -O vscode-server-linux-x64.tar.gz
tar zxvf vscode-server-linux-x64.tar.gz -C ~/.vscode-server/bin/${commit_id} --strip 1
touch ~/.vscode-server/bin/${commit_id}/0
