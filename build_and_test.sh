#!/bin/bash
set -e
rm -rf /app/build
mkdir -p /app/build
cd /app/build
cmake ..
make
QT_QPA_PLATFORM=offscreen ./tests/tst_all
cd /app
QT_QPA_PLATFORM=offscreen /app/build/src/pari --selfcheck
