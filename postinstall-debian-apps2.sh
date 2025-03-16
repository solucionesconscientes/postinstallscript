#!/bin/bash

# Actualizar repositorios e instalar wget, git y curl
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
opciones=$(dialog --stdout --checklist "Selecciona las aplicaciones que deseas instalar:" 22 76 16 \
    0 "Actualizar el sistema con nala upgrade" off \
    1 "Actualizar el sistema con apt full-upgrade" on \
    2 "Instalar Flatpak" on \
    3 "Navegadores: LibreWolf (extrepo)" off \
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
    57 "Utilidades: Gwenview (Flatpak)" off \
    58 "Utilidades: p7zip-full, rar, unrar (Debian)" off \
    60 "Bajos Recursos: Vokoscreen (Debian)" off \
    61 "Bajos Recursos: Smplayer (Debian)" off \
    62 "Bajos Recursos: Chromium (Debian)" off \
    63 "Bajos Recursos: Transmission-GTK (Debian)" off \
    64 "Bajos Recursos: Transmission-QT (Debian)" off \
    65 "Bajos Recursos: Deluge (Debian)" off \
    66 "Bajos Recursos: Pragha (Debian)" off \
    67 "Bajos Recursos: Evince (Debian)" off \
    68 "Bajos Recursos: Gthumb (Debian)" off \
    69 "Apagar el equipo" off)

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
            sudo apt update && sudo apt install -y extrepo
            sudo extrepo enable librewolf
            sudo apt update && sudo apt install -y librewolf
            installed_apps+=("LibreWolf")
            ;;
        4)
            flatpak install -y flathub com.brave.Browser
            installed_apps+=("Brave (Flatpak)")
            ;;
        5)
            curl -fsS https://dl.brave.com/install.sh | sudo sh
            installed_apps+=("Brave (Repo)")
            ;;
        6)
            flatpak install -y flathub org.mozilla.firefox
            installed_apps+=("Firefox")
            ;;
        8)
            sudo nala install -y chromium chromium-l10n
            installed_apps+=("Chromium")
            ;;
        9)
            flatpak install -y flathub com.google.Chrome
            installed_apps+=("Google Chrome")
            ;;
        10)
            flatpak install -y flathub org.onlyoffice.desktopeditors
            installed_apps+=("Onlyoffice")
            ;;
        11)
            flatpak install -y flathub org.libreoffice.LibreOffice
            installed_apps+=("LibreOffice")
            ;;
        12)
            flatpak install -y flathub com.wps.Office
            installed_apps+=("WPS Office")
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
        17)
            flatpak install -y flathub org.kde.kdenlive
            installed_apps+=("Kdenlive")
            ;;
        18)
            flatpak install -y flathub org.strawberrymusicplayer.strawberry
            installed_apps+=("Strawberry")
            ;;
        19)
            flatpak install -y flathub org.audacityteam.Audacity
            installed_apps+=("Audacity")
            ;;
        20)
            flatpak install -y flathub fr.handbrake.ghb
            installed_apps+=("Handbrake")
            ;;
        22)
            sudo nala install -y haruna
            installed_apps+=("Haruna")
            ;;
        23)
            flatpak install -y flathub org.kde.krita
            installed_apps+=("Krita")
            ;;
        24)
            flatpak install -y flathub org.gimp.GIMP
            installed_apps+=("Gimp")
            ;;
        25)
            flatpak install -y flathub org.kde.digikam
            installed_apps+=("DigiKam")
            ;;
        26)
            flatpak install -y flathub org.kde.okular
            installed_apps+=("Okular")
            ;;
        27)
            flatpak install -y flathub org.gnome.OCRFeeder
            installed_apps+=("OCR Feeder")
            ;;
        28)
            flatpak install -y flathub io.github.manisandro.gImageReader
            installed_apps+=("GImageReader")
            ;;
        29)
            flatpak install -y flathub net.codeindustry.MasterPDFEditor
            installed_apps+=("Master PDF Editor")
            ;;
        30)
            flatpak install -y flathub com.github.jeromerobert.pdfarranger
            installed_apps+=("PDF Arranger")
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
            installed_apps+=("Onion mediaX")
            ;;
        34)
            flatpak install -y flathub org.localsend.localsend_app
            installed_apps+=("Localsend")
            ;;
        35)
            flatpak install -y flathub com.github.ryonakano.reco
            installed_apps+=("Reco")
            ;;
        36)
            flatpak install -y flathub com.github.vkohaupt.vokoscreenNG
            installed_apps+=("Vokoscreen")
            ;;
        37)
            flatpak install -y flathub org.filezillaproject.Filezilla
            installed_apps+=("Filezilla")
            ;;
        38)
            flatpak install -y flathub org.freefilesync.FreeFileSync
            installed_apps+=("FreeFileSync")
            ;;
        39)
            flatpak install -y flathub org.jdownloader.JDownloader
            installed_apps+=("JDownloader")
            ;;
        40)
            flatpak install -y flathub com.hoptodesk.HopToDesk
            installed_apps+=("HopToDesk")
            ;;
        41)
            flatpak install -y flathub io.github.aandrew_me.ytdn
            installed_apps+=("YTDN")
            ;;
        42)
            flatpak install -y flathub io.github.giantpinkrobots.flatsweep
            installed_apps+=("Flatsweep")
            ;;
        43)
            flatpak install -y flathub com.github.qarmin.czkawka
            installed_apps+=("Czkawka")
            ;;
        44)
            flatpak install -y flathub org.bleachbit.BleachBit
            installed_apps+=("BleachBit")
            ;;
        45)
            sudo nala install -y kio-gdrive kaccounts-providers
            installed_apps+=("Integración Google KDE")
            ;;
        46)
            sudo nala install -y fwupd
            sudo fwupdmgr refresh
            sudo fwupdmgr get-updates
            installed_apps+=("fwupd")
            ;;
        47)
            sudo nala install -y ifuse
            installed_apps+=("ifuse")
            ;;
        48)
            sudo nala install -y \
            libavcodec-extra \
            libdvdcss2 \
            ffmpeg \
            gstreamer1.0-plugins-good \
            gstreamer1.0-plugins-bad \
            gstreamer1.0-plugins-ugly
            installed_apps+=("Codecs Multimedia")
            ;;
        49)
            git clone https://github.com/AdnanHodzic/auto-cpufreq.git /home/auto-cpufreq
            cd /home/auto-cpufreq
            yes | sudo ./auto-cpufreq-installer --install
            installed_apps+=("Autocpufreq")
            ;;
        50)
            wget -q https://github.com/fastfetch-cli/fastfetch/releases/download/2.22.0/fastfetch-linux-amd64.deb
            sudo dpkg -i fastfetch-linux-amd64.deb
            rm -rf fastfetch-linux-amd64.deb
            sudo nala autoremove
            installed_apps+=("Fastfetch")
            ;;
        51)
            sudo nala install -y partitionmanager
            installed_apps+=("KDE Partition Manager")
            ;;
        52)
            sudo nala install -y gufw
            sudo ufw enable
            installed_apps+=("Gufw")
            ;;
        53)
            sudo nala install -y kshutdown
            installed_apps+=("Kshutdown")
            ;;
        54)
            sudo nala install -y gparted
            installed_apps+=("Gparted")
            ;;
        55)
            flatpak install -y flathub org.linux_hardware.hw-probe
            installed_apps+=("Hardware Probe")
            ;;
        56)
            flatpak install -y flathub org.gnome.Firmware
            installed_apps+=("Firmware")
            ;;
        57)
            flatpak install -y flathub org.kde.gwenview
            installed_apps+=("Gwenview")
            ;;
        58)
            sudo nala install -y p7zip-full rar unrar
            installed_apps+=("p7zip-full, rar, unrar")
            ;;
        60)
            sudo nala install -y vokoscreen
            installed_apps+=("Vokoscreen (Bajos Recursos)")
            ;;
        61)
            sudo nala install -y smplayer smplayer-l10n libva-dev libvdpau-dev
            installed_apps+=("Smplayer (Bajos Recursos)")
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
        62)
            sudo nala install -y chromium chromium-l10n
            installed_apps+=("Chromium (Bajos Recursos)")
            ;;
        63)
            sudo nala install -y transmission-gtk
            installed_apps+=("Transmission GTK")
            ;;
        64)
            sudo nala install -y transmission-qt
            installed_apps+=("Transmission QT")
            ;;
        65)
            sudo nala install -y deluge
            installed_apps+=("Deluge")
            ;;
        66)
            sudo nala install -y pragha
            installed_apps+=("Pragha")
            ;;
        67)
            sudo nala install -y evince
            installed_apps+=("Evince")
            ;;
        68)
            sudo nala install -y gthumb
            installed_apps+=("Gthumb")
            ;;
        69)
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