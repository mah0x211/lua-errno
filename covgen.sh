#!/usr/bin/env sh

set -ex

mkdir -p ./coverage
# Limit capture to project sources instead of filtering system headers afterward.
lcov -c -d ./src --include "$(pwd)/src/*" -o coverage/lcov.info
# genhtml -o coverage/html coverage/lcov.info
