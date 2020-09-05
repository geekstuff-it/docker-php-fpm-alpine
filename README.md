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

### Within the init shell that the above will land you into, create the symfony demo project, then dockerize it.
```
symfony new --demo --no-git .
php-dockerize
```
* The --no-git option prevents you from having to set your identity within that init phase, where it will be lost anyway.
   You should do that from your own host after.


### Your project is dockerized!
At this point your project is docker ready.

It was configured to use the lastest specific php version and latest specific geekstuffreal/php-fpm-alpine version,
matching the php box that you choose to initialize with.

To try it out, first ensure you exit the shell from the init phase above.
You should be outside of docker at this point and inside your project folder.

Then simply run `docker-compose up` and see the result at http://localhost:8080/

## Multi stage Dockerfile
You should see 6 different stages, meant to give you 3 possible end results. Those end results are a **php-fpm dev build**, a **php-fpm prod build**, and an **nginx build**. Here's how it's structured:
- (intermediate) **base** is where you add things that you want in both your dev and prod build.
- (intermediate) **buildtools** extends base, and is where you add the stuff you need in dev,
                 including what you need to build your assets (composer, npm, etc).
- (end result) **dev** extends buildtools, adds xdebug and it's config.
- (intermediate) **build** extends buildtools, and is meant to build all your assets and optimize your code, in preparation for packaging.
- (end result) **nginx** extends geekstuffreal/nginx-php-alpine, which is a slim layer on top of official image to let us configure nginx on the fly more easily.
- (end result) **prod** extends all the way back to base, copy generated files from build stage, optimize php, opcache config, etc.

### Build examples
Examples all assume you are in a terminal in the folder where dockerizer generated files.

#### Prod
```
# Build
docker build --target nginx -t mycode-nginx .
docker build --target prod -t mycode-php-fpm .

# Run (in separate terminals)
docker run --rm --name mycode-php-fpm mycode-php-fpm
docker run -e PHP_FPM_HOST=mycode-php-fpm --link mycode-php-fpm -p 8080:8080 --rm mycode-nginx

# Open http://localhost:8080/ to view result
```

### Dev
```
# Build
docker build --target dev -t mycode-php-fpm-dev .

# Run
docker run --rm --name mycode-php -v $(pwd):/app mycode-php-fpm-dev
docker run --rm --name mycode-nginx --link mycode-php -v $(pwd)/public:/app/public \
  -p 8080:8080 -e PHP_FPM_HOST=mycode-php geekstuffreal/nginx-php-alpine:latest

# Open http://localhost:8080/ to view result
docker exec mycode-php php bin/console about
```

## docker-compose

Dev environment:
```
docker-compose up --build
```

Prod test:
```
docker-compose -f docker-compose.prod-test.yml up --build
```

TIP: If you need to use a different host port than 8080, prepend your docker-compose up with `LOCAL_HTTP_PORT=8083`


## TODO
- add contribution guide
- also reassess build tags
  - maybe adjust auto tags creation to include phpVersion without our version (our latest release being implied)
- try xdebug connect back which could be trickier with nginx in between this time..
  (customisable nginx timeout overridden and super extended in dev stage sounds nice)
- get it tried out by someone using docker-machine. file init permissions should not be an issue there as docker-machine makes them irrelevant I believe.
  - not sure about non docker-machine users using non default main id 1000. Some minor tweaks left to do to handle this.
- consider renaming prod-test to pkg-test
- consider using twig blocks to simply multi framework options
