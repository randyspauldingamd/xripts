#!/bin/bash

if [ $# -eq 0 ]; then
  echo "$0 should be run from your home directory. Enter '$0 go' to execute it."
  [ "$BASH_SOURCE" == "$0" ] &&
    exit 1
  return 1
fi

files=(._aliases .gitconfig)
for file in ${files[@]}; do
  cp scripts/$file .
done

[ "$BASH_SOURCE" == "$0" ] &&
  exit 0
return 0

# TODO: finish fancier version
script_dir=$(dirname $0)
data_dir=${script_dir}/data
mkdir -p ${data_dir}
home_file=${data_dir}/home_path

if [ -f ${$home_file} ]; then
  echo "Please create data/home_path: 'echo </home/randy> > <scripts_dir>/data/home_path"
  return 1
fi
