ls Sources | while read service; do \
    if [ -f "Sources/$service/Dockerfile" ]; then \
        SERVICE_NAME=$(echo $service | sed 's/\([A-Z]\)/ \1/g' | cut -d' ' -f3 | tr '[:upper:]' '[:lower:]') ; \
        echo 'Building' ${CONTAINER_IMAGE}-$SERVICE_NAME ; \
        docker build -t ${CONTAINER_IMAGE}:$SERVICE_NAME-${VERSION} -f Sources/$service/Dockerfile . ; \
    fi ; \
done
