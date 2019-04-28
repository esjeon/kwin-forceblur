#!/bin/sh

plasmapkg2 -i forceblur.kwinscript || plasmapkg2 -u forceblur.kwinscript
mkdir -pv ~/.local/share/kservices5/
cp -vf metadata.desktop ~/.local/share/kservices5/forceblur.desktop

