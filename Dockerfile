FROM python:3.7-alpine as builder

RUN apk --no-cache add \
    build-base \
    python3-dev \
    libffi-dev \
    openssl-dev \
    ncurses-dev \
    libxml2-dev \
    libxslt-dev \
    git \
    bash \
    cargo \
    rust && \
    # netconf-console installation
    pip3 install git+https://bitbucket.org/martin_volf/ncc/@2.3.0 && \
    find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf && \
    find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf

FROM python:3.7-alpine as prod
# Labels
LABEL maintainer="dodin.roman@gmail.com" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.build-date= \
    org.label-schema.vcs-ref= \
    org.label-schema.name="hellt/netconf-console-docker" \
    org.label-schema.description="Netconf-console inside Alpine Docker container" \
    org.label-schema.url="https://github.com/hellt/netconf-console-docker" \
    org.label-schema.vcs-url="https://github.com/hellt/netconf-console-docker" \
    org.label-schema.vendor="Roman Dodin" \
    org.label-schema.docker.cmd="docker run --rm -it hellt/netconf-console --help"

RUN apk add --no-cache \
    python3 \
    openssh && \
    # cleanup
    find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf && \
    find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf

COPY --from=builder /usr/lib/libx*.* /usr/lib/
COPY --from=builder /usr/lib/libex*.* /usr/lib/
COPY --from=builder /usr/lib/libgcrypt* /usr/lib/
COPY --from=builder /usr/lib/libgpg* /usr/lib/
COPY --from=builder /usr/local/lib/python3.7/site-packages/ /usr/local/lib/python3.7/site-packages/
COPY --from=builder /usr/local/bin/netconf-console /usr/local/bin/netconf-console

WORKDIR /rpc

ENTRYPOINT [ "netconf-console" ]
