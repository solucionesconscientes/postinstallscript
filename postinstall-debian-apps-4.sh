#!/bin/bash
# Actualizar repositorios e instalar nala, wget, git y curl
sudo apt update -y
sudo apt install -y nala
sudo nala install -y wget git curl
# Comprobar si dialog está instalado, si no, instalarlo
if ! command -v dialog &> /dev/null; then
    echo "dialog no está instalado. Instalándolo ahora..."
    sudo nala install -y dialog
fi
# Inicializar variables
start_time=$(date +%s)
installed_apps=()
# Mostrar el menú de selección múltiple con las aplicaciones agrupadas por tipo
opciones=$(dialog --stdout --checklist "Selecciona las aplicaciones que deseas instalar:" 23 76 17 \
    0 "Actualizar el sistema con nala upgrade" off \
    1 "Actualizar el sistema con apt full-upgrade" on \
    2 "Instalar Flatpak" on \
    3 "Navegadores: LibreWolf (Flatpak)" off \
    4 "Navegadores: Brave (Flatpak)" off \
    5 "Navegadores: Brave (Repo)" on \
    6 "Navegadores: Firefox (Flatpak)" off \
    8 "Navegadores: Chromium (Debian)" off \
    9 "Navegadores: Google Chrome (Flatpak)" off \
    10 "Ofimática: Onlyoffice (Flatpak)" on \
    11 "Ofimática: LibreOffice (Flatpak)" off \
    12 "Ofimática: WPS Office (Flatpak)" off \
    13 "Multimedia: VLC (Flatpak)" off \
    14 "Multimedia: VLC (Debian)" on \
    15 "Multimedia: VLC Plugin Bittorrent (Debian)" on \
    16 "Multimedia: Celluloid (Debian)" off \
    17 "Multimedia: Kdenlive (Flatpak)" off \
    18 "Multimedia: Strawberry (Flatpak)" off \
    19 "Multimedia: Audacity (Flatpak)" off \
    20 "Multimedia: Handbrake (Flatpak)" off \
    22 "Multimedia: Haruna (Debian)" on \
    23 "Edición de Imágenes: Krita (Flatpak)" off \
    24 "Edición de Imágenes: Gimp (Flatpak)" off \
    25 "Edición de Imágenes: DigiKam (Flatpak)" off \
    26 "PDF y OCR: Okular (Flatpak)" off \
    27 "PDF y OCR: OCR Feeder (Flatpak)" off \
    28 "PDF y OCR: GImageReader (Flatpak)" off \
    29 "PDF y OCR: Master PDF Editor (Flatpak)" off \
    30 "PDF y OCR: PDF Arranger (Flatpak)" off \
    31 "Utilidades: qBittorrent (Flatpak)" off \
    32 "Utilidades: qBittorrent (Debian)" off \
    33 "Utilidades: Onion mediaX (Flatpak)" off \
    34 "Utilidades: Localsend (Flatpak)" on \
    35 "Utilidades: Reco (Flatpak)" on \
    36 "Utilidades: Vokoscreen (Flatpak)" off \
    37 "Utilidades: Filezilla (Flatpak)" off \
    38 "Utilidades: FreeFileSync (Flatpak)" off \
    39 "Utilidades: JDownloader (Flatpak)" on \
    40 "Utilidades: HopToDesk (Flatpak)" on \
    41 "Utilidades: YTDN (Flatpak)" off \
    42 "Utilidades: Flatsweep (Flatpak)" on \
    43 "Utilidades: Czkawka (Flatpak)" off \
    44 "Utilidades: BleachBit (Flatpak)" on \
    45 "Utilidades: Integración Google KDE (Debian)" off \
    46 "Utilidades: fwupd (Debian)" off \
    47 "Utilidades: ifuse (Debian)" on \
    48 "Utilidades: Codecs Multimedia (Debian)" on \
    49 "Utilidades: Autocpufreq (GitHub)" off \
    50 "Utilidades: Fastfetch (Debian)" on \
    51 "Utilidades: KDE Partition Manager (Debian)" off \
    52 "Utilidades: Gufw (Debian)" on \
    53 "Utilidades: Kshutdown (Debian)" on \
    54 "Utilidades: Gparted (Debian)" off \
    55 "Utilidades: Hardware Probe (Flatpak)" off \
    56 "Utilidades: Firmware (Flatpak)" off \
    57 "Utilidades: Gwenview (Debian)" off \
    58 "Utilidades: p7zip-full, rar, unrar (Debian)" off \
    59 "Utilidades: Blueman (Gestor de Bluetooth)" off \
    60 "Utilidades: Linux Assistant (Flatpak)" off \
    61 "Bajos Recursos: Vokoscreen (Debian)" off \
    62 "Bajos Recursos: Smplayer (Debian)" off \
    63 "Bajos Recursos: Chromium (Debian)" off \
    64 "Bajos Recursos: Transmission-GTK (Debian)" off \
    65 "Bajos Recursos: Transmission-QT (Debian)" off \
    66 "Bajos Recursos: Deluge (Debian)" off \
    67 "Bajos Recursos: Pragha (Debian)" off \
    68 "Bajos Recursos: Evince (Debian)" off \
    69 "Bajos Recursos: Gthumb (Debian)" off \
    70 "Apagar el equipo" off)
# Comprobar si se ha cancelado la selección
if [ $? -ne 0 ]; then
    echo "Instalación cancelada por el usuario o error en dialog."
    exit 1
fi
# Verificar si opciones está vacía
if [ -z "$opciones" ]; then
    echo "No se seleccionaron opciones o hubo un error al procesar la selección."
    exit 1
fi
# Ejecutar la actualización del sistema si se selecciona
IFS=' ' read -r -a seleccionadas <<< "$opciones"
if [[ " ${seleccionadas[*]} " =~ " 0 " ]]; then
    sudo nala update && sudo nala upgrade -y
    installed_apps+=("Sistema Actualizado con nala upgrade")
fi
if [[ " ${seleccionadas[*]} " =~ " 1 " ]]; then
    sudo apt update && sudo apt full-upgrade -y
    installed_apps+=("Sistema Actualizado con apt full-upgrade")
fi
# Ejecutar la instalación de Flatpak si se selecciona
if [[ " ${seleccionadas[*]} " =~ " 2 " ]]; then
    sudo apt install -y flatpak
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo  
    installed_apps+=("Flatpak")
fi
# Ejecutar la instalación de las aplicaciones seleccionadas
for opcion in "${seleccionadas[@]}"; do
    case $opcion in
        3)
            flatpak install -y flathub io.librewolf.Librewolf
            installed_apps+=("LibreWolf (Flatpak)")
            ;;
        4)
            flatpak install -y flathub com.brave.Browser
            installed_apps+=("Brave (Flatpak)")
            ;;
        5)
            curl -fsS https://dl.brave.com/install.sh   | sudo sh
            installed_apps+=("Brave (Repo)")
            ;;
        6)
            flatpak install -y flathub org.mozilla.firefox
            installed_apps+=("Firefox (Flatpak)")
            ;;
        8)
            sudo nala install -y chromium chromium-l10n
            installed_apps+=("Chromium (Debian)")
            ;;
        9)
            flatpak install -y flathub com.google.Chrome
            installed_apps+=("Google Chrome (Flatpak)")
            ;;
        10)
            flatpak install -y flathub org.onlyoffice.desktopeditors
            installed_apps+=("Onlyoffice (Flatpak)")
            ;;
        11)
            flatpak install -y flathub org.libreoffice.LibreOffice
            installed_apps+=("LibreOffice (Flatpak)")
            ;;
        12)
            flatpak install -y flathub com.wps.Office
            installed_apps+=("WPS Office (Flatpak)")
            ;;
        13)
            flatpak install -y flathub org.videolan.VLC
            installed_apps+=("VLC (Flatpak)")
            ;;
        14)
            sudo nala install -y vlc
            installed_apps+=("VLC (Debian)")
            ;;
        15)
            sudo nala install -y vlc-plugin-bittorrent
            installed_apps+=("VLC Plugin Bittorrent (Debian)")
            ;;
        16)
            sudo nala install -y celluloid
            installed_apps+=("Celluloid (Debian)")
            ;;
        17)
            flatpak install -y flathub org.kde.kdenlive
            installed_apps+=("Kdenlive (Flatpak)")
            ;;
        18)
            flatpak install -y flathub org.strawberrymusicplayer.strawberry
            installed_apps+=("Strawberry (Flatpak)")
            ;;
        19)
            flatpak install -y flathub org.audacityteam.Audacity
            installed_apps+=("Audacity (Flatpak)")
            ;;
        20)
            flatpak install -y flathub fr.handbrake.ghb
            installed_apps+=("Handbrake (Flatpak)")
            ;;
        22)
            sudo nala install -y haruna
            installed_apps+=("Haruna (Debian)")
            ;;
        23)
            flatpak install -y flathub org.kde.krita
            installed_apps+=("Krita (Flatpak)")
            ;;
        24)
            flatpak install -y flathub org.gimp.GIMP
            installed_apps+=("Gimp (Flatpak)")
            ;;
        25)
            flatpak install -y flathub org.kde.digikam
            installed_apps+=("DigiKam (Flatpak)")
            ;;
        26)
            flatpak install -y flathub org.kde.okular
            installed_apps+=("Okular (Flatpak)")
            ;;
        27)
            flatpak install -y flathub org.gnome.OCRFeeder
            installed_apps+=("OCR Feeder (Flatpak)")
            ;;
        28)
            flatpak install -y flathub io.github.manisandro.gImageReader
            installed_apps+=("GImageReader (Flatpak)")
            ;;
        29)
            flatpak install -y flathub net.codeindustry.MasterPDFEditor
            installed_apps+=("Master PDF Editor (Flatpak)")
            ;;
        30)
            flatpak install -y flathub com.github.jeromerobert.pdfarranger
            installed_apps+=("PDF Arranger (Flatpak)")
            ;;
        31)
            flatpak install -y flathub org.qbittorrent.qBittorrent
            installed_apps+=("qBittorrent (Flatpak)")
            ;;
        32)
            sudo nala install -y qbittorrent
            installed_apps+=("qBittorrent (Debian)")
            ;;
        33)
            flatpak install -y flathub io.github.onionware_github.onionmedia
            installed_apps+=("Onion mediaX (Flatpak)")
            ;;
        34)
            flatpak install -y flathub org.localsend.localsend_app
            installed_apps+=("Localsend (Flatpak)")
            ;;
        35)
            flatpak install -y flathub com.github.ryonakano.reco
            installed_apps+=("Reco (Flatpak)")
            ;;
        36)
            flatpak install -y flathub com.github.vkohaupt.vokoscreenNG
            installed_apps+=("Vokoscreen (Flatpak)")
            ;;
        37)
            flatpak install -y flathub org.filezillaproject.Filezilla
            installed_apps+=("Filezilla (Flatpak)")
            ;;
        38)
            flatpak install -y flathub org.freefilesync.FreeFileSync
            installed_apps+=("FreeFileSync (Flatpak)")
            ;;
        39)
            flatpak install -y flathub org.jdownloader.JDownloader
            installed_apps+=("JDownloader (Flatpak)")
            ;;
        40)
            flatpak install -y flathub com.hoptodesk.HopToDesk
            installed_apps+=("HopToDesk (Flatpak)")
            ;;
        41)
            flatpak install -y flathub io.github.aandrew_me.ytdn
            installed_apps+=("YTDN (Flatpak)")
            ;;
        42)
            flatpak install -y flathub io.github.giantpinkrobots.flatsweep
            installed_apps+=("Flatsweep (Flatpak)")
            ;;
        43)
            flatpak install -y flathub com.github.qarmin.czkawka
            installed_apps+=("Czkawka (Flatpak)")
            ;;
        44)
            flatpak install -y flathub org.bleachbit.BleachBit
            installed_apps+=("BleachBit (Flatpak)")
            ;;
        45)
            sudo nala install -y kio-gdrive kaccounts-providers
            installed_apps+=("Integración Google KDE (Debian)")
            ;;
        46)
            sudo nala install -y fwupd
            sudo fwupdmgr refresh
            sudo fwupdmgr get-updates
            installed_apps+=("fwupd (Debian)")
            ;;
        47)
            sudo nala install -y ifuse
            installed_apps+=("ifuse (Debian)")
            ;;
        48)
            sudo nala install -y \
            libavcodec-extra \
            libdvdcss2 \
            ffmpeg \
            gstreamer1.0-plugins-good \
            gstreamer1.0-plugins-bad \
            gstreamer1.0-plugins-ugly
            installed_apps+=("Codecs Multimedia (Debian)")
            ;;
        49)
            git clone https://github.com/AdnanHodzic/auto-cpufreq.git   /home/auto-cpufreq
            cd /home/auto-cpufreq
            yes | sudo ./auto-cpufreq-installer --install
            installed_apps+=("Autocpufreq (GitHub)")
            ;;
        50)
            wget -q https://github.com/fastfetch-cli/fastfetch/releases/download/2.22.0/fastfetch-linux-amd64.deb  
            sudo dpkg -i fastfetch-linux-amd64.deb
            rm -rf fastfetch-linux-amd64.deb
            sudo nala autoremove
            installed_apps+=("Fastfetch (Debian)")
            ;;
        51)
            sudo nala install -y partitionmanager
            installed_apps+=("KDE Partition Manager (Debian)")
            ;;
        52)
            sudo nala install -y gufw
            sudo ufw enable
            installed_apps+=("Gufw (Debian)")
            ;;
        53)
            sudo nala install -y kshutdown
            installed_apps+=("Kshutdown (Debian)")
            ;;
        54)
            sudo nala install -y gparted
            installed_apps+=("Gparted (Debian)")
            ;;
        55)
            flatpak install -y flathub org.linux_hardware.hw-probe
            installed_apps+=("Hardware Probe (Flatpak)")
            ;;
        56)
            flatpak install -y flathub org.gnome.Firmware
            installed_apps+=("Firmware (Flatpak)")
            ;;
        57)
            sudo nala install -y gwenview
            installed_apps+=("Gwenview (Debian)")
            ;;
        58)
            sudo nala install -y p7zip-full rar unrar
            installed_apps+=("p7zip-full, rar, unrar (Debian)")
            ;;
        59)
            sudo nala install -y blueman
            installed_apps+=("Blueman (Gestor de Bluetooth) (Debian)")
            ;;
        60)
            flatpak install -y flathub io.github.jean28518.Linux-Assistant
            installed_apps+=("Linux Assistant (Flatpak)")
            ;;
        61)
            sudo nala install -y vokoscreen
            installed_apps+=("Vokoscreen (Bajos Recursos) (Debian)")
            ;;
        62)
            sudo nala install -y smplayer smplayer-l10n libva-dev libvdpau-dev
            installed_apps+=("Smplayer (Bajos Recursos) (Debian)")
            # Habilitar la aceleración por hardware en SMPlayer para el usuario actual
            USER_HOME=$(eval echo ~${SUDO_USER:-$USER})
            SMPLAYER_CONF="$USER_HOME/.config/smplayer/smplayer.ini"
            mkdir -p "$USER_HOME/.config/smplayer"
            # Si el archivo no existe, crearlo con la configuración básica
            if [ ! -f "$SMPLAYER_CONF" ]; then
                cat << EOF > "$SMPLAYER_CONF"
[default]
hwdec=auto
EOF
                chown "$SUDO_USER:$SUDO_USER" "$SMPLAYER_CONF"
            # Si el archivo existe, asegurarse de que hwdec esté configurado
            elif ! grep -q "hwdec=auto" "$SMPLAYER_CONF"; then
                # Si hwdec ya existe, reemplazarlo; si no, añadirlo bajo [default]
                if grep -q "hwdec=" "$SMPLAYER_CONF"; then
                    sed -i 's/hwdec=.*/hwdec=auto/' "$SMPLAYER_CONF"
                else
                    sed -i '/\[default\]/a hwdec=auto' "$SMPLAYER_CONF"
                fi
            fi
            ;;
        63)
            sudo nala install -y chromium chromium-l10n
            installed_apps+=("Chromium (Bajos Recursos) (Debian)")
            ;;
        64)
            sudo nala install -y transmission-gtk
            installed_apps+=("Transmission GTK (Bajos Recursos) (Debian)")
            ;;
        65)
            sudo nala install -y transmission-qt
            installed_apps+=("Transmission QT (Bajos Recursos) (Debian)")
            ;;
        66)
            sudo nala install -y deluge
            installed_apps+=("Deluge (Bajos Recursos) (Debian)")
            ;;
        67)
            sudo nala install -y pragha
            installed_apps+=("Pragha (Bajos Recursos) (Debian)")
            ;;
        68)
            sudo nala install -y evince
            installed_apps+=("Evince (Bajos Recursos) (Debian)")
            ;;
        69)
            sudo nala install -y gthumb
            installed_apps+=("Gthumb (Bajos Recursos) (Debian)")
            ;;
        70)
            sudo shutdown -h now
            ;;
        *)
            echo "Opción no reconocida: $opcion"
            ;;
    esac
done
# Record end time
end_time=$(date +%s)
execution_time=$((end_time - start_time))
# Mostrar tiempo de ejecución en la terminal
echo "Tiempo total de ejecución: $((execution_time / 60)) minutos y $((execution_time % 60)) segundos."
echo "La instalación ha finalizado."
exit 0