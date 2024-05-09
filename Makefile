DOCKER_COMP = docker compose

PHP_CONT = $(DOCKER_COMP) exec php

PHP      = $(PHP_CONT) php
COMPOSER = $(PHP_CONT) composer
SYMFONY  = $(PHP) bin/console

.DEFAULT_GOAL = help
.PHONY        : help build up start down logs sh composer vendor sf cc test

# Show this help
help:
	@cat $(MAKEFILE_LIST) | docker run --rm -i w1d0/make-help

## Docker
# Builds the Docker images
build:
	@$(DOCKER_COMP) build --pull --no-cache

# Start the docker hub in detached mode (no logs)
up:
	@$(DOCKER_COMP) up --detach

# Build and start the containers
start: build up

# Stop the docker hub
down:
	@$(DOCKER_COMP) down --remove-orphans

# Show live logs
logs:
	@$(DOCKER_COMP) logs --tail=0 --follow

# Connect to the FrankenPHP container
sh:
	@$(PHP_CONT) sh

# Connect to the FrankenPHP container via bash so up
# and down arrows go to previous commands
bash:
	@$(PHP_CONT) bash

# Start tests with phpunit, pass the parameter "c=" to add options to phpunit,
# example: make test c="--group e2e --stop-on-failure"
test:
	@$(eval c ?=)
	@$(DOCKER_COMP) exec -e APP_ENV=test php bin/phpunit $(c)


## Composer
# Run composer, pass the parameter "c=" to run a given command,
# example: make composer c='req symfony/orm-pack'
composer:
	@$(eval c ?=)
	@$(COMPOSER) $(c)

# Install vendors according to the current composer.lock file
vendor:
vendor: c=install --prefer-dist --no-dev --no-progress --no-scripts --no-interaction
vendor: composer

## Symfony
# List all Symfony commands or pass the parameter "c=" to run a given command,
# example: make sf c=about
sf:
	@$(eval c ?=)
	@$(SYMFONY) $(c)

# Clear the cache
cc: c=c:c
cc: sf

## Gitflow
# Get current version number
fsv:
	gitversion /showvariable FullSemVer
