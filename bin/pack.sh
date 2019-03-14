#!/bin/sh
file=forceblur.kwinscript 
rm -rvf "$file" 
exec zip -r9 "$file" *
