Despues de Instalar Manjaro

** Selecciona los Repositorios más Rápidos
sudo pacman-mirrors -g

** Instalar Fuentes topograficas

sudo pacman -S ttf-liberation ttf-dejavu cantarell-fonts ttf-bitstream-vera ttf-droid terminus-font nerd-fonts-terminus ttf-inconsolata ttf-hack ttf-ubuntu-font-family ttf-anonymous-pro ttf-cheapskate ttf-fira-sans ttf-font-icons ttf-font-logos ttf-freefont ttf-linux-libertine ttf-linux-libertine-g ttf-montserrat ttf-roboto

** Habilitar Formatos de Archivos Comprimidos

sudo pacman -S unrar zip unzip p7zip lzip arj sharutils lzop unace lrzip xz cabextract lha lz4 gzip bzip2

** Instalar Visual studio code
Install from AUR (Method # 1)

1- Acquire build files from Arch Linux user repository.

    $ curl -L -O https://aur.archlinux.org/cgit/aur.git/snapshot/visual-studio-code-bin.tar.gz

2- Extract the downloaded package

    $ tar -xvf visual-studio-code-bin.tar.gz

3- Change directory to the extracted package

    $ cd visual-studio-code-bin

4- Build and install the package

    $ makepkg -si

** Instalar Xampp es su ultima version

Bajamos de la pagina oficial la version para linux la ultima disponible
https://www.apachefriends.org/es/download.html

Agregamos las dependencias si estamos en la version de 64bits
sudo pacman -S lib32-glibc lib32-gcc-libs

Tamnbien tenemos que instalar los siguientes programas
net-tools, inetutils

Nos dirigimos a la carpeta donde se descargo los archivos y le damos permisos de ejecución
chmod +x xampp-linux-x64-7.2.12-0-installer.run 

Ejecutamos el instalador y seguimos todos los pasos.
sudo ./xampp-linux-x64-7.2.12-0-installer.run

Para incializar xampp ejecutamos en la terminal.
sudo /opt/lamp/lamp start

Para reiniciar xampp ejecutamos en la terminal.
sudo /opt/lamp/lamp restart

Para parar xampp ejecutamos en la terminal.
sudo /opt/lamp/lamp stop

Para solucionar el problema con phpmyadmin, seguimos estos pasos
Dentro de la carpeta de instalación, de xampp /opt/lamp, buscamos la carpeta phpmyadmin
en la cual hay un archivo llamado config.inc.php, abrimos este archivo y buscamos la linea donde esta los siguiente

/* Directories for saving/loading files from server */
$cfg['UploadDir'] = '';
$cfg['SaveDir'] = ''

Insertar el código: 
$cfg['TempDir'] = '/tmp';

Guardar y salir (:wq)

Reiniciar el servicio MySql 

Con ellos solucionamos ese problma que se presentaba cuando ... abriamos phpmyadmin

** Para ingresar a mysql por consola podemos hacerlo con la siguiente instruncción
/opt/lampp/bin/mysql -u root  (sin password por defecto)[enter]

Ahora vamos a crear un virtualhost para poder desarrollar en nuestro directorio personal y no tener problemas con permisos



** Información valiosa de GIT
http://rogerdudler.github.io/git-guide/index.es.html


** Instalar Mysql-WorkBench
los instalamos normal desde los Repositorios, pero para que funcione correctamente tenemos que instalar el siguiente paquete
sudo pacman -Sy gnome-keyring

** Instalar termtosvg
Esta herramienta la utilizamos para guardar en formato gif o animacion la consola, hay que instalarlo por medio de AUR
en este caso lo hice despues de instalar pamac que me permite instalar y compilar aplicaciones con AUR.

** Instalar simplescreenrecord para grabar los videos
pacman -Sy simplescreenrecord

** Instalar funetes tf-ms-fonts, se hace desde AUR con el instalador grafico que se instalar con pamac

** Instalar wine, para poder ejecutar programas de microsoft, el va a instalar otras dependencias cuando ejecutes la aplicacion
pacman -Sy wine
