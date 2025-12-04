ALL:    docker

IMAGE = jenkinsciinfra/rating
TAG = $(shell git rev-parse HEAD | cut -b 1-7)

docker:
	docker build -t $(IMAGE):$(TAG) .

run: docker
	docker-compose up --build -d

# when run with 'make run', makes sure that it responds correctly
run-test:
	curl -v 'http://localhost:8085/rate/submit.php?version=2.536&rating=0&issue=80386' 2>&1
	curl -v 'http://localhost:8085/rate/submit.php?version=2.536&rating=0&issue=https://github.com/jenkinsci/jenkins/issues/20615#issuecomment-3572009192' 2>&1
	curl -v 'http://localhost:8085/rate/submit.php?version=2.536&rating=0&issue=https://github.com/jenkinsci/jenkins/issues/20616#issue-3659905060' 2>&1
	curl -v 'http://localhost:8085/rate/submit.php?version=2.536&rating=0&issue=https://github.com/jenkinsci/jenkins/issues/20620/#issue-3659905060' 2>&1
	curl -v 'http://localhost:8085/rate/submit.php?version=2.536&rating=0&issue=https://github.com/jenkinsci/jenkins/issues/20617/' 2>&1
	curl -v 'http://localhost:8085/rate/submit.php?version=2.536&rating=0&issue=https://github.com/jenkinsci/jenkins/issues/20608' 2>&1
	curl -v 'http://localhost:8085/rate/result.php' 2>&1
