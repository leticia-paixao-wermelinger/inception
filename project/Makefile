name = inception

#.DEFAULT_GOAL = all

all:
	docker compose -f ./srcs/docker-compose.yml up -d --build

env:
	./make_env.sh

down:
	docker compose -f ./srcs/docker-compose.yml down

.PHONY : all down 