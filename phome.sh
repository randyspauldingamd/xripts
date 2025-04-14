#!/bin/bash

if [ $# -eq 0 ]; then
  echo "phome should be run from your home directory (not sourced). Enter '$ phome go' to execute it from here."
  [ "$BASH_SOURCE" == "$0" ] &&
    exit 1
  return 1
fi

mkdir repos 2> /dev/null

homefiles=(._aliases .bashrc .gitconfig)

for file in ${homefiles[@]}; do
  cp $file $file.bak 2> /dev/null
  cp xripts/home/$file .
done

# TODO: finish fancier version. quick exit for now
exit 0

#[ "$BASH_SOURCE" == "$0" ] &&
#  exit 0

script_dir=$(dirname $0)
data_dir=${script_dir}/data
mkdir -p ${data_dir}
home_file=${data_dir}/home_path

if [ -f ${${home_file}} ]; then
  echo "Please create data/home_path: 'echo </home/randy> > <scripts_dir>/data/home_path"
  return 1
fi

[ -f ssh.tar ] && rm ssh.tar 2>&1 > /dev/null
