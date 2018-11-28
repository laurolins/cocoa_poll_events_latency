#!env bash
if [ "$1" == "plot" ]; then
R -f plot.R
else
FLAGS=""
# FLAGS="-DCUSTOM_EVENTS_MASK -DCUSTOM_RUN_LOOP -DDISABLE_APP_NAP"
FLAGS="-DCUSTOM_EVENTS_MASK"
clang ${FLAGS} -g -ggdb -O2 -framework Cocoa -x objective-c -o main main.m 
fi


