CONTAINER_VERSION = 0.2
CONTAINER_NAME = kauppa
CONTAINER_URL = naamio/$(CONTAINER_NAME)

clean:
	if	[ -d ".build" ]; then \
		rm -rf .build ; \
	fi

build: clean
	@echo --- Building
	swift build

test: build
	swift test

run: build
	@echo --- Invoking executable
	./.build/debug/Kauppa

build-release: clean
	docker run -v $$(pwd):/tmp/kauppa -w /tmp/kauppa -it ibmcom/swift-ubuntu:4.0.3 swift build -c release -Xcc -fblocks -Xlinker -L/usr/local/lib

clean-container:

	-docker stop $(CONTAINER_NAME)
	-docker rm $(CONTAINER_NAME)
	-docker rmi $(CONTAINER_URL):$(CONTAINER_VERSION)

build-container: clean-container build-release

	docker build -t $(CONTAINER_URL):$(CONTAINER_VERSION) .

build-containers: build-release
	ls Sources | while read service; do \
		if [ -f "Sources/$$service/main.swift" ]; then \
			SERVICE_NAME=$$(echo $$service | sed 's/\([A-Z]\)/ \1/g' | cut -d' ' -f3 | tr '[:upper:]' '[:lower:]') ; \
			echo 'Building' $(CONTAINER_URL)-$$SERVICE_NAME ; \
			docker build -t $(CONTAINER_URL)-$$SERVICE_NAME:$(CONTAINER_VERSION) -f Sources/$$service/Dockerfile . ; \
		fi ; \
	done

remove-containers:
	docker images | grep $(CONTAINER_URL).*$(CONTAINER_VERSION) | awk -v OFS=':' '{print $$1,$$2}' | xargs docker rmi

push-containers: build-containers
	docker images | grep $(CONTAINER_URL).*$(CONTAINER_VERSION) | awk -v OFS=':' '{print $$1,$$2}' | xargs echo 'Pushing'

.PHONY: clean build test run
