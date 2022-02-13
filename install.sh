#!/bin/sh
set -euf

if [[ ! -f forceblur.kwinscript ]]; then
	echo "Error: can't find package file: $PWD/forceblur.kwinscript"
	echo "Please run 'pack' first"
	exit 1
fi >&2

plasmapkg2 -i forceblur.kwinscript || plasmapkg2 -u forceblur.kwinscript
mkdir -pv ~/.local/share/kservices5/
cp -vf metadata.desktop ~/.local/share/kservices5/forceblur.desktop

