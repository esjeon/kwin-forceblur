#!/bin/sh
file=kwin-force-blur.kwinscript 
rm -rvf "$file" 
exec zip -r9 "$file" *
