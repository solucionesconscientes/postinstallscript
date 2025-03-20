Write-Host "Iniciando script..." -ForegroundColor Green
Start-Sleep -Seconds 2

# Verificar y ajustar la directiva de ejecución solo para esta sesión
$currentPolicy = Get-ExecutionPolicy -Scope Process
if ($currentPolicy -eq "Restricted" -or $currentPolicy -eq "AllSigned") {
    Write-Host "La directiva de ejecución actual ($currentPolicy) no permite ejecutar scripts." -ForegroundColor Yellow
    Write-Host "Solicitando permiso para cambiarla a 'Bypass' solo para esta sesión..." -ForegroundColor Yellow
    $response = Read-Host " ¿Permitir ejecución de scripts en esta sesión? (S/N)"
    if ($response -eq "S" -or $response -eq "s") {
        try {
            Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
            Write-Host "Directiva cambiada a 'Bypass' para esta sesión. Continuando..." -ForegroundColor Green
            Start-Sleep -Seconds 1
        } catch {
            Write-Host "Error al cambiar la directiva: $_" -ForegroundColor Red
            Write-Host "No se puede continuar. Cierra y ejecuta como administrador si es necesario." -ForegroundColor Red
            pause
            exit 1
        }
    } else {
        Write-Host "Permiso denegado. El script no puede ejecutarse sin cambiar la directiva." -ForegroundColor Red
        pause
        exit 1
    }
} else {
    Write-Host "Directiva de ejecución compatible detectada ($currentPolicy). Continuando..." -ForegroundColor Green
    Start-Sleep -Seconds 1
}

# Verificar permisos administrativos
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Este script requiere permisos administrativos." -ForegroundColor Yellow
    Write-Host "Intentando ejecutarlo como administrador..." -ForegroundColor Yellow
    Start-Sleep -Seconds 1
    try {
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -ErrorAction Stop
        Write-Host "Solicitud enviada. Si no ves otra ventana, revisa permisos o UAC." -ForegroundColor Yellow
        Start-Sleep -Seconds 3
        exit 0
    } catch {
        Write-Host "Error al intentar ejecutar como administrador: $_" -ForegroundColor Red
        Write-Host "Posibles causas: UAC deshabilitado, permisos insuficientes o ejecución bloqueada." -ForegroundColor Red
        Write-Host "Instrucciones:" -ForegroundColor Yellow
        Write-Host "1. Abre PowerShell como administrador (Win + X > 'Windows PowerShell (Administrador)')." -ForegroundColor Yellow
        Write-Host "2. cd C:\Users\hola\Downloads" -ForegroundColor Yellow
        Write-Host "3. .\script8.ps1" -ForegroundColor Yellow
        pause
        exit 1
    }
}

Write-Host "Ejecutando como administrador. Continuando..." -ForegroundColor Green
Start-Sleep -Seconds 1

$startTime = Get-Date
$installedApps = @()

$options = @(
    # Gestión de Chocolatey
    @{ID=0; Name="Instalar Chocolatey"; Command="Set-ExecutionPolicy Bypass -Scope CurrentUser -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"; Enabled=$true},
    @{ID=1; Name="Actualizar Chocolatey"; Command="choco upgrade chocolatey -y"; Enabled=$false},
    @{ID=2; Name="Instalar Chocolatey GUI"; Command="choco install chocolateygui -y"; Enabled=$true},

    # Navegadores
    @{ID=3; Name="Navegadores: Brave"; Command="choco install brave -y"; Enabled=$true},
    @{ID=4; Name="Navegadores: LibreWolf"; Command="choco install librewolf -y"; Enabled=$false},
    @{ID=5; Name="Navegadores: Firefox"; Command="choco install firefox -y"; Enabled=$false},
    @{ID=6; Name="Navegadores: Chromium"; Command="choco install chromium -y"; Enabled=$false},
    @{ID=7; Name="Navegadores: Google Chrome"; Command="choco install googlechrome -y"; Enabled=$false},
    @{ID=8; Name="Navegadores: Microsoft Edge"; Command="choco install microsoft-edge -y"; Enabled=$false},

    # Ofimática
    @{ID=9; Name="Ofimática: OnlyOffice"; Command="choco install onlyoffice -y"; Enabled=$true},
    @{ID=10; Name="Ofimática: LibreOffice"; Command="choco install libreoffice-fresh -y"; Enabled=$false},
    @{ID=11; Name="Ofimática: WPS Office"; Command="choco install wpsoffice -y"; Enabled=$false},
    @{ID=12; Name="Ofimática: Notepad++"; Command="choco install notepadplusplus -y"; Enabled=$false},

    # Multimedia - Reproductores
    @{ID=13; Name="Multimedia: VLC"; Command="choco install vlc -y"; Enabled=$true},
    @{ID=14; Name="Multimedia: SMPlayer"; Command="choco install smplayer -y"; Enabled=$true},
    @{ID=15; Name="Multimedia: Spotify"; Command="choco install spotify -y"; Enabled=$false},

    # Multimedia - Edición y Conversión
    @{ID=16; Name="Multimedia: Audacity"; Command="choco install audacity -y"; Enabled=$false},
    @{ID=17; Name="Multimedia: Kdenlive"; Command="choco install kdenlive -y"; Enabled=$false},
    @{ID=18; Name="Multimedia: Handbrake"; Command="choco install handbrake -y"; Enabled=$false},
    @{ID=19; Name="Multimedia: OBS Studio"; Command="choco install obs-studio -y"; Enabled=$false},
    @{ID=20; Name="Multimedia: freac"; Command="choco install freac -y"; Enabled=$false},

    # Multimedia - Códecs
    @{ID=21; Name="Multimedia: ffdshow (Códecs de Video)"; Command="choco install ffdshow -y"; Enabled=$true},
    @{ID=22; Name="Multimedia: ffmpeg (Códecs de Video)"; Command="choco install ffmpeg -y"; Enabled=$true},
    @{ID=23; Name="Multimedia: K-Lite Codec Pack Mega"; Command="choco install k-lite-codec-pack-mega -y"; Enabled=$false},

    # Edición de Imágenes
    @{ID=24; Name="Edición de Imágenes: Krita"; Command="choco install krita -y"; Enabled=$false},
    @{ID=25; Name="Edición de Imágenes: GIMP"; Command="choco install gimp -y"; Enabled=$false},
    @{ID=26; Name="Edición de Imágenes: DigiKam"; Command="choco install digikam -y"; Enabled=$false},

    # PDF y OCR
    @{ID=27; Name="PDF y OCR: Adobe Acrobat Reader DC"; Command="choco install adobereader -y"; Enabled=$false},
    @{ID=28; Name="PDF y OCR: SumatraPDF"; Command="choco install sumatrapdf -y"; Enabled=$false},
    @{ID=29; Name="PDF y OCR: Master PDF Editor"; Command="choco install masterpdfeditor -y"; Enabled=$false},
    @{ID=30; Name="PDF y OCR: Okular"; Command="choco install okular -y"; Enabled=$true},

    # Compresión y Archivos
    @{ID=31; Name="Compresión: 7-Zip"; Command="choco install 7zip -y"; Enabled=$true},
    @{ID=32; Name="Compresión: PeaZip"; Command="choco install peazip -y"; Enabled=$false},

    # Descargas y Torrents
    @{ID=33; Name="Descargas: qBittorrent"; Command="choco install qbittorrent -y"; Enabled=$false},
    @{ID=34; Name="Descargas: Transmission"; Command="choco install transmission -y"; Enabled=$false},
    @{ID=35; Name="Descargas: Deluge"; Command="choco install deluge -y"; Enabled=$false},
    @{ID=36; Name="Descargas: JDownloader"; Command="choco install jdownloader -y"; Enabled=$false},

    # Comunicación
    @{ID=37; Name="Comunicación: Discord"; Command="choco install discord -y"; Enabled=$false},
    @{ID=38; Name="Comunicación: Telegram"; Command="choco install telegram -y"; Enabled=$false},
    @{ID=39; Name="Comunicación: WhatsApp"; Command="choco install whatsapp -y"; Enabled=$false},
    @{ID=40; Name="Comunicación: Zoom"; Command="choco install zoom -y"; Enabled=$false},

    # Utilidades del Sistema
    @{ID=41; Name="Utilidades: FileZilla"; Command="choco install filezilla -y"; Enabled=$false},
    @{ID=42; Name="Utilidades: FreeFileSync"; Command="choco install freefilesync -y"; Enabled=$false},
    @{ID=43; Name="Utilidades: Localsend"; Command="choco install localsend -y"; Enabled=$false},
    @{ID=44; Name="Utilidades: VokoscreenNG"; Command="choco install vokoscreen-ng -y"; Enabled=$false},
    @{ID=45; Name="Utilidades: BleachBit"; Command="choco install bleachbit -y"; Enabled=$false},
    @{ID=46; Name="Utilidades: Czkawka"; Command="choco install czkawka -y"; Enabled=$false},
    @{ID=47; Name="Utilidades: Fastfetch"; Command="choco install fastfetch -y"; Enabled=$false},
    @{ID=48; Name="Utilidades: Kshutdown"; Command="choco install kshutdown -y"; Enabled=$false},
    @{ID=49; Name="Utilidades: 360 Total Security"; Command="choco install 360ts -y"; Enabled=$false},
    @{ID=50; Name="Utilidades: Snappy Driver Installer"; Command="choco install snappy-driver-installer-origin -y"; Enabled=$false},
    @{ID=51; Name="Utilidades: Google Earth"; Command="choco install googleearth -y"; Enabled=$false},

    # Desarrollo
    @{ID=52; Name="Desarrollo: Git"; Command="choco install git -y"; Enabled=$false},
    @{ID=53; Name="Desarrollo: VS Code"; Command="choco install vscode -y"; Enabled=$false},

    # Apagar
    @{ID=54; Name="Apagar el equipo"; Command="Stop-Computer -Force"; Enabled=$false}
)

function Show-Menu {
    Clear-Host
    Write-Host "Selecciona los programas a instalar (Flechas: mover, Espacio: seleccionar, Enter: continuar):" -ForegroundColor Cyan
    Write-Host "---------------------------------------------------"
    for ($i = 0; $i -lt $options.Length; $i++) {
        $status = if ($options[$i].Enabled) { "[X]" } else { "[ ]" }
        Write-Host "  $status $($options[$i].Name)" -ForegroundColor White
    }
    Write-Host "---------------------------------------------------"
}

function Update-Menu {
    param ($selectedIndex, $previousIndex)
    $baseY = 2  # Posición Y donde empieza la lista (después del título y la línea)
    
    # Actualizar la línea anterior (quitar resaltado)
    if ($previousIndex -ge 0) {
        [Console]::SetCursorPosition(0, $baseY + $previousIndex)
        $status = if ($options[$previousIndex].Enabled) { "[X]" } else { "[ ]" }
        Write-Host "  $status $($options[$previousIndex].Name)" -ForegroundColor White -NoNewline
    }
    
    # Actualizar la línea actual (resaltar)
    [Console]::SetCursorPosition(0, $baseY + $selectedIndex)
    $status = if ($options[$selectedIndex].Enabled) { "[X]" } else { "[ ]" }
    Write-Host "> $status $($options[$selectedIndex].Name)" -ForegroundColor Yellow -NoNewline
}

try {
    # Mostrar el menú inicial una vez
    Show-Menu
    $selectedIndex = 0
    $previousIndex = -1
    
    # Posicionar el cursor en la primera opción
    Update-Menu -selectedIndex $selectedIndex -previousIndex $previousIndex
    
    do {
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        $previousIndex = $selectedIndex
        
        switch ($key.VirtualKeyCode) {
            38 { if ($selectedIndex -gt 0) { $selectedIndex-- } }  # Flecha arriba
            40 { if ($selectedIndex -lt $options.Length - 1) { $selectedIndex++ } }  # Flecha abajo
            32 {  # Espacio para seleccionar/desmarcar
                $options[$selectedIndex].Enabled = -not $options[$selectedIndex].Enabled
            }
            13 { break }  # Enter para continuar
        }
        
        # Actualizar solo las líneas afectadas
        Update-Menu -selectedIndex $selectedIndex -previousIndex $previousIndex
    } while ($key.VirtualKeyCode -ne 13)
} catch {
    Write-Host "Error en el menú interactivo: $_" -ForegroundColor Red
    pause
    exit 1
}

$selectedOptions = $options | Where-Object { $_.Enabled }

if ($selectedOptions.Count -eq 0) {
    Write-Host "No se seleccionaron opciones." -ForegroundColor Yellow
    pause
    exit 1
}

foreach ($option in $selectedOptions) {
    Write-Host "Ejecutando: $($option.Name)" -ForegroundColor Green
    try {
        Invoke-Expression $option.Command
        $installedApps += $option.Name
    } catch {
        Write-Host "Error al ejecutar $($option.Name): $_" -ForegroundColor Red
    }
}

$endTime = Get-Date
$executionTime = $endTime - $startTime

Write-Host "Tiempo total de ejecución: $($executionTime.TotalMinutes.ToString("F2")) minutos." -ForegroundColor Cyan
Write-Host "Aplicaciones instaladas: $($installedApps -join ', ')" -ForegroundColor Green
Write-Host "La instalación ha finalizado." -ForegroundColor Cyan

pause
exit 0
