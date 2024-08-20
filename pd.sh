#!/bin/bash
# Extends a 'standard' MIOpen ci docker container.

if (( $(ps aux | grep -c systemd) != 1 )); then
  echo "This script should only be run from a docker container."
  return 1
fi

if [ $# == 0 ]; then
  apt install -y bash-completion nano
fi

export USER=$( echo $PWD | awk -F/ '{print $3}' )
export PATH=/home/$USER/xripts:/home/$USER/scripts:$PATH

. /etc/bash_completion
alias edit='nano -l'

alias tgts='cmake --build . --target help | grep -v -e "\btest_" -e "\btidy" -e "\bgenerate" | sed "s/\.\.\. //" '

function curdir() {
  mydir=${PWD##*/}
}

function in_build() {
  if [ "${PWD##*/}" == "build" ]; then return 0; fi
  return 1
}

function has_build() {
  if [ -d "build" ]; then return 0; fi
  return 1
}

function mt() {
  if ! in_build; then
    echo "I can only be run from a directory called 'build' that has been initialized by CMake"
    return 1
  fi

  test=$1
  if [ $test != test* ]; then
    test=test_$1
  fi
  clear ; make -j 24 $test && bin/$test
}

function mkb() {
  mkdir -p build ; cd build
  mv ./CMakeCache.txt ./oldCache.txt
}

MIOPEN_TEST=MIOPEN_TEST_ALL
sudocmd=
if [ "$HOSTNAME" = shemp ]; then
  MIOPEN_TEST=MIOPEN_TEST_GFX103X
  sudocmd=sudo
fi
function cmk() {
  export CXX=/opt/rocm/llvm/bin/clang++ && $sudocmd cmake -D$MIOPEN_TEST=1 -DMIOPEN_BACKEND=HIP -DCMAKE_PREFIX_PATH="/opt/rocm/" -DBUILD_DEV=1 $1 $2 $3 $4 $5 $6 ..
}
function dmk() {
  export CXX=/opt/rocm/llvm/bin/clang++ && $sudocmd cmake -D$MIOPEN_TEST=1 -DCMAKE_BUILD_TYPE=Debug -DMIOPEN_BACKEND=HIP -DCMAKE_PREFIX_PATH="/opt/rocm/" -DBUILD_DEV=1 $1 $2 $3 $4 $5 $6 ..
}

function fix_test() {
  if [ $# -lt 1 ]; then
    return 1
  fi

  TEST=$1
  if [[ ${TEST} != *"bin/test_"* ]]; then
    TEST="bin/test_"$TEST
  fi

  echo $TEST
  return 0
}

function gtf() {
  if [ $# -lt 2 ]; then
    echo 'Usage: # gtf [bin/test_]mytest "suiteA*:suiteB*-fixtureC*"'
    echo '   -->   bin/test_mytest --gtest_filter="suiteA*:suiteB*-fixtureC*"'
    return 1
  fi

  TEST=$(fix_test $1)
  $TEST --gtest_filter="$2"
}

function gtlt() {
  if [ $# -lt 1 ]; then
    echo 'Usage: # gtlt [bin/test_]mytest'
    echo '   -->   bin/test_mytest --gtest_list_tests'
    return 1
  fi

  TEST=$(fix_test $1)
  $TEST --gtest_list_tests
}

function get_miotag() {
  curdir
  if [[ ! $mydir =~ .*-MIOpen$ ]]; then
    return 1
  fi
  miotag=${mydir%-*}
}

function bstash() {
  if in_build; then cd ..; fi
  if ! has_build; then
    echo "Unable to find build directory, aborting"
    return 1
  fi
  curdir
  if ! get_miotag; then
    echo "Aborting, directory must match <id>-MIOpen"
    return 1
  fi
  tmpdir=../${miotag}tmp/build
  rm -r $tmpdir.1 &> /dev/null
  mv $tmpdir $tmpdir.1 &> /dev/null
  mv ./build $tmpdir
}

function brestore() {
  if in_build; then
    echo "Aborting--already in build folder"
    return 1
  fi
  if has_build; then
    echo "Aborting--a build folder already exists"
    return 1
  fi
  if ! get_miotag; then
    echo "Aborting--directory must match <id>-MIOpen"
    return 1
  fi
  tmpdir=../${miotag}tmp/build
  if [ ! -d $tmpdir ]; then
    tmpdir=$tmpdir.1
    if [ ! -d $tmpdir ]; then
      echo "Aborting; '$tmpdir' not found"
      return 1
    fi
  fi
  mv $tmpdir .
}
