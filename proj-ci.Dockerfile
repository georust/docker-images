# https://hub.docker.com/orgs/georust/proj-ci

FROM georust/libproj-builder:proj-7.2.0

RUN apt-get update \
  && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
    clang \
  && rm -rf /var/lib/apt/lists/*

COPY --from=georust/libproj-builder:proj-7.2.0 /build/usr /usr
