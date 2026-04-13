ALL:    docker

IMAGE = jenkinsciinfra/rating
TAG = $(shell git rev-parse HEAD | cut -b 1-7)

docker:
	docker build -t $(IMAGE):$(TAG) .

run: docker
	docker-compose up --build --detach --force-recreate --renew-anon-volumes

test: run
	bats --trace --verbose-run tests/tests.bats
