# https://hub.docker.com/orgs/georust/geo-ci

# ------------------------------------------------------------------------------
# Final stage
# ------------------------------------------------------------------------------

ARG RUST_VERSION
ARG PROJ_VERSION

FROM georust/libproj-builder:proj-${PROJ_VERSION}-rust-${RUST_VERSION} as libproj-builder
FROM rust:$RUST_VERSION

ARG RUST_VERSION
ARG PROJ_VERSION
RUN test -n "$RUST_VERSION" || (echo "RUST_VERSION ARG not set" && false)
RUN test -n "$PROJ_VERSION" || (echo "PROJ_VERSION ARG not set" && false)

# clang and libtiff5 are needed to build geo with `--features use-proj`
# note: I think we can remove clang if we make bindgen optional, see https://github.com/georust/proj-sys/issues/24
RUN apt-get update \
  && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
    ca-certificates \
    clang \
    git \
    libtiff5 \
    pkg-config \
  && rm -rf /var/lib/apt/lists/*

COPY --from=libproj-builder /build/usr /usr

