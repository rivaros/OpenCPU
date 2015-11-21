#!/bin/bash


if [ "$(uname)" == "Darwin" ]; then
    fswatch -E --exclude='___jb_|/\.' .
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    inotifywait -m -q -r -e CREATE,CLOSE_WRITE,DELETE,MODIFY,MOVED_FROM,MOVED_TO --exclude '___jb_|/\.' --format '%w%f' .
elif [ "$(expr substr $(uname -s) 1 6)" == "CYGWIN" ]; then
    inotifywait -m -r -q -e create,delete,modify,move --format '%w\%f' .
fi
