# --- VARIÁVEIS PRINCIPAIS ---
# NOME DA SUA GPU
$gpuName = "*RTX 4070*"

$managePowerSaver = $true

# --- LEITURA DO HARDWARE ---
$battery = Get-WmiObject -Namespace root\wmi -Class BatteryStatus
$plugged = $battery.PowerOnline

$currentSSID = (netsh wlan show interfaces | Select-String -Pattern '\s+SSID\s+:\s+(.*)$' | ForEach-Object { $_.Matches.Groups[1].Value.Trim() })

$gpu = Get-PnpDevice -FriendlyName $gpuName -Class Display -ErrorAction SilentlyContinue

# Verifica se há monitores externos conectados
$monitors = @(Get-PnpDevice -Class Monitor -Status OK -ErrorAction SilentlyContinue)
$externalDisplayConnected = $monitors.Count -gt 1

# --- Modo Bateria  ---
if ($plugged -eq $false) {

    if ($managePowerSaver) {
        # Liga limite padrão de economia de energia
        powercfg /setdcvalueindex SCHEME_CURRENT SUB_ENERGYSAVER ESBATTTHRESHOLD 100
        
        # Força uso intenso dos LP E-Cores
        powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFEPP 80
        
        # Wifi em modo Maximum Power Saving
        powercfg /setdcvalueindex SCHEME_CURRENT 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 3

        # PCIe ASPM para Economia de Energia
        powercfg /setdcvalueindex SCHEME_CURRENT 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a558def 2
        
        # Aplica as regras de energia
        powercfg /setactive SCHEME_CURRENT

        # Derruba o MSI Afterburner
        Stop-Process -Name "MSIAfterburner" -Force -ErrorAction SilentlyContinue

        # Desativa o Windows Update
        Stop-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
        Set-Service -Name "wuauserv" -StartupType Disabled -ErrorAction SilentlyContinue

        # Define a rede WiFi atual como Conexão Limitada (Corta tráfego em segundo plano)
        if ($currentSSID) {
            netsh wlan set profileparameter name="$currentSSID" cost=Fixed | Out-Null
        }
    }

    # Desativa GPU
    if ($gpu -and $gpu.Status -eq "OK" -and -not $externalDisplayConnected) {
        Disable-PnpDevice -InstanceId $gpu.InstanceId -Confirm:$false
    }

# --- Modo Tomada ---
} else {

    if ($managePowerSaver) {
        # Desliga limite de economia de energia
        powercfg /setacvalueindex SCHEME_CURRENT SUB_ENERGYSAVER ESBATTTHRESHOLD 20
        
        # Restaura para modo de desempenho 
        powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFEPP 33
        
        # Wifi Maximum Performance
        powercfg /setacvalueindex SCHEME_CURRENT 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 0

        # PCIe ASPM para Desempenho Máximo
        powercfg /setacvalueindex SCHEME_CURRENT 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a558def 0
        
        # Aplica as regras de energia
        powercfg /setactive SCHEME_CURRENT
    
        # Inicia o MSI Afterburner novamente
        $afterburnerPath = "C:\Program Files (x86)\MSI Afterburner\MSIAfterburner.exe"
        if (Test-Path $afterburnerPath) {
            Start-Process -FilePath $afterburnerPath -WindowStyle Minimized
        }

        # Ativa o Windows Update
        Set-Service -Name "wuauserv" -StartupType Manual -ErrorAction SilentlyContinue
        Start-Service -Name "wuauserv" -ErrorAction SilentlyContinue

        # Retorna a rede Wifi, desativando o modo Conexão Limitada
        if ($currentSSID) {
            netsh wlan set profileparameter name="$currentSSID" cost=Unrestricted | Out-Null
        }
    }

    # Ativa GPU
    if ($gpu -and $gpu.Status -ne "OK") {
        Enable-PnpDevice -InstanceId $gpu.InstanceId -Confirm:$false
    }
}