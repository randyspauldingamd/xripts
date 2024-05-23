#!/bin/bash
# Runs clang-format on all applicable files in MIOpen repo.
# From https://github.com/ROCm/MIOpen/wiki/How-to-format-code

find . -iname '*.h' \
    -o -iname '*.hpp' \
    -o -iname '*.cpp' \
    -o -iname '*.h.in' \
    -o -iname '*.hpp.in' \
    -o -iname '*.cpp.in' \
    -o -iname '*.cl' \
| grep -v -E '(build/)|(install/)' \
| xargs -n 1 -P $(nproc) -I{} -t clang-format-12 -style=file {} -i 2>/dev/null

