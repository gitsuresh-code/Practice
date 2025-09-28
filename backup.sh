#!/bin/bash

user=$(id -u) #user check

#colog codes
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


sourced=$1 # first argument
destd=$2   # second argument
days=${3:-14} # if not provided considered as 14 days


logpath="/tmp/shell/applogs"
name=$( echo $0 | cut -d "." -f1 )
logfile="$logpath/$name.log" # /tmp/shell/backup.log

echo "Script started executed at: $(date)" | tee -a $logfile

if [ "$user" -ne 0 ]; then
    echo "ERROR:: Please run this script with root privelege"
    exit 1 # if user is not root. script will end here
fi


usage_instruction(){
    echo -e "$R USAGE:: sudo sh 24-backup.sh <SOURCE_DIR> <DEST_DIR> <DAYS>[optional, default 14 days] $N"
    exit 1 #if 2 args are not passed. script will end here
}

### Check for Args passed ####
if [ $# -lt 2 ]; then
    usage_instruction
fi


mkdir -p "$logpath"
# Ensure destination exists
mkdir -p "$destd"




### Check SOURCE_DIR Exist ####
if [ ! -d "$sourced" ]; then
    echo -e "$R Source $sourced does not exist $N"
    exit 1 #script will end here
fi



### Check DEST_DIR Exist ####
#if [ ! -d $destd ]; then
#   echo -e "$R Destination $destd does not exist $N"
#    exit 1 #script will end here
#fi


# Generate timestamped zip filename
timestamp=$(date +%F-%H-%M)
zipfile="$destd/app-logs-$timestamp.zip"

# Find files older than $days
files_found=$(find "$sourced" -type f -name "*.log" -mtime +"$days")

if [ -z "$files_found" ]; then
    echo -e "No files to archive ... $Y SKIPPING $N"
    exit 1
fi

echo "Archiving the following files:"
echo "$files_found"


# Archive logs safely
if find "$sourced" -type f -name "*.log" -mtime +"$days" -print0| zip -@ -j "$zipfile"; then
    echo -e "Archival ... $G SUCCESS $N"

    # Delete original files safely
    find "$sourced" -type f -name "*.log" -mtime +"$days" -print0 | while IFS= read -r -d '' filepath; do
    rm -f "$filepath"
    done
    echo "All old logs archived and deleted successfully."

else
    echo -e "Archival ... $R FAILURE $N"
    # Remove incomplete zip file if it exists
    [ -f "$zipfile" ] && rm -f "$zipfile"
    echo -e "Removing incomplete Archival Files"
    exit 1
fi