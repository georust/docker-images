# https://hub.docker.com/orgs/georust/geo-ci

# ------------------------------------------------------------------------------
# tarpaulin build stage
# ------------------------------------------------------------------------------

FROM rust:latest as tarpaulin-builder

RUN cargo install cargo-tarpaulin --root /build

# ------------------------------------------------------------------------------
# Final stage
# ------------------------------------------------------------------------------

FROM ubuntu:20.04

# clang and libtiff5 are needed to build geo with `--features use-proj`
# note: I think we can remove clang if we make bindgen optional, see https://github.com/georust/proj-sys/issues/24
# curl is needed to run tarpaulin
RUN apt-get update \
  && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
    ca-certificates \
    cargo \
    clang \
    curl \
    git \
    libtiff5 \
    pkg-config \
    rustc \
  && rm -rf /var/lib/apt/lists/*

COPY --from=libproj-builder:latest /build/usr /usr
COPY --from=tarpaulin-builder /build/bin /usr/bin

