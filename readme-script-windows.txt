Click derecho sobre el script, ejecutar con Powershell.
Si tenemos restringida la ejecución de scripts, el script nos pedirá habilitarla hasta el cierre de sesión con "O"
Seleccionamos las aplicaciones deseadas y pulsamos enter.

Instalar Chocolatey con interfaz gráfica (independiente del script)
Abrir Power Shell como administrador
Pegar los siguientes comandos:
Instalar Chocolatey: 
iwr https://community.chocolatey.org/install.ps1 -UseBasicParsing | iex
Instalar Chocolatey GUI: 
choco install chocolateygui -y
