# https://github.com/orgs/georust/packages/container/package/proj-ci-without-system-proj

# This container is based on the libproj-builder container, which has built
# libproj, and thus has all the dependencies for building proj from source, but
# we intentionally have not installed it to a system path.

ARG RUST_VERSION
ARG PROJ_VERSION

FROM ghcr.io/georust/libproj-builder:proj-${PROJ_VERSION}-rust-${RUST_VERSION}

ARG RUST_VERSION
ARG PROJ_VERSION
RUN test -n "$RUST_VERSION" || (echo "RUST_VERSION ARG not set" && false)
RUN test -n "$PROJ_VERSION" || (echo "PROJ_VERSION ARG not set" && false)

RUN apt-get update \
  && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
    clang \
    cmake \
  && rm -rf /var/lib/apt/lists/*
