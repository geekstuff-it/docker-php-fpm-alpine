# geekstuff-it/php-fpm-alpine


The intention here is to instantly be able to:
- spawn a new php project,
- have an easy and full dev environment with xdebug
- a proper php-fpm docker image build that will turn on all optimisations like infinite opcache or preloading
- a separate nginx build that only has public/ content

Source: https://github.com/geekstuff-it/docker-php-fpm-alpine  
Builds: https://hub.docker.com/r/geekstuffreal/php-fpm-alpine  
Dockerizer app: https://github.com/geekstuff-it/php-fpm-nginx-alpine-dockerizer


## Example how to use this to kickstart and/or dockerize your php-fpm nginx app on alpine.
For the examples here, we will use php `7.4.9`. You can use `latest`, `7.3` and other variants as well.
(see [here for list of tags](https://hub.docker.com/r/geekstuffreal/php-fpm-alpine/tags) you can choose from)

### Get into a container with php and tools to install your framework and dockerize it.
```
mkdir super-project
cd super-project
docker run --rm -v $(pwd):/app -it geekstuffreal/php-fpm-alpine:7.4.9 php-init
```

### Within the init shell that the above will land you into, create the symfony demo project
```
symfony new --demo --no-git .
php-dockerize
```
* The --no-git option prevents you from having to set your identity within that init phase, where it will be lost anyway.
   You should do that from your own host after.

### Your project is dockerized!
At this point your project is ready.
It was configured to use the lastest specific php version and latest specific geekstuffreal/php-fpm-alpine version,
following your major php version selected above.

(you can exit the shell from the init phase at this point)
```
# start the dev environment
docker-compose up --build
# or start the optimized and fully packaged environment
docker-compose -f docker-compose.prod-test.yml up --build
```
You should now be able to see the result in http://localhost:8080/
(you can change the 8080 port with `LOCAL_HTTP_PORT=8083 docker-compose up`)

## TODO
- add contribution guide
- also reassess build tags
  - maybe adjust auto tags creation to include phpVersion without our version (our latest release being implied)
- try/fix xdebug which could be trickier with nginx in between.. (customisable nginx timeout overridden and super extended in dev stage sounds nice)
- get it tried out by someone using docker-machine. file init permissions should not be an issue there as docker-machine makes them irrelevant I believe.
  - not sure about non docker-machine users using non default main id 1000. Some minor tweaks left to do to handle this.
- consider renaming prod-test to pkg-test
- consider using twig blocks to simply multi framework options
