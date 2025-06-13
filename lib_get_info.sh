#!/bin/bash
# AUTHOR: Marek Bubeník
# DATE: 2025-06-13
# ABOUT: Retrieve info about a library, lists other related libraries anrelated packages
# USAGE: ./lib_get_info.sh <package>
#
#

master=$1

fullpath=$(ldconfig -p | grep $1 | tr ' ' '\n' | grep /)
mapfile -t libs < <(ldd $fullpath 2>/dev/null| cut -f1 -d " " | awk '{$1=$1};1' | sort | uniq)
mapfile -t pkgs < <(dpkg -S $libs 2>/dev/null | cut -f1 -d ":" | sort | uniq)

echo ">> libs"
for i in ${libs[@]}; do
	echo $i
done
echo ""

echo ">> packages"
for j in ${pkgs[@]}; do
	echo $j
done
echo ""
