PWD = $(shell pwd)
DRIVER_DIR = $(shell dirname ${PWD})
DOCKER_COMPOSE_FILE = docker-compose-single.yml
DOCKER_RUNNING = $(shell docker ps -q | wc -l)
DOCKER_EXISTS = $(shell docker ps -aq | wc -l)


up: down
	docker-compose -f ${PWD}/compose/${DOCKER_COMPOSE_FILE} up -d
	sleep 3
	date

clean: down remove_venv
	docker system prune -fa

down:
    ifneq ($(DOCKER_RUNNING),0)
		docker stop $$(docker ps -q)
    endif

    ifneq ($(DOCKER_EXISTS),0)
		docker rm $$(docker ps -a -q)
    endif

	docker network prune -f
	docker volume prune -f

create_venv:
	pipenv install

remove_venv:
	pipenv --rm

venv:
	pipenv shell

reset_mysql:
	pipenv run behave features/setup.feature --tags=@Initialize_mysql

used_in_local: create_venv up
	pipenv run behave features/setup.feature
