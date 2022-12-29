# https://hub.docker.com/orgs/georust/libproj-builder

# Builds libproj from source

FROM rust:%RUST_VERSION%

# Install dependencies
RUN apt-get update \
  && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
    clang \
    libcurl4-gnutls-dev \
    libsqlite3-dev \
    libtiff5-dev \
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
RUN wget https://github.com/OSGeo/PROJ/releases/download/9.1.0/proj-9.1.0.tar.gz
RUN tar -xzvf proj-9.1.0.tar.gz
RUN mv proj-9.1.0 proj-src

# from https://proj.org/install.html
RUN mkdir /proj-src/build
WORKDIR /proj-src/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=/build/usr
RUN cmake --build . --target install -j $(nproc)

RUN rm -fr /proj-src
