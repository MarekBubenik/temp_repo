#!/bin/bash
# AUTHOR: Marek Bubeník
# DATE: 2025-06-13
# ABOUT: Retrieve info about a package; dependencies, if other packages on a system are dependent on it, logs
# USAGE: ./pkg_get_info.sh <package> | tee mylogfile.log
# NOTE: You don't have to tee to log file it makes easier to go through, because of the amount of logs being displayed
#
#

pkg=$1
#user=$2
finddep=$(apt-cache depends $pkg | grep -E "Depends:|Recommends:" | awk '{print $2}')

man_or_dep() {
	pkgstate=$(apt list --installed 2>/dev/null | grep ^$1)
	pkgstate_dep=$(grep automatic <<< "$pkgstate")
	pkgstate_local=$(grep local <<< "$pkgstate")

	if [[ -z "${pkgstate}" ]]; then
		echo "Package: $1 - has not been installed yet."
	elif [[ ${pkgstate_dep} ]]; then
		echo "Package: $1 - has been installed as a dependency."
		echo $pkgstate
	elif [[ ${pkgstate_local} ]]; then 
		echo "Package: $1 - has been installed as a separate package."
		echo $pkgstate
	else
		echo "Package: $1 - has been installed manually."
		echo $pkgstate
	fi
}


dpkg_fun() {
	grep -E 'install |remove ' /var/log/dpkg.log* | sort | cut -f1,2,3,4 -d' ' | grep $1
}

auth_fun() {
	grep -E "$1" /var/log/auth.log
}

ausearch_fun() {
	mapfile -t auvar < <( grep "$1" /var/log/audit/audit.log | sed -n 's/.*(\(.*\)).*/\1/p' | cut -f2 -d ':' )
        if [[ ! -z ${auvar} ]]; then
                for msgid in ${auvar[@]}; do
                        ausearch --event "$msgid" --comm apt 2>/dev/null
                done
        fi
}

ausearch_autoremove_fun() {
        mapfile -t auvar < <( grep "autoremove" /var/log/audit/audit.log | sed -n 's/.*(\(.*\)).*/\1/p' | cut -f2 -d ':' )
        if [[ ! -z ${auvar} ]]; then
                for msgid in ${auvar[@]}; do
                        ausearch --event "$msgid" --comm apt 2>/dev/null
                done
        fi
}

is_apt() {
	apt list --installed 2>/dev/null | grep $pkg | echo $?
}

echo -e "==============================="
echo -e "===== Installation method ====="
echo -e "==============================="

man_or_dep $pkg
echo ""

echo -e "============================================="
echo -e "===== List dependencies of this package ====="
echo -e "============================================="

apt-cache depends $pkg 2>/dev/null
echo ""

echo -e "====================================================================="
echo -e "===== List packages that depends on this package on this system ====="
echo -e "====================================================================="

apt-cache rdepends --installed $pkg 2>/dev/null
echo ""

echo -e "=============================="
echo -e "===== APT logs - package ====="
echo -e "=============================="

echo ">>> $pkg"

echo -e "### dpkg.log ###"
dpkg_fun "$pkg"

echo -e "### auth.log ###"
auth_fun "$pkg"

echo -e "### audit.log ###"
ausearch_fun "$pkg"

echo -e "==================================="
echo -e "===== APT logs - dependencies ====="
echo -e "==================================="

for package in $finddep; do
	
	echo ">>> $package"
	
	echo -e "### dpkg.log ###" 
	dpkg_fun "$package"

	echo -e "### auth.log ###"
	auth_fun "$package"

	echo -e "### audit.log ###"
	ausearch_fun "$package"
	echo -e ""
done

echo -e "====================================="
echo -e "===== autoremove - dependencies ====="
echo -e "====================================="

ausearch_autoremove_fun
echo -e ""

