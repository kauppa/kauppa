## Swagger specification

All our APIs should have valid Swagger spec modularized and defined in this directory.

You can see the documented version using a docker container,

```
docker run -p 80:8080 -d -e SWAGGER_JSON=/specs/swagger.yaml -v "$(pwd)/specs":/specs swaggerapi/swagger-ui
```
