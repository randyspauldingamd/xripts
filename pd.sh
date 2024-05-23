#!/bin/bash
# Extends a 'standard' MIOpen ci docker container.

if (( $(ps aux | grep -c systemd) != 1 )); then
  echo "This script should only be run from a docker container."
  return 1
fi

if [ $# == 0 ]; then
  apt install -y bash-completion nano
fi

. /etc/bash_completion
alias edit='nano -l'

alias tgts='cmake --build . --target help | grep -v -e "\btest_" -e "\btidy" -e "\bgenerate" | sed "s/\.\.\. //" '

function mt() {
# TODO test this part and finish it
#  if [ "$(PWD##*/)" != "build" ]; then
#    echo "I can only be run from a directory called 'build' that has been initialized by CMake"
#    return 1
#  fi

  test=$1
  if [ $test != test* ]; then
    test=test_$1
  fi
  clear ; make -j 24 $test && bin/$test
}

function mkb() {
  mkdir build ; cd build
}

function cmk() {
  export CXX=/opt/rocm/llvm/bin/clang++ && cmake -DMIOPEN_BACKEND=HIP -DCMAKE_PREFIX_PATH="/opt/rocm/" ..
}

