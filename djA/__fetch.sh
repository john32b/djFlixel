#!/bin/bash

# Copies the djA library files that djflixel needs from haxelib path

# CD to current script dir, in case it was called from elsewhere
cd "$(dirname "$0")"

# Get where the files are
libpath=$(haxelib libpath djA)
[[ $? -ne 0 ]] && {
	echo Cannot find \'djA\' on haxelib, is it installed?
	exit 1;
}
echo Found djA at \"$libpath\"

# Files to copy over
FILES=(
	ArrayExecSync.hx
	DataT.hx
	Macros.hx
	types/SimpleCoords.hx
	types/SimpleRect.hx
	types/SimpleVector.hx
)

# Some manual initialization 
mkdir -p types


function copyfile() {
	echo .. copying file \"$1\"
	cp "$libpath"djA/$1 "./$1" -f
}


for f in "${FILES[@]}"; do 
	copyfile $f
done

echo - DONE -

