# NOME DA SUA GPU
$gpuName = "*RTX 4070*"

$managePowerSaver = $true

$battery = Get-WmiObject -Namespace root\wmi -Class BatteryStatus
$plugged = $battery.PowerOnline

$gpu = Get-PnpDevice -FriendlyName $gpuName -Class Display

if ($plugged -eq $false) {
    # MODO BATERIA
    if ($managePowerSaver) {
        # Liga economia de energia
        powercfg /setdcvalueindex SCHEME_CURRENT SUB_ENERGYSAVER ESBATTTHRESHOLD 100
        powercfg /setactive SCHEME_CURRENT
    }

    # Desativa GPU
    if ($gpu.Status -eq "OK") {
        Disable-PnpDevice -InstanceId $gpu.InstanceId -Confirm:$false
    }
} else {
    # MODO TOMADA
    if ($managePowerSaver) {
        # Desliga economia
        powercfg /setdcvalueindex SCHEME_CURRENT SUB_ENERGYSAVER ESBATTTHRESHOLD 20
        powercfg /setactive SCHEME_CURRENT
    }

    # Ativa GPU
    if ($gpu.Status -ne "OK") {
        Enable-PnpDevice -InstanceId $gpu.InstanceId -Confirm:$false
    }
}