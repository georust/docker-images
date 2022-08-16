# https://hub.docker.com/orgs/georust/geo-ci

# ------------------------------------------------------------------------------
# Final stage
# ------------------------------------------------------------------------------

FROM rust:1.61

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

COPY --from=georust/libproj-builder:rust-1.61 /build/usr /usr

