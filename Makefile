ALL:    docker

IMAGE = jenkinsciinfra/rating
TAG = $(shell git rev-parse HEAD | cut -b 1-7)

build:
	docker build -t $(IMAGE):$(TAG) .

run: build
	docker-compose up --build --detach --force-recreate --renew-anon-volumes

# Ensure bats exists in the current folder
bats:
	git submodule update --init --recursive
	git clone https://github.com/bats-core/bats-core bats
	cd bats && git checkout 3bca150ec86275d6d9d5a4fd7d48ab8b6c6f3d87; # v1.13.0

test: run bats
# Show bats version
	bats/bin/bats --version
ifeq ($(CI), true)
# Execute the test harness and write result to a TAP file
	bats/bin/bats --trace --verbose-run tests/tests.bats --formatter junit | tee tests/junit-results.xml
else
# Execute the test harness
	bats/bin/bats --trace --verbose-run tests/tests.bats --formatter pretty --timing
endif	
