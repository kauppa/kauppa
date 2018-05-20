FROM ibmcom/swift-ubuntu-runtime:4.1

ADD .build/release/KauppaCoupon /usr/share/kauppa/

ENV KAUPPA_SERVICE_PORT=8090

EXPOSE ${KAUPPA_SERVICE_PORT}

WORKDIR /usr/share/kauppa/

ENTRYPOINT ["/usr/share/kauppa/KauppaCoupon"]
