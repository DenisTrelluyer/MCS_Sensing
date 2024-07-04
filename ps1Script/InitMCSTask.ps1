# . ./nanoconsole/scripts/nano-mcs.ps1
 #Ping eps
 TS-NewNanoMcsTask -Sat testsat -CommType sband -ScriptFile onBoardScript/PingEPS.txt | TS-AddTask -Name pingEPS -Priority 100 -DurationRelative 0.1 -Repeat
 # Stop script on FC
TS-NewNanoMcsTask -Sat testsat -CommType sband -ScriptFile onBoardScript/StopFCScripts.txt | TS-AddTask -Name StopFCScripts -Priority 10 -DurationRelative 0.1 -Repeat
 # Start script on FC
TS-NewNanoMcsTask -Sat testsat -CommType sband -ScriptFile onBoardScript/StartFCScripts.txt | TS-AddTask -Name StartFCScripts -Priority 10 -DurationRelative 0.1 -Repeat

#download EPS telemetry
TS-NewFileDownloadTask -Sat testsat -CommType sband -Subsystem 4 -File 10 | TS-AddTask -Name downloadEPS -Priority 20 -DurationRelative 0.1 -Repeat

#download FC telemetry
TS-NewFileDownloadTask -Sat testsat -CommType sband -Subsystem 3 -File 3 | TS-AddTask -Name downloadFC -Priority 20 -DurationRelative 0.1 -Repeat
#download AOCS telemetry
TS-NewFileDownloadTask -Sat testsat -CommType sband -Subsystem 3 -File 6 | TS-AddTask -Name downloadAOCS -Priority 20 -DurationRelative 0.1 -Repeat

#download Script logs
TS-NewFileDownloadTask -Sat testsat -CommType sband -Subsystem 3 -File 14 | TS-AddTask -Name downloadScript1 -Priority 20 -DurationRelative 0.1 -Repeat
TS-NewFileDownloadTask -Sat testsat -CommType sband -Subsystem 3 -File 15 | TS-AddTask -Name downloadScript2 -Priority 20 -DurationRelative 0.1 -Repeat

#StartFBX
TS-NewNanoMcsTask -Sat testsat -CommType sband -ScriptFile onBoardScript/StartFBX.txt | TS-AddTask -Name StartFBX -Priority 10 -DurationRelative 0.1 -Repeat

#StartPayload
TS-NewNanoMcsTask -Sat testsat -CommType sband -ScriptFile onBoardScript/StartPayload.txt | TS-AddTask -Name StartPayload -Priority 10 -DurationRelative 0.1 -Repeat

#Upload PC plan
TS-NewFileUploadTask -Sat testsat -CommType sband  -Subsystem 3 -File 9 -FilePath onBoardScript/PCPlan.txt | TS-AddTask -Name UploadPCPlan -Priority 20 -DurationRelative 0.1 -Repeat
#Upload FC plan
TS-NewFileUploadTask -Sat testsat -CommType sband  -Subsystem 3 -File 10 -FilePath onBoardScript/FCPlan.txt | TS-AddTask -Name UploadFCPlan -Priority 20 -DurationRelative 0.1 -Repeat


# Restore link on PC
TS-NewNanoMcsTask -Sat testsat -CommType sband -ScriptFile onBoardScript/RestoreLink.txt | TS-AddTask -Name RestorePClinks -Priority 99 -DurationRelative 0.05 -Repeat
#Upload firmware
TS-NewFileUploadTask -Sat testsat -CommType sband  -Subsystem 5 -File 17 -FilePath firmware/image.bin | TS-AddTask -Name UploadFirmware -Priority 98 -DurationRelative 0.9 -Repeat
# Get file information on Upload
TS-NewNanoMcsTask -Sat testsat -CommType sband -ScriptFile onBoardScript/GetUploadInfo.txt | TS-AddTask -Name GetUploadInfo -Priority 10 -DurationRelative 0.1 -Repeat


#download Image telemetry
TS-NewFileDownloadTask -Sat testsat -CommType xband -Subsystem 5 -File  25 | TS-AddTask -Name PC_download_Image -Priority 20 -DurationRelative 1 -Repeat