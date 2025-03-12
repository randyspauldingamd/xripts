#!/bin/bash
# Runs clang-format on all applicable files in MIOpen repo.
# From https://github.com/ROCm/MIOpen/wiki/How-to-format-code

CLANG_CMD=clang-format-12

if ! command -v ${CLANG_CMD} 2>&1 >/dev/null
then
    echo "Error! ${CLANG_CMD} could not be found"
    exit 1
fi

if [ $# == 0 ]; then
    find . -iname '*.h' \
     -o -iname '*.hpp' \
     -o -iname '*.cpp' \
     -o -iname '*.h.in' \
     -o -iname '*.hpp.in' \
     -o -iname '*.cpp.in' \
     -o -iname '*.cl' \
   | grep -v -E '(build/)|(install.*/)' \
   | xargs -n 1 -P $(nproc) -I{} -t ${CLANG_CMD} -style=file {} -i 2>/dev/null
else
    find . -iname '*.h' \
     -o -iname '*.hpp' \
     -o -iname '*.cpp' \
     -o -iname '*.h.in' \
     -o -iname '*.hpp.in' \
     -o -iname '*.cpp.in' \
     -o -iname '*.cl' \
   | grep -v -E '(build/)|(install.*/)'
fi
