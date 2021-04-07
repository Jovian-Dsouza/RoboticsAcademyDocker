# If the first argument is ...
ifneq (,$(findstring tools_,$(firstword $(MAKECMDGOALS))))
	# use the rest as arguments
	RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
	# ...and turn them into do-nothing targets
	#$(eval $(RUN_ARGS):;@:)
endif


.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[0-9a-zA-Z_-]+:.*?## / {printf "\033[36m%-42s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

pick_place: ## Build Pick Place
	docker build -t academy:pick_place exercise/pick_place/
	@printf "\n\033[92mDocker Image: academy:pick_place\033[0m\n"

run_pick_place : ## [NVIDIA] Run Pick Place
	xhost +
	docker run -it --rm \
	-e DISPLAY=${DISPLAY} \
	-v ${XSOCK}:${XSOCK} \
	-v ${HOME}/.Xauthority:/root/.Xauthority \
	--privileged  --net=host --gpus all \
	-v ${PWD}/home:/root/ \
	--name academy_pick_place academy:pick_place /bin/bash
	@printf "\n\033[92mDocker Image: academy:pick_place\033[0m\n"

run_drone_cat_mouse : ## [NVIDIA] Run cat mouse
	xhost +
	docker run -it --rm \
	-e DISPLAY=${DISPLAY} \
	-v ${XSOCK}:${XSOCK} \
	-v ${HOME}/.Xauthority:/root/.Xauthority \
	--privileged  --net=host --gpus all \
	-v ${PWD}/home:/root/dockerHome \
	--name academy_drone_cat_mouse \
	docker_academy:latest /bin/bash
	@printf "\n\033[92mDocker Image: academy:pick_place\033[0m\n"

web_docker_academy: ## Web Docker academy
	docker run -it --rm \
	--privileged --gpus all \
	-v ${PWD}/home:/root/dockerHome \
	-p 8080:8080 -p 7681:7681 -p 2303:2303 -p 1905:1905 -p 8765:8765 -p 6080:6080 \
	--name academy_drone_cat_mouse \
	docker_academy:latest python3.8 manager.py
	@printf "\n\033[92mDocker Image: academy:pick_place\033[0m\n"