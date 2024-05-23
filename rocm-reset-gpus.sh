#!/bin/bash
# Resets all GPUs on the system

if (( $(ps aux | grep -c systemd) == 1 )); then
  echo "This script should not be run from docker."
  exit 1
fi

num_gpus=$(rocm-smi -i | grep 'GPU' | wc -l)

for i in `seq 1 $num_gpus`; do 
  g=$((i-1))
  echo "Resetting GPU $g"
  sudo rocm-smi --gpureset -d $g
  echo "Done resetting GPU $g"
done
