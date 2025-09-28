#!/bin/bash
path="/tmp/shell"
file=$(echo $0 | cut -d "." -f1)
logfile="$path/$file.log"

mkdir -p $path

if [ ! -d $path ]; then
echo "directory doesn't exist"
fi

filestodelete=$(find $path -name "*.log")
while IFS=read filepath 
do 
       echo "Delete the file: $filepath"
       rm -rf $filepath
       echo "Deleted the file: $filepath"

done <<<$filestodelete
