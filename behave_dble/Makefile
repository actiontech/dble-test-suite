# ifndef DBLE_DBLE_TOPO
# 	DBLE_DBLE_TOPO = single
# endif

PWD = $(shell pwd)
DOCKER_COMPOSE_FILE = docker-compose.yml

up: down
	docker-compose -f ${PWD}/compose/${DOCKER_COMPOSE_FILE} up -d
	sleep 3
	date

clean: down remove_venv
	docker system prune -fa

down:
	docker ps -a -q | xargs -r docker rm -f
	docker network prune -f
	docker volume prune -f

create_venv:
	pipenv install

remove_venv:
	pipenv --rm

venv:
	pipenv shell
