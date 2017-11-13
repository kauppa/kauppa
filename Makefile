CONTAINER_URL = omnijarstudio/kauppa:0.2
CONTAINER_NAME = kauppa

clean:
	if	[ -d ".build" ]; then \
		rm -r .build ; \
	fi

build: clean
	@echo --- Building
	swift build

test: build
	swift test

run: build
	@echo --- Invoking executable
	./.build/debug/Kauppa

build-release clean:
	docker run -v $$(pwd):/tmp/kauppa -w /tmp/kauppa -it ibmcom/swift-ubuntu:4.0 swift build -c release -Xcc -fblocks -Xlinker -L/usr/local/lib

clean-container:

	-docker stop $(CONTAINER_NAME)
	-docker rm $(CONTAINER_NAME)
	-docker rmi $(CONTAINER_URL)

build-container: clean-container build-release

	docker build -t $(CONTAINER_URL) .

.PHONY: build test run
