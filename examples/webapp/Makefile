#DOCKER_TAG?=$(shell git log -n 1 --format="%h" --)
DOCKER_PATH=example.localnet/software

IMAGE_NAME=webapp
REMOTE_IMAGE_NAME=$(DOCKER_PATH)/$(IMAGE_NAME)
KIND_IMAGE_NAME=localhost:5001/$(IMAGE_NAME)

.PHONY: build
build:
	DOCKER_BUILDKIT=1 docker build \
		-t $(IMAGE_NAME):local .
	docker tag $(IMAGE_NAME):local $(IMAGE_NAME):latest
	docker tag $(IMAGE_NAME):local $(REMOTE_IMAGE_NAME):latest
	docker tag $(IMAGE_NAME):local $(KIND_IMAGE_NAME):latest

.PHONY: run
run: build
	docker run --rm -p 3000:3000 -it --name $(IMAGE_NAME) $(IMAGE_NAME):local
