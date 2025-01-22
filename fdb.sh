#!/bin/bash

MY_CMD=less
MY_GFX=942

if [ "$1" == "rm" ]; then
  MY_CMD=rm
  shift
fi
if [ "$1" == "gfx" ]; then
  shift
  MY_GFX=$1
  shift
fi

${MY_CMD} /root/.config/miopen/gfx${MY_GFX}130.HIP.3_3_0_.ufdb.txt
