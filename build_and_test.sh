#!/bin/bash
set -e
rm -rf /app/build
mkdir -p /app/build
cd /app/build
cmake ..
make
cd /app/build/tests
./tst_all
cd /app
/app/build/src/pari --selfcheck
