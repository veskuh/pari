#!/bin/bash
set -e
rm -rf /app/build
mkdir -p /app/build
cd /app/build
qmake6 /app/pari.pro
make
QT_QPA_PLATFORM=offscreen /app/build/tests/tst_settings
QT_QPA_PLATFORM=offscreen /app/build/src/pari --selfcheck
