#!/bin/bash

echo "Files older than 14 days"
find . -name "*.log" -type f -mtime +14
