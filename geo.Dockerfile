# https://hub.docker.com/orgs/georust/geo-ci

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

# Install PROJ dependencies
RUN apt-get update \
  && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
    clang \
    libcurl4-gnutls-dev \
    libsqlite3-dev \
    libtiff5-dev \
    make \
    pkg-config \
    sqlite3 \
    wget \
  && rm -rf /var/lib/apt/lists/*

# Compile and install PROJ
RUN wget https://github.com/OSGeo/PROJ/releases/download/7.0.1/proj-7.0.1.tar.gz \
  && tar -xzvf proj-7.0.1.tar.gz \
  && cd proj-7.0.1 \
  && ./configure --disable-dependency-tracking --prefix=/usr \
  && make \
  && make install \
  && cd .. \
  && rm -rf proj-7.0.1.tar.gz \
  && rm -rf proj-7.0.1
