#!/bin/bash
function f2f {
	find $1 -maxdepth 1 -type f | while read FILE
	do
		FOLDER=`echo ${FILE%.*}`
		mkdir "$FOLDER"
		mv "$FILE" "$FOLDER"
	done
}
# f2f `pwd`
f2f '*.avi'
f2f '*.AVI'
f2f '*.mp4'
f2f '*.MP4'
f2f '*.mkv'
f2f '*.MKV'
f2f '*.m4v'
f2f '*.M4V'
