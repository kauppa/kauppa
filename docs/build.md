## Building Kauppa

Use `make build` and `make test` for usual building and testing.

### Docker

Use `make build-container` if you want a monolithic image. For scalability, each service should have its own image, for which `make build-containers` can be used.

`CONTAINER_VERSION`, `CONTAINER_NAME` and `CONTAINER_URL` can be set manually through arguments to `make` (like `make build-container CONTAINER_VERSION=0.0`). This is how we build the images in Gitlab CI (see `.gitlab-ci.yml` in root).

Each service has its own `Dockerfile`, which assumes that the docker daemon gets the context from root.
