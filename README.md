# dockerlamp

LAMP docker with php5.6 and  services via supervisord: ssh,mysql,apache

Documentroot (WORKDIR) = 

## building new image

`docker build -t  wessie/lamp .`
`docker push wessie/lamp`

## running

from dockerhub:  `docker pull wessie/lamp`

`docker run -p 22 -p 8080:80 -t -i wessie/lamp`

## attaching

(use running container id)

`docker exec -it daf0e6648d96 /bin/bash`