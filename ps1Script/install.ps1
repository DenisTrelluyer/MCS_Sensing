param(
    [string]$ConfigFile = "$PSscriptRoot/install-config.json"
)

$servicesFolder = "$PSScriptRoot/services"
$templatesFolder = "$PSScriptRoot/templates"
$nanoconsoleFolder = "$PSScriptRoot/nanoconsole"
$structsFolder = "$PSScriptRoot/telemetry-structs"
$imagesFolder = "$PSScriptRoot/images"

$config = Get-Content $ConfigFile -Raw | ConvertFrom-Json

# Insert missing values into .env file
(Get-Content "$servicesFolder/.env").
    replace('{{NAME}}', $config.satellite.name). `
    replace('{{IP}}', $config.satellite.ip). `
    replace('{{PORT}}', $config.satellite.port) |
    Set-Content "$servicesFolder/.env"

# Read .env file
$e = @{};
Get-Content "$servicesFolder/.env" | ForEach-Object {
    $name, $value = $_ -split '=', 2
    $e[$name] = $value
}

$nanoconsoleSatFolder = "$nanoconsoleFolder/sats/$($e['SAT_NAME'].ToLower())"

# Create MF config
(Get-Content "$templatesFolder/mcs-frontend.template.json").
    replace('${MF_USERNAME}', $e['MF_USERNAME']). `
    replace('${MF_PASS_HASH}', $e['MF_PASS_HASH']). `
    replace('${SAT_NAME}', $e['SAT_NAME']) |
    Set-Content "$servicesFolder/mcs-frontend/config.json"

# Create nanoconsole config
(Get-Content "$templatesFolder/nanoconsole.template.json"). `
	replace('${MF_PORT}', $e['MF_PORT']). `
	replace('${SAT_NAME}', $e['SAT_NAME'].ToLower()).`
	replace('${INFLUX_USER}', $e['INFLUX_USER']). `
	replace('${INFLUX_PASSWORD}', $e['INFLUX_PASSWORD']) |
	Set-Content "$nanoconsoleFolder/config.json"

# Create satellite config
$tmpSatConfig = (Get-Content "$templatesFolder/satellite.template.json"). `
    replace('${POSTGRES_USER}', $e['POSTGRES_USER']). `
    replace('${POSTGRES_PASSWORD}', $e['POSTGRES_PASSWORD']). `
    replace('${POSTGRES_DB}', $e['POSTGRES_DB']). `
    replace('${POSTGRES_SCHEMA}', $e['SAT_NAME']). `
    replace('${POSTGRES_PORT}', $e['POSTGRES_PORT']). `
    replace('${SAT_IP}', $e['SAT_IP']). `
    replace('${SAT_PORT}', $e['SAT_PORT']). `
    replace('${SAT_NAME}', $e['SAT_NAME']). `
    replace('${INFLUX_USER}', $e['INFLUX_USER']). `
    replace('${INFLUX_PASSWORD}', $e['INFLUX_PASSWORD']) |
    ConvertFrom-Json

# Create nano-shell.cmd
(Get-Content "$PSscriptRoot/nano-shell.cmd").
    replace('${MF_USERNAME}', $e['MF_USERNAME']). `
    replace('${MF_PASSWORD}', $e['MF_PASSWORD']) |
    Set-Content "$PSscriptRoot/nano-shell.cmd"

# Create satellite config folder
New-Item -Path $nanoconsoleSatFolder -ItemType Directory -Force | Out-Null

# Iterate over subsystems
$config.subsystems.PSObject.Properties | ForEach-Object {
    $subsystemName = $_.Name
    $subsystemConfig = $_.Value
    
    $tmpSatConfig.subsystems += @{
        name = $subsystemName
        csp = $subsystemConfig.cspId
    }
   
    # Create subsystem config folder
    $susbsystemPath = "$nanoconsoleSatFolder/subsystem.$subsystemName"
    New-Item -Path $susbsystemPath -ItemType Directory -Force | Out-Null
    New-Item -Path "$susbsystemPath/structs" -ItemType Directory -Force | Out-Null

    $tmpSubsystemConfig = @{
        files = @()
    }

    $subsystemConfig.files | ForEach-Object {
        if ($_.struct -ne $null){
            $tmpSubsystemConfig.files += @{
                id = $_.id
                name = $_.name
                structure = "structs\$($_.struct)"
            }
            Copy-Item "$structsFolder/$($_.struct)" "$susbsystemPath/structs/$($_.struct)" -Force
        }elseif($_.protocol -ne $null){
            Copy-Item "$structsFolder/$($_.protocol)" "$susbsystemPath/structs/$($_.protocol)" -Force
        }
    }

    $tmpSubsystemConfig | ConvertTo-Json -Depth 100 | Set-Content "$susbsystemPath/subsystem.json"
}

Get-ChildItem $imagesFolder -Filter *.docker | ForEach-Object {
    $imageName = $_.Name -replace '.docker', ''
    $imagePath = $_.FullName

    Write-Host "Importing docker image $imageName"

    & docker load -i $imagePath
}

$tmpSatConfig | ConvertTo-Json -Depth 100 | Set-Content "$nanoconsoleSatFolder/sat.json"

& docker compose -p mcs-bundle --project-directory "$PSScriptRoot/services" up -d

$env:NANOCONSOLE_CONFIG_PATH = "$nanoconsoleFolder/config.json"
$env:NANOCONSOLE_SAT_FOLDER_PATH = "$nanoconsoleFolder/sats"

$env:NANO_CRED_USER = $e['MF_USERNAME']
$env:NANO_CRED_PASS = $e['MF_PASSWORD']

. "$nanoconsoleFolder/scripts/nano-mcs.ps1"
