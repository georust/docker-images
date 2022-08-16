# https://hub.docker.com/orgs/georust/proj-ci-without-system-proj

# This container is based on the libproj-builder container, which has built
# libproj, and thus has all the dependencies for building proj from source, but
# we intentionally have not installed it to a system path.
FROM georust/libproj-builder:rust-1.63

RUN apt-get update \
  && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
    clang \
    cmake \
  && rm -rf /var/lib/apt/lists/*
