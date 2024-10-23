#!/bin/bash

# This was the beginning of a shell script to setup for AI support
# I don't know the current status...

. pd.sh

export PYTHONPATH=$PYTHONPATH:$pwd/benchmark
export PATH="/usr/local/bin:/usr/bin:$PATH"

python3 -m pip install pytz av einops
# /bin/git clone 

