#!/bin/bash
#
# AUTHOR: Marek Bubeník
# DATE: 2025-06-13
# ABOUT: Look for related executables based on a provided name, lists related libraries and their packages 
# USAGE: ./exec_get_info.sh <package> | tee mylogfile.log
# NOTE: You don't have to tee to log file it makes easier to go through, because of the amount of logs being displayed
#
#

master=$1

mapfile -t libs < <( for i in $(find / -maxdepth 5 -type f -executable -name "*$master*"); do ldd $i 2>/dev/null; done | cut -f1 -d " " | awk '{$1=$1};1' | sort | uniq )
mapfile -t pkg_pre < <( for i in ${libs[@]}; do dpkg -S $i 2>/dev/null | cut -f1 -d ":" | uniq; done)

echo "#########################"
echo ">>> $master"
echo "#########################"

echo ">> Libraries"
for i in ${libs[@]}; do
	echo $i
done
echo ""

echo ">> Common packages for libraries"
for j in "${pkg_pre[@]}";do 
	echo $j; 
done | sort | uniq
echo ""

