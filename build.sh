#!env bash
if [ "$1" == "plot" ]; then
	R -f plot.R
elif [ "$1" == "stats" ]; then
	R -f stats.R
elif [ "$1" == "profile" ]; then
	instruments -t "Time Profiler" ./main
else
	FLAGS=""
	# FLAGS="-DCUSTOM_EVENTS_MASK -DCUSTOM_RUN_LOOP -DDISABLE_APP_NAP"
	FLAGS="-DCUSTOM_EVENTS_MASK"
	clang ${FLAGS} -g -ggdb -O2 -framework Cocoa -x objective-c -o main main.m 
fi


