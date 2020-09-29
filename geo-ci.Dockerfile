# https://hub.docker.com/orgs/georust/geo-ci

# ------------------------------------------------------------------------------
# PROJ build stage
# ------------------------------------------------------------------------------

FROM ubuntu:20.04 as proj_builder

# Specify where PROJ will get installed
ARG DESTDIR="/build"

# Install dependencies
RUN apt-get update \
  && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
    clang \
    libcurl4-gnutls-dev \
    libsqlite3-dev \
    libtiff5-dev \
    make \
    cmake \
    pkg-config \
    sqlite3 \
    wget

# Compile and install
RUN wget https://github.com/OSGeo/PROJ/releases/download/7.1.0/proj-7.1.0.tar.gz \
  && tar -xzvf proj-7.1.0.tar.gz \
  && cd proj-7.1.0 \
  && ./configure --prefix=/usr \
  && make -j$(nproc) \
  && make install

# ------------------------------------------------------------------------------
# tarpaulin build stage
# ------------------------------------------------------------------------------

FROM rust:latest as tarpaulin_builder

RUN cargo install cargo-tarpaulin --root /build

# ------------------------------------------------------------------------------
# Final stage
# ------------------------------------------------------------------------------

FROM ubuntu:20.04

# clang and libtiff5 are needed to build geo with `--features use-proj`
# curl is needed to run tarpaulin
RUN apt-get update \
  && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
    ca-certificates \
    cargo \
    clang \
    curl \
    git \
    libtiff5 \
    rustc \
  && rm -rf /var/lib/apt/lists/*

# Copy PROJ artifacts from proj_builder
COPY --from=proj_builder /build/usr/share/proj/ /usr/share/proj/
COPY --from=proj_builder /build/usr/include/ /usr/include/
COPY --from=proj_builder /build/usr/bin/ /usr/bin/
COPY --from=proj_builder /build/usr/lib/ /usr/lib/

# Copy tarpauling artifacts from proj_builder
COPY --from=tarpaulin_builder /build/bin/ /usr/bin
