#!/bin/bash
#
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

if [[ ${#} -ne 1 ]]; then
	echo "Usage: $0 <mcs_repo>"
	exit 01
fi
mcs_repo=$1

ln -s ../mcs-sensing/Task4State ../$mcs_repo/Task4State 
ln -s ../mcs-sensing/bashScript ../$mcs_repo/bashScript 
ln -s ../mcs-sensing/onBoardScript ../$mcs_repo/onBoardScript 
ln -s ../mcs-sensing/ps1Script ../$mcs_repo/ps1Script 

exit 0
