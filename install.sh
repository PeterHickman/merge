#!/bin/sh

BINARY='/usr/local/bin'

echo "Building merge"
go build merge.go

echo "Installing merge to $BINARY"
install -v merge $BINARY

echo "Removing the build"
rm merge
