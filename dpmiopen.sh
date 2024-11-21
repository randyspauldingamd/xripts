#/bin/bash

if (( $(ps aux | grep -c systemd) == 1 )); then
  echo "This script should not be run from docker."
  exit 1
fi

docker pull rocm/miopen:$1

