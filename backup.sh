#!/bin/bash

user=$(id -u) #user check

#colog codes
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

trap 'echo "There is error at Line:$LINENO and for commmand: $BASH_COMMAND"' ERR

sourced=$1 # first argument
destd=$2   # second argument
days=${3:-14} # if not provided considered as 14 days


logpath="/tmp/shell-script/backuplogs"
name=$( echo $0 | cut -d "." -f1 )
logfile="$logpath/$name.log" #/tmp/shell-script/backuplogs/backup.log

mkdir -p "$logpath"
echo "Script started executed at: $(date)" | tee -a $logfile    



dnf install zip -y &>>$logfile
if [ $? -ne 0 ]; then
    echo "Installing zip package is success" | tee -a $logfile
    else
    echo "Zip package is already exist"
fi


if [ "$user" -ne 0 ]; then
    echo "ERROR:: Please run this script with root privelege" | tee -a $logfile
    exit 1 # if user is not root. script will end here
fi


usage_instruction(){
    echo -e "$R USAGE:: sudo sh 24-backup.sh <SOURCE_DIR> <DEST_DIR> <DAYS>[optional, default 14 days] $N" | tee -a $logfile
    exit 1 #if 2 args are not passed. script will end here
}

### Check for Args passed ####
if [ $# -lt 2 ]; then
    usage_instruction
fi



# Ensure destination exists
mkdir -p "$destd"


### Check SOURCE_DIR Exist ####
if [ ! -d "$sourced" ]; then
    echo -e "$R Source $sourced does not exist $N" | tee -a $logfile
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
echo "Zipfile is available here: $zipfile"

# Find files older than $days
files_found=$(find "$sourced" -type f -name "*.log" -mtime +"$days")

if [ -z "$files_found" ]; then
    echo -e "No files to archive ... $Y SKIPPING $N" | tee -a $logfile
    exit 1
fi

echo "Archiving the following files:" | tee -a $logfile
echo "$files_found" | tee -a $logfile


# Archive logs safely
if find "$sourced" -type f -name "*.log" -mtime +"$days" -print0 | xargs -0 zip -j "$zipfile"; then
    echo -e "Archival ... $G SUCCESS $N"

    # Delete original files safely
    find "$sourced" -type f -name "*.log" -mtime +"$days" | while read -r filepath; do
    rm -f "$filepath"
    done

    echo "All old logs archived and deleted successfully." | tee -a $logfile
    echo "Zipfile is available here: $zipfile"
    
else
    echo -e "Archival ... $R FAILURE $N"
    # Remove incomplete zip file if it exists
    [ -f "$zipfile" ] && rm -f "$zipfile"
    echo -e "Removing incomplete Archival Files" | tee -a $logfile
    exit 1
fi