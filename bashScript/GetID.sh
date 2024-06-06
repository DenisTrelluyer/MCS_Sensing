#!/bin/bash
#
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

if [[ ${#} -ne 1 ]]; then
	echo "Usage: $0 <state-name>"
	exit 01
fi
state_name=$1

powershell  -command ". ./nanoconsole/scripts/nano-mcs.ps1 && TS-ListTasks testsat -SortBy ID -Filter All"    | grep ${state_name}|  sed 's@^[^0-9]*\([0-9]\+\).*@\1@'
exit 0