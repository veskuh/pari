#!/bin/bash
set -e
rm -rf /app/build
mkdir -p /app/build
cd /app/build
qmake6 /app/pari.pro
make
cd /app/build/tests
make
QT_QPA_PLATFORM=offscreen ./tst_all
cd /app
QT_QPA_PLATFORM=offscreen /app/build/src/pari --selfcheck
