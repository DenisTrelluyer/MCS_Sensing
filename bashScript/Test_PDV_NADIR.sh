#!/bin/bash
#
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes


# Set off de toutes les taches
./SetTask.sh Init

# Creation de la tache de mise on PC A voir si on inclus pas la tache dans les taches génériques
powershell  -command ". ./nanoconsole/scripts/nano-mcs.ps1 && TS-NewNanoMcsTask -Sat testsat -CommType sband -ScriptFile script/InitTest.txt | TS-AddTask -Name InitTest -Priority 100" 

# Creation de la tache de mise on FC A voir si on inclus pas la tache dans les taches génériques
powershell  -command ". ./nanoconsole/scripts/nano-mcs.ps1 && TS-NewNanoMcsTask -Sat testsat -CommType sband -ScriptFile script/InitTest.txt | TS-AddTask -Name InitTest -Priority 100" 

# Execution de la mise on PC/FC + payload
powershell  -command ". ./nanoconsole/scripts/nano-mcs.ps1 &&TS-StartFlatsatSession -Sat testsat -CommType sband -Duration 1m -ID 1 "

# Set on des tasks Upload Ou passage normal
./SetTask.sh Upload_PC_FC_Script

#Upload de plan 
powershell  -command ". ./nanoconsole/scripts/nano-mcs.ps1 &&TS-StartFlatsatSession -Sat testsat -CommType sband -Duration 8m -ID 1 "

#suppression des scripts pour eviter un upload non désiré
rm /home/denis/MCS/mcs-bundle-3.0.3/onBoardScripts/*

# value to be confirmed
sleep 180

#Passage avec downlink image HKTM 
powershell  -command ". ./nanoconsole/scripts/nano-mcs.ps1 &&TS-StartFlatsatSession -Sat testsat -CommType sband -Duration 8m -ID 1 "

#Post test

