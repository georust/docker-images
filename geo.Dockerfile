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
    pkg-config \
    sqlite3 \
    wget

# Compile and install
RUN wget https://github.com/OSGeo/PROJ/releases/download/7.0.1/proj-7.0.1.tar.gz \
  && tar -xzvf proj-7.0.1.tar.gz \
  && cd proj-7.0.1 \
  && ./configure --disable-dependency-tracking --prefix=/usr \
  && make \
  && make install

# ------------------------------------------------------------------------------
# Final stage
# ------------------------------------------------------------------------------

FROM ubuntu:20.04

# Install Rust
RUN apt-get update \
  && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
    cargo \
    rustc \
  && rm -rf /var/lib/apt/lists/*

# Install Tarpaulin dependencies
RUN apt-get update \
  && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
    libssl-dev \
  && rm -rf /var/lib/apt/lists/*

# Install tarpaulin
RUN cargo install cargo-tarpaulin

COPY --from=proj_builder /build/usr/share/proj/ /usr/share/proj/
COPY --from=proj_builder /build/usr/include/ /usr/include/
COPY --from=proj_builder /build/usr/bin/ /usr/bin/
COPY --from=proj_builder /build/usr/lib/ /usr/lib/

