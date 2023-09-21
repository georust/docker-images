# https://hub.docker.com/orgs/georust/libproj-builder

# Builds libproj from source

ARG RUST_VERSION
FROM rust:$RUST_VERSION

ARG RUST_VERSION
ARG PROJ_VERSION
RUN test -n "$RUST_VERSION" || (echo "RUST_VERSION ARG not set" && false)
RUN test -n "$PROJ_VERSION" || (echo "PROJ_VERSION ARG not set" && false)

# Install dependencies
RUN apt-get update \
  && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
    clang \
    libcurl4-gnutls-dev \
    libsqlite3-dev \
    libtiff-dev \
    cmake \
    pkg-config \
    sqlite3 \
    wget \
  && rm -rf /var/lib/apt/lists/*

# Compile and install to /build
#
# Note libproj is not installed to a system directory, so that a staged build
# can install from this container using something like:
#
#    # PROJ stage
#    FROM libproj-builder as libproj-builder
#    ...
#    # Maybe some additional stages
#    ...
#    # Output Container
#    FROM my-base-image
#    ...
#    COPY --from=libproj-builder /build/usr /usr
#    ...
RUN wget https://github.com/OSGeo/PROJ/releases/download/${PROJ_VERSION}/proj-${PROJ_VERSION}.tar.gz
RUN tar -xzvf proj-${PROJ_VERSION}.tar.gz
RUN mv proj-${PROJ_VERSION} proj-src

# from https://proj.org/install.html
RUN mkdir /proj-src/build
WORKDIR /proj-src/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=/build/usr
RUN cmake --build . --target install -j $(nproc)

RUN rm -fr /proj-src
