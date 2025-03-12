#!/bin/bash
# Extends a 'standard' MIOpen ci docker container.

if (( $(ps aux | grep -c systemd) != 1 )); then
  echo "This script should only be run from a docker container."
  return 1
fi

# tf dockers don't define these
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'

# export LOUD_ENV=MIOPEN_DEBUG_LOGGING_QUIETING_DISABLE=1  MIOPEN_ENABLE_LOGGING=1  MIOPEN_ENABLE_LOGGING_CMD=1  MIOPEN_LOG_LEVEL=6

if [ $# == 0 ] || [ "$1" == "puml" ] || [ "$1" == "tf" ]; then
  PKGS=bash-completion nano dotnet-runtime-8.0
  if [ "$1" == "tf" ]; then
    apt update
	PKGS=${PKGS} cmake clang-format-12
  fi
#  if [ "$1" == "puml" ]; then
#    set -m
#    # TODO: download plantuml
#    PKGS=${PKGS} default-jre graphviz
#  fi
  apt install -y ${PKGS}
fi

# TODO: edit requirements.txt, then run cmake -P install_deps.cmake --minimum --prefix ./install_dir

export USER=$( echo $PWD | awk -F/ '{print $3}' )
export PATH=/home/$USER/xripts:$PATH

. /etc/bash_completion
alias edit='nano -l'

alias tgts='cmake --build . --target help | grep -v -e "\btest_" -e "\btidy" -e "\bgenerate" | sed "s/\.\.\. //" '

function curdir() {
  mydir=${PWD##*/}
}

function in_build() {
  if [[ "${PWD##*/}" == *"build" ]]; then return 0; fi
  return 1
}

function has_build() {
  if [ $# -gt 0 ]; then
    hbtag="d"
  fi
  if [ -d "${hbtag}build" ]; then return 0; fi
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
  clear ; make -j 96 $test && bin/$test
}

function mkb() {  # creates the [d]build dir
  if [ $# -gt 0 ]; then
    mkbtag="d"
  fi
  mkbBUILD=${mkbtag}build
  if ( in_build $@ ); then
    rm ./CMakeCache.txt 2> /dev/null
  else
    mkdir -p $mkbBUILD ; cd $mkbBUILD
  fi
}

function newb() {  # wipes out the current [d]build folder
  if [ $# -gt 0 ]; then
    nbtag="d"
  fi
  nbBUILD=${nbtag}build
  if in_build; then
    cd ..
  fi
  if ( has_build $@ ); then
    rm -r $nbBUILD
  fi
  mkb $@
}

MIOPEN_TEST=MIOPEN_TEST_ALL
sudocmd=
if [ "$HOSTNAME" = shemp ]; then
  MIOPEN_TEST=MIOPEN_TEST_GFX103X
  export HSA_OVERRIDE_GFX_VERSION=10.3.0
  sudocmd=sudo
fi

function cmk() {  # runs CMake using default config
  if [ "$1" == "-h" ]; then
    echo "[TEST_TYPE=ALL|HALF|INT8|FLOAT8|BFLOAT16|FLOAT] [GFX=908|90A|94X|95X|900|906|103X|110X|120X] [CI=ON] [DEV=ON] <c|d>mk arg1 arg2 arg3 arg4 arg5 arg6"
    return 0
  fi
  MIOPEN_TEST=MIOPEN_TEST_ALL
#  MIOPEN_TEST_FLOAT8=
  if [ "$TEST_TYPE" != "" ]; then
    MIOPEN_TEST="MIOPEN_TEST_${TEST_TYPE}"
  fi
  DMIOPEN_TEXT_GFX=
  if [ "$GFX" != "" ]; then
    DMIOPEN_TEST_GFX="-DMIOPEN_TEST_GFX${GFX}=1"
  fi
  MIOPEN_CI=
  if [ "$CI" != "" ]; then
    MIOPEN_CI=-DMIOPEN_TEST_FLAGS=" --disable-verification-cache"  -DMIOPEN_USE_COMPOSABLEKERNEL=On  -DMIOPEN_USE_MLIR=ON -DMIOPEN_GPU_SYNC=Off
  fi
  BUILD_DEV=OFF
  if [ "$DEV" != "" ]; then
    BUILD_DEV=$DEV
  fi
  export CXX=/opt/rocm/llvm/bin/clang++ && $sudocmd cmake -D$MIOPEN_TEST=1 $DMIOPEN_TEXT_GFX $MIOPEN_CI -DMIOPEN_BACKEND=HIP -DBUILD_DEV=$BUILD_DEV -DCMAKE_PREFIX_PATH="/opt/rocm/" $1 $2 $3 $4 $5 $6 ..
}

function dmk() {  # runs CMake using Debug config
  export CXX=/opt/rocm/llvm/bin/clang++ && $sudocmd cmake -D$MIOPEN_TEST=1 -DCMAKE_BUILD_TYPE=Debug -DMIOPEN_BACKEND=HIP -DCMAKE_PREFIX_PATH="/opt/rocm/" -DBUILD_DEV=1 $1 $2 $3 $4 $5 $6 ..
}

function fix_test() {  # helper for shorter test names
  if [ $# -lt 1 ]; then
    return 1
  fi

  TEST=$1
  if [[ ${TEST} == "test_"* ]]; then
    TEST="bin/"${TEST}
  elif [[ ${TEST} != *"bin/test_"* ]]; then
    TEST="bin/test_"${TEST}
  fi

  echo $TEST
  return 0
}

function gtf() {  # shorthand for <test> --gtest_filter
  if [ $# -lt 2 ]; then
    echo 'Usage: # gtf [bin/test_]mytest "suiteA*:suiteB*-fixtureC*"'
    echo '   -->   bin/test_mytest --gtest_filter="suiteA*:suiteB*-fixtureC*"'
    return 1
  fi

  TEST=$(fix_test $1)
  $TEST --gtest_filter="$2"
}

function gtlt() {  # shorthand for <test> --gtest_list_tests
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
