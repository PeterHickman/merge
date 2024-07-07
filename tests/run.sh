#!/usr/bin/env bash

[ -d tmp ] && rm -rf tmp

for TEST in test*.rb
do
  ./${TEST}
done
