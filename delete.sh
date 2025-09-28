#!/bin/bash
path="/var/log/scriptlog/"
file=$(echo $0 | cut -d "." -f1)
logfile=$path/$file.log

filepath=$(find . -name "*.log" -type f)
while [ IFS=read -s $filepath ]
do 
       echo "Delete the file: $filepath"
       rm -rf $filepath
done <<<$logfile
