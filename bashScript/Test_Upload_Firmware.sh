#!/bin/bash
#
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes


# Set off de toutes les taches
./SetTask.sh Init

# Creation de la tache de mise on PC A voir si on inclus pas la tache dans les taches génériques
powershell  -command ". ./nanoconsole/scripts/nano-mcs.ps1 && TS-NewNanoMcsTask -Sat testsat -CommType sband -ScriptFile script/InitTest.txt | TS-AddTask -Name InitTest -Priority 100" 

# Execution de la mise on PC
powershell  -command ". ./nanoconsole/scripts/nano-mcs.ps1 &&TS-StartFlatsatSession -Sat testsat -CommType sband -Duration 1m -ID 1 "

# Set on des tasks Upload
./SetTask.sh UploadFirmware

# boucle d'upload
while true ; do

	return = powershell  -command ". ./nanoconsole/scripts/nano-mcs.ps1 &&TS-StartFlatsatSession -Sat testsat -CommType sband -Duration 8m -ID 1 "
	sleep 60
	echo $return

	if ($return -ne 0) then;
		break
	fi

done

#Post test

