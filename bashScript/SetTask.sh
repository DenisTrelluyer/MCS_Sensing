#!/bin/bash
#
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

echo "On"
echo $1
cat Task4State/$1_On | while read line || [[ -n $line ]];
do
   ID="$(bashScript/GetID.sh $line)" # do something with $line here
   echo $ID 	
   powershell -command ". ./nanoconsole/scripts/nano-mcs.ps1 && TS-ResumeTask -Sat testsat -ID $ID"
done
echo "Off"
echo $1
cat Task4State/$1_Off | while read line || [[ -n $line ]];
do
   ID="$(bashScript/GetID.sh $line)" # do something with $line here
   echo $ID 
   powershell -command ". ./nanoconsole/scripts/nano-mcs.ps1 && TS-PauseTask -Sat testsat -ID $ID"   
done