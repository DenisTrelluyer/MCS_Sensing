#!/bin/bash
#
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

#Init Test, Set on des équipements nécessaires au test, positionnement de heure bord, ...
./nanoMCS -c 10.31.50.100 5000   --configfile MCSPlan.txt




# Set on des tasks Upload Ou passage normal
./SetTask.sh Upload_PC_FC_Script

cp *.txt /home/denis/MCS/mcs-bundle-3.0.3/onBoardScripts/

#Upload de plan 
powershell  -command ". ./nanoconsole/scripts/nano-mcs.ps1 &&TS-StartFlatsatSession -Sat testsat -CommType sband -Duration 8m -ID 1 "

#suppression des scripts pour eviter un upload non désiré
rm /home/denis/MCS/mcs-bundle-3.0.3/onBoardScripts/* # emplacement des fichiers à revoir



# value to be confirmed
sleep 180

#Passage standard
./SetTask.sh Normal_pass 

#Passage avec downlink image HKTM 
powershell  -command ". ./nanoconsole/scripts/nano-mcs.ps1 &&TS-StartFlatsatSession -Sat testsat -CommType sband -Duration 8m -ID 1 "
powershell  -command ". ./nanoconsole/scripts/nano-mcs.ps1 &&TS-StartFlatsatSession -Sat testsat -CommType xband -Duration 8m -ID 1 "

#Post test

