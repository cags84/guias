# Guia Docker - Php7

Guia para configurar Docker con php7, postgresql, entre otras herramientas con el objetivo de tener un entorno de desarrollo con todo lo necesario, ya sea para Laravel, o para desarrollar sus proyectos con php sin framewoks.

![Logo](/images/logo.png)

## Requerimientos

Esta guía esta desarrollada en:

* S.O = Ubuntu 20.04 Focal
* Docker version 19.03.11, build 42e35e61f3
* docker-compose version 1.25.0

Se entiende que se tiene instalado el S.O Ubuntu 20.04 Focal y actualizado, ademas tambien de instalar Docker y docker compose, como editores vamos a utilizar.

* vim
* sublime text 3
* visual studio code

### Paso 1

Actualizamos nuestro sistemas host.

```shell
sudo apt-get update && sudo apt-get upgrade -y
```
### Paso 2

Instalamos algunas dependencias, que utilizaremos a lo largo de la guía.
```shell
$ sudo apt-get install vim nano tree
```

### Paso 3
Cremos la estructura de directorios para nuestro proyecto, en este caso voy a crear un directorio llamada *code-php* dentro de mi directorio personal.

```shell
$ cd ~
$ mkdir ~/code-php
``` 
Ingresamos al directorio
```shell
$ cd ~/code-php
```

### Paso 4
Desde el registry https://hub.docker.com/ vamos a descargar las siguientes imagenes

* composer
* php7.2-apache
* postgres:10.13

Tenemos que tener en cuenta que instalo versiones especificas, dado que cumplen con los requisitos para laravel al día de hoy 14-06-2020, si estas viendo esta guía mucho tiempo despues es recomendable que ajustes esto porque puede ser diferente.

Para descargar las imagenes con docker hacemos lo siguiente.

```shell
$ docker pull composer
$ docker pull php:7.2-apache
$ docker pull postgres:10.13
```
Podemos comprobar que se hizo correctamente la descarga con el siguiente comando.

```shell
$ docker image ls
```

Veremos algo así.

![Imagen ls](/images/image-ls.png)

### Paso 5

Aprovechando que tenemos la imagen de composer podemos generar la estructura del proyecto, que en este caso vamos a utilizar laravel, para ello vamos crear un contenedor momentaneo que nos permitear ejecutar esa tarea.

```shell
$ cd ~/code-php
$ docker container run --rm -it -v $PWD:/app composer create-project --prefer-dist laravel/laravel app-laravel
```

Con ese comando crearemos un proyecto nuevo con el nombre de app-laravel, a tener encuenta que si queremo una versión especifica debemos pasarlo al final del comando, para la fecha de esta guia va a instalar la versión 7.x de laravel, pero si quisieramos la versión 6.x, debemos especificarlo, lo podemos ver en la guía de laravel. https://laravel.com/docs/6.x#installing-laravel

Ahora tenemos un problema dado que el comando crea los arhivos con permisos de root:root, debemos pasar los permisos a nuestro usuario, por lo cual debemos entrar a la carpeta y hacer los siguiente.

```shell
$ cd ~/code.php/
$ sudo chown -R carlos:carlos app-laravel/
$ sudo chmod -R 755 app-laravel/
```

### Paso 6

Ahora desde nuestro directorio *code-php* vamos a llamar nuestro editor de preferencia y crearemos el *DockerFile*, y agregamos la siguiente configuración, nombre del archivo debe respetar mayusculas y minusculas.

```shell
ARG VERSION="php:7.2-apache"

FROM ${VERSION}

# Actualizamos el SO
RUN apt-get update

# Instalamos utilidades
RUN apt-get install -y curl git supervisor zip unzip vim nano htop wget

# Instalamos dependencias de php
RUN apt-get install -y libpq-dev && docker-php-ext-install pdo pdo_pgsql pdo_mysql

# Copiamos composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Habilitamos rewrite
RUN a2enmod rewrite

# Creamos una variable de entorno
ENV APP_HOME /var/www/html

# Eliminamos el contenido por default y creamos un enlace simbolico
RUN mkdir -p /opt/data/public && rm -rf /var/www/html && ln -s /opt/data/public $APP_HOME

# Definimos el workspace
WORKDIR $APP_HOME
```

Es este archivo definimos que vamos a utilizar la versión php:7.2-apache, instalamos las dependencias necesarias y copiamo el composer que lo vamos a necesitas, ademas de activar modulos y definir otro directorio como directorio de trabajo.

### Paso 7

Ahora con su editor de preferencia, vamos a crear el archivo *docker-composer.yml*, y le agregamos el siguiente contenido-

```shell
version: "3"

services:
    postgres:
        image: postgres:10.13
        ports: 
            - "5432:5432"
        volumes:
            - ~/.docker/laraveldb2/postgres:/var/lib/postgresql/data
        environment: 
            POSTGRES_PGDATA: /var/lib/postgresql/data/pgdata
            POSTGRES_USER: admin
            POSTGRES_DB: laraveldb
            POSTGRES_PASSWORD: admin
    web:
        build: .
        volumes: 
            - ./:/opt/data
        ports: 
            - 8080:80
        depends_on: 
            - postgres
```

Con esto estamos definiendo dos servicios, uno para la base de datos postgres:10.13, y el otro llamado web, que va a tomar el Dockerfile creado anteriormente, puede editarlo a su necesidad.

### Paso 8

Ahora procedemos a correr los servicios.

```shell
$docker-composer up -d
```
up nos permite iniciar los contenedores con los parametros indicados en *docker-compose.yml* y el flag *-d* nos da la opción de correr los conetenedores en segundo plano, para que quedemos en el la terminal.

### Paso 9

Podemos verificar que los contenedores esten corriendo, de las suguientes formas.

```shell
$ docker container ls
```

![Lista de contenedores](/images/container-ls.png)

Veamos en el navegador, ingresando a http://127.0.0.1:8080

![Laravel](/images/laravel-1.png)

### Paso 10

Podemos ingresar a los contenedores para poder hacer modificaciones o realizar alguna accion.

Primero los listamos para ver el id.

```shell
$ docker container ls
```
![Laravel-6](/images/laravel6.png)

Podemos ver los id y tomamos notas de los tres primeros caracteres, por ejemplo *0ac* es para ingresar al contenedor donde tenemos el document_root y el *916* para ingresar al contenedor de postgresql.

Ej: docker exec -it id_contenedor comando_a_ejecutar

```shell
$ docker exec -it 0ac bash
```

Lo que veremos es que nos devuelve una terminal donde podemos trabajar.

![Ingresar container](/images/ingresar-container.png)

### Paso 11

Como tome como ejemplo Laravel, entonces debemos modificar las variables de entorno ubicada en el archivo *.env*, para poder definir los parametros para la conexión a la base de datos, que para este caso es postgresql.

Con el editor de nuestra preferencia, editamos el archivo *.env*, ubicado en la raíz de proyecto y modificamos para que se vea así, obviamente las credencias son las que colocamos en el archivo *docker-compose.yml*.

Tips: En el campo DB_HOST, le colocamos postgres, que el valor que definimos en el archivo *docker-compose.yml*, es como llamamos al servicio en este caso *postgres*.

![Configuracion BD](/images/configuracion-bd.png)


### Paso 12

Ahora nos podemos conectar al contenedor como lo vemos en el paso 10, y por medio de *php artisan migrate*, hacer la configuración en la base de datos.

Recuerda verificar el id, *docker container ls*.
```shell
$ docker exec -it 0ac bash
```

Ya podemos ejecutar comandos sin problemas y con ello poder trabajar.

![php artisan](/images/php-artisan.png)

Podemos ingresar tambien al contenedor de base de datos postgresql, con el id.

Recuerda verificar el id, *docker container ls*.
```shell
$ docker exec -it 916 bash
```

![container-postgres](/images/container-postgres.png)


Muchas gracias por seguir este tutorial, espero les sea de ayuda :)

### Creditos

Este tutorial esta basado en el video en youtube https://www.youtube.com/watch?v=Jh8F9MYxVhQ, de Ferroxido, ademas de las páginas de cada una de las imagenes en hub docker https://hub.docker.com/, https://www.youtube.com/watch?v=q7v2Qqf2Vmk

