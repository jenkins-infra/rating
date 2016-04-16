ALL:    docker

IMAGE = jenkinsciinfra/rating
TAG = $(shell git rev-parse HEAD | cut -b 1-7)

docker:
	docker build -t $(IMAGE):$(TAG) .

push: docker
	docker push $(IMAGE):$(TAG)

run: docker
	docker run -ti --rm -p 8085:80 $(IMAGE):$(TAG)
