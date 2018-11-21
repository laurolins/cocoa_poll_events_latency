#!env bash
if [ "$1" == "plot" ]; then
R -f plot.R
else
clang -g -ggdb -O2 -framework Cocoa -x objective-c -o main main.m 
fi


