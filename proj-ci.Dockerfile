# https://hub.docker.com/orgs/georust/proj-ci

FROM libproj-builder

RUN apt-get update \
  && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
    cargo \
    clang \
    rustc \
  && rm -rf /var/lib/apt/lists/*

COPY --from=libproj-builder /build/usr /usr
