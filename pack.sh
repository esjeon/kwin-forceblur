#!/bin/sh
set -eu

if ! type zip >&/dev/null; then
	echo "Error: Can't find 'zip' command."
	echo "       Please install 'zip' command first."
	exit 1
fi >&2

file=forceblur.kwinscript
rm -rvf "$file"
exec zip -r9 "$file" \
	README.md \
	LICENSE \
	metadata.desktop \
	contents \
