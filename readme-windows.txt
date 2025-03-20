1. Abrir Powershell como administrador
2. Pegar el siguiente comando para permitir la ejecución de escripts sólo durante la sesión actual, al cerrar la sesión y volver a iniciar la ejecución de scripts no estará permitida: Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
3. Click derecho sobre el script, ejecutar con Powershell.

Instalar Chocolatey con interfaz gráfica (independiente del script)
Chocolatey: iwr https://community.chocolatey.org/install.ps1 -UseBasicParsing | iex
Chocolatey GUI: choco install chocolateygui -y
