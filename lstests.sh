#!/bin/bash

if [ $# == 0 ]; then
  echo "Usage:   $0 <regex>"
  echo "Example: lstests graphapi   # lists all targets matching 'test_graphapi'"
  return 0
fi

make -qp | grep -P '^[.a-zA-Z0-9][^$#\/\t=]*:([^=]|$)' | tee >(cut -d: -f1 ) >(grep '^\s*\.PHONY\s*:' |cut -d: -f2) >/dev/null| tr ' ' '\n' | sed '/^\s*\./ d; /^\s*$/ d' |sort |uniq -u | grep test_$1
