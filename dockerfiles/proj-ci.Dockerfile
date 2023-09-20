# https://hub.docker.com/orgs/georust/proj-ci

ARG RUST_VERSION
ARG PROJ_VERSION
FROM georust/libproj-builder:proj-${PROJ_VERSION}-rust-${RUST_VERSION}

ARG RUST_VERSION
ARG PROJ_VERSION
RUN test -n "$RUST_VERSION" || (echo "RUST_VERSION ARG not set" && false)
RUN test -n "$PROJ_VERSION" || (echo "PROJ_VERSION ARG not set" && false)

RUN apt-get update \
  && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
    clang \
  && rm -rf /var/lib/apt/lists/*

RUN cp -r /build/usr/* /usr
