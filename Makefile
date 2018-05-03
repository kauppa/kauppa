CONTAINER_VERSION = 0.2
CONTAINER_NAME = kauppa
CONTAINER_URL = naamio/$(CONTAINER_NAME)

KAUPPA_SERVICE_PORT = 8090
KAUPPA_PRODUCTS_PORT = 8000
KAUPPA_ACCOUNTS_PORT = 8020
KAUPPA_TAX_PORT = 8070
KAUPPA_CART_PORT = 8025

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
	docker run -v $$(pwd):/tmp/kauppa -w /tmp/kauppa -it ibmcom/swift-ubuntu:4.0 swift build -c release -Xcc -fblocks -Xlinker -L/usr/local/lib

clean-container:
	-docker stop $(CONTAINER_NAME)
	-docker rm $(CONTAINER_NAME)
	-docker rmi $(CONTAINER_URL):$(CONTAINER_VERSION)

build-container: clean-container build-release
	docker build -t $(CONTAINER_URL):$(CONTAINER_VERSION) .

build-containers: clean-containers build-release
	CONTAINER_IMAGE=$(CONTAINER_URL) VERSION=$(CONTAINER_VERSION) ./scripts/build-images.sh

run-containers: build-containers
	docker run -itd --name=kauppa-accounts -p $(KAUPPA_ACCOUNTS_PORT):$(KAUPPA_SERVICE_PORT) naamio/kauppa:accounts-$(CONTAINER_VERSION) ; \
	KAUPPA_ACCOUNTS=$$(docker inspect kauppa-accounts | grep IPAddress | tail -1 | awk -F '"' '{print $$4}') ; \
	docker run -itd --name=kauppa-tax -p $(KAUPPA_TAX_PORT):$(KAUPPA_SERVICE_PORT) naamio/kauppa:tax-$(CONTAINER_VERSION) ; \
	KAUPPA_TAX=$$(docker inspect kauppa-tax | grep IPAddress | tail -1 | awk -F '"' '{print $$4}') ; \
	docker run -itd --name=kauppa-products \
		-e KAUPPA_TAX_ENDPOINT=http://$$KAUPPA_TAX:$(KAUPPA_SERVICE_PORT) \
		-p $(KAUPPA_PRODUCTS_PORT):$(KAUPPA_SERVICE_PORT) naamio/kauppa:products-$(CONTAINER_VERSION) ; \
	KAUPPA_PRODUCTS=$$(docker inspect kauppa-products | grep IPAddress | tail -1 | awk -F '"' '{print $$4}') ; \
	docker run -itd --name=kauppa-cart \
		-e KAUPPA_TAX_ENDPOINT=http://$$KAUPPA_TAX:$(KAUPPA_SERVICE_PORT) \
		-e KAUPPA_ACCOUNTS_ENDPOINT=http://$$KAUPPA_ACCOUNTS:$(KAUPPA_SERVICE_PORT) \
		-e KAUPPA_PRODUCTS_ENDPOINT=http://$$KAUPPA_PRODUCTS:$(KAUPPA_SERVICE_PORT) \
		-e KAUPPA_COUPONS_ENDPOINT=127.0.0.1 \
		-e KAUPPA_ORDERS_ENDPOINT=127.0.0.1 \
		-p $(KAUPPA_CART_PORT):$(KAUPPA_SERVICE_PORT) naamio/kauppa:cart-$(CONTAINER_VERSION)

clean-containers:
	-docker images | grep $(CONTAINER_URL).*$(CONTAINER_VERSION) | awk -v OFS=':' '{print $$1,$$2}' | xargs docker rmi

push-containers: build-containers
	docker images | grep $(CONTAINER_URL).*$(CONTAINER_VERSION) | awk -v OFS=':' '{print $$1,$$2}' | xargs docker push

.PHONY: clean build test run
