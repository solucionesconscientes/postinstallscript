# Comprobar si se ejecuta como administrador y forzar elevación si no
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Inicializar variables
$startTime = Get-Date
$installedApps = @()

# Definir las opciones del menú (aplicaciones disponibles en Chocolatey y compatibles con Windows)
$options = @(
    @{ID=0; Name="Instalar Chocolatey (si no está instalado)"; Command="Set-ExecutionPolicy Bypass -Scope CurrentUser -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"; Enabled=$true},
    @{ID=1; Name="Actualizar Chocolatey"; Command="choco upgrade chocolatey -y"; Enabled=$false},
    @{ID=2; Name="Navegadores: LibreWolf"; Command="choco install librewolf -y"; Enabled=$false},
    @{ID=3; Name="Navegadores: Brave"; Command="choco install brave -y"; Enabled=$true},
    @{ID=4; Name="Navegadores: Firefox"; Command="choco install firefox -y"; Enabled=$false},
    @{ID=5; Name="Navegadores: Chromium"; Command="choco install chromium -y"; Enabled=$false},
    @{ID=6; Name="Navegadores: Google Chrome"; Command="choco install googlechrome -y"; Enabled=$true},
    @{ID=7; Name="Navegadores: Microsoft Edge"; Command="choco install microsoft-edge -y"; Enabled=$false},
    @{ID=8; Name="Ofimática: OnlyOffice"; Command="choco install onlyoffice -y"; Enabled=$true},
    @{ID=9; Name="Ofimática: LibreOffice"; Command="choco install libreoffice-fresh -y"; Enabled=$false},
    @{ID=10; Name="Ofimática: WPS Office"; Command="choco install wpsoffice -y"; Enabled=$false},
    @{ID=11; Name="Ofimática: Notepad++"; Command="choco install notepadplusplus -y"; Enabled=$true},
    @{ID=12; Name="Multimedia: VLC"; Command="choco install vlc -y"; Enabled=$true},
    @{ID=13; Name="Multimedia: SMPlayer"; Command="choco install smplayer -y"; Enabled=$false},
    @{ID=14; Name="Multimedia: Kdenlive"; Command="choco install kdenlive -y"; Enabled=$false},
    @{ID=15; Name="Multimedia: Strawberry"; Command="choco install strawberry -y"; Enabled=$false},
    @{ID=16; Name="Multimedia: Audacity"; Command="choco install audacity -y"; Enabled=$false},
    @{ID=17; Name="Multimedia: Handbrake"; Command="choco install handbrake -y"; Enabled=$false},
    @{ID=18; Name="Multimedia: Spotify"; Command="choco install spotify -y"; Enabled=$true},
    @{ID=19; Name="Multimedia: OBS Studio"; Command="choco install obs-studio -y"; Enabled=$false},
    @{ID=20; Name="Edición de Imágenes: Krita"; Command="choco install krita -y"; Enabled=$false},
    @{ID=21; Name="Edición de Imágenes: GIMP"; Command="choco install gimp -y"; Enabled=$false},
    @{ID=22; Name="Edición de Imágenes: DigiKam"; Command="choco install digikam -y"; Enabled=$false},
    @{ID=23; Name="Edición de Imágenes: Paint.NET"; Command="choco install paint.net -y"; Enabled=$false},
    @{ID=24; Name="PDF y OCR: Master PDF Editor"; Command="choco install masterpdfeditor -y"; Enabled=$false},
    @{ID=25; Name="PDF y OCR: Adobe Acrobat Reader DC"; Command="choco install adobereader -y"; Enabled=$true},
    @{ID=26; Name="PDF y OCR: SumatraPDF"; Command="choco install sumatrapdf -y"; Enabled=$false},
    @{ID=27; Name="Utilidades: qBittorrent"; Command="choco install qbittorrent -y"; Enabled=$false},
    @{ID=28; Name="Utilidades: Localsend"; Command="choco install localsend -y"; Enabled=$true},
    @{ID=29; Name="Utilidades: VokoscreenNG"; Command="choco install vokoscreen-ng -y"; Enabled=$false},
    @{ID=30; Name="Utilidades: FileZilla"; Command="choco install filezilla -y"; Enabled=$false},
    @{ID=31; Name="Utilidades: FreeFileSync"; Command="choco install freefilesync -y"; Enabled=$false},
    @{ID=32; Name="Utilidades: JDownloader"; Command="choco install jdownloader -y"; Enabled=$true},
    @{ID=33; Name="Utilidades: Czkawka"; Command="choco install czkawka -y"; Enabled=$false},
    @{ID=34; Name="Utilidades: BleachBit"; Command="choco install bleachbit -y"; Enabled=$true},
    @{ID=35; Name="Utilidades: Fastfetch"; Command="choco install fastfetch -y"; Enabled=$true},
    @{ID=36; Name="Utilidades: Kshutdown"; Command="choco install kshutdown -y"; Enabled=$true},
    @{ID=37; Name="Utilidades: 360 Total Security"; Command="choco install 360ts -y"; Enabled=$false},
    @{ID=38; Name="Utilidades: PeaZip"; Command="choco install peazip -y"; Enabled=$false},
    @{ID=39; Name="Utilidades: 7-Zip"; Command="choco install 7zip -y"; Enabled=$false},
    @{ID=40; Name="Utilidades: K-Lite Codec Pack Mega"; Command="choco install k-lite-codec-pack-mega -y"; Enabled=$false},
    @{ID=41; Name="Utilidades: Snappy Driver Installer"; Command="choco install snappy-driver-installer-origin -y"; Enabled=$false},
    @{ID=42; Name="Utilidades: Transmission"; Command="choco install transmission -y"; Enabled=$false},
    @{ID=43; Name="Utilidades: Deluge"; Command="choco install deluge -y"; Enabled=$false},
    @{ID=44; Name="Utilidades: Discord"; Command="choco install discord -y"; Enabled=$true},
    @{ID=45; Name="Utilidades: Git"; Command="choco install git -y"; Enabled=$false},
    @{ID=46; Name="Utilidades: VS Code"; Command="choco install vscode -y"; Enabled=$true},
    @{ID=47; Name="Utilidades: Telegram"; Command="choco install telegram -y"; Enabled=$true},
    @{ID=48; Name="Utilidades: WhatsApp"; Command="choco install whatsapp -y"; Enabled=$true},
    @{ID=49; Name="Apagar el equipo"; Command="Stop-Computer -Force"; Enabled=$false}
)

# Verificar si Chocolatey está instalado y ajustar la primera opción
if (Get-Command choco -ErrorAction SilentlyContinue) {
    $options[0].Name = "Chocolatey ya está instalado (omitir)"
    $options[0].Command = "Write-Host 'Chocolatey ya está instalado.'"
    $options[0].Enabled = $false
}

# Crear un formulario básico para selección múltiple (usando Out-GridView)
$selectedOptions = $options |
    Select-Object @{Name="ID"; Expression={$_.ID}},
                  @{Name="Name"; Expression={$_.Name}},
                  @{Name="Selected"; Expression={$_.Enabled}} |
    Out-GridView -Title "Selecciona las aplicaciones que deseas instalar" -PassThru

# Verificar si se canceló la selección
if (-not $selectedOptions) {
    Write-Host "Instalación cancelada por el usuario."
    exit 1
}

# Filtrar las opciones seleccionadas
$selectedIds = $selectedOptions | Where-Object { $_.Selected } | Select-Object -ExpandProperty ID

# Verificar si no se seleccionó nada
if ($selectedIds.Count -eq 0) {
    Write-Host "No se seleccionaron opciones."
    exit 1
}

# Ejecutar las instalaciones seleccionadas
foreach ($id in $selectedIds) {
    $option = $options | Where-Object { $_.ID -eq $id }
    if ($option) {
        Write-Host "Ejecutando: $($option.Name)"
        Invoke-Expression $option.Command
        $installedApps += $option.Name
    } else {
        Write-Host "Opción no reconocida: $id"
    }
}

# Calcular tiempo de ejecución
$endTime = Get-Date
$executionTime = $endTime - $startTime

# Mostrar resultados
Write-Host "Tiempo total de ejecución: $($executionTime.TotalMinutes.ToString("F2")) minutos."
Write-Host "Aplicaciones instaladas: $($installedApps -join ', ')"
Write-Host "La instalación ha finalizado."

# Mantener la ventana abierta hasta que el usuario presione una tecla
Write-Host "Presiona cualquier tecla para cerrar..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
exit 0
