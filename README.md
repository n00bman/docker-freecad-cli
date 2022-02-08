# docker-freecad-cli
Docker image for Freecad build without GUI based on Ubuntu 21.04

https://wiki.freecadweb.org/About_FreeCAD

## How to run image?

docker pull avyaborov/freecad-cli:latest

## Run docker image:

docker run -it avyaborov/freecad-cli:latest bash


## How to run FreeCADCmd?

Before run FreeCADCmd you need set env variable HOME. For example if you use FreeCADCmd in PHP you should do it like this

exec(HOME=/home/user /usr/local/bin/FreeCADCmd)

