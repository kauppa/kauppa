FROM ibmcom/swift-ubuntu-runtime:4.0.3

ADD .build/release/KauppaNaamio /usr/share/kauppa/

ENV KAUPPA_SERVICE_PORT=8090

EXPOSE ${KAUPPA_SERVICE_PORT}

WORKDIR /usr/share/kauppa/

ENTRYPOINT ["/usr/share/kauppa/KauppaNaamio"]
