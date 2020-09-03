# php-fpm-alpine


The intention here is to instantly be able to:
- spawn a new php project,
- have an easy and full dev environment with xdebug
- a proper php-fpm docker image build that will turn on all optimisations like infinite opcache or preloading
- a separate nginx build that only has public/ content

Source: https://github.com/geekstuff-it/docker-php-fpm-alpine  
Builds: https://hub.docker.com/r/geekstuffreal/php-fpm-alpine  
Duplicated with Dev tools: https://github.com/geekstuff-it/docker-php-buildtools-alpine


## TODO
- add sample usage
- trigger matching buildtools builds in this repo post_build hook
- try/fix xdebug which could be trickier with nginx in between.. (customisable nginx timeout overridden and super extended in dev stage sounds nice)
- get it tried out by someone using docker-machine
