#!/bin/bash
path="/tmp/shell"
file=$(echo $0 | cut -d "." -f1)
logfile="$path/$file.log"

mkdir -p $path

if [ ! -d $path ]; then
echo "$path doesn't exist"
exit 1
fi

filestodelete=$(find $path -name "*.log")
while IFS= read -r filepath 
do 
       echo "Delete the file: $filepath"
       rm -rf $filepath
       echo "Deleted the file: $filepath"

done <<< $filestodelete
