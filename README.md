# GeoRust Docker Images

Configuration for Docker containers used by georust projects, primarily for CI.

## Supporting Multiple Versions with Docker Tags

Not everyone is running the latest and greatest of everything at the same time,
so it makes sense to support a reasonable window of dependencies.

Unlike a `git tag`, a `tag` in Docker is not conventionally treated as an
immutable alias to a precise single state. Rather, it's more like a named
"release track" or "semver constraint". 

Using the official Rust Docker containers as an example, the `rust:1.45` tag
should be read as "the latest container published for rust >=1.45.0 <1.46". The
`rust:1.45` tag initially referred to the 1.45.0 release, but was
later [updated to refer to the 1.45.1 release, and then again to the 1.45.2
release](https://hub.docker.com/_/rust?tab=tags&page=1&ordering=last_updated&name=1.45).
This is by design - a docker tag does not have the same goals as a git tag.

We lean into this strategy of "docker tag as semver". The current stable
version of Rust is 1.50.0, so if I published `geo-ci:rust-1.50` today based on
`rust:1.50`, it would include rustc 1.50.0. If Rust later publishes a
hypothetical 1.50.1 release, they would update their `rust:1.50` container.  It
would be entirely normal and expected that I would rebuild at that point, and
clobber our `geo-ci:rust-1.50` tag with a new image based on rust 1.50.1.

If we did want to use only a very specific rust version, rust publishes the 3
number tag as well, e.g. `rust:1.45.1`. Similarly we could publish a new tag
for each minor patch (`geo-ci:rust-1.50.0`, `geo-ci:rust-1.50.1`, etc.), but
running CI against each patch seems like overkill at this point.

## How to Update Rust

### add a new set of Dockerfiles

i.e. assume we're adding support for rust 1.53.

    ./generate 1.53

    # build containers
    make build-all

    # run some tests on the new containers
    make test-all

    # If everythig looks good, you can publish the new tags
    make publish-all

    # optionally drop support for old unsupported versions
    rm -fr rust-1.49
 
## How to Update Proj

libproj (the cpp lib) is built using the [docker container builder
pattern](https://docs.docker.com/develop/develop-images/multistage-build/), and
then reused by multiple CI containers.

In this example, we'll be updating to `PROJ 7.2.1`

### Update CI Docker containers

Edit `template/libproj-builder.Dockerfile` to download and build `PROJ` 7.2.1

Then, for each supported version of rust (in this example, rust-1.49):

    # remove old docker files
    rm -fr rust-1.49
    # regenerate the docker files
    ./generate 1.49
    cd rust-1.49
    # rebuild the containers
    make build-all
    # retest the containers
    make test-all
    # republish the containers
    make publish-all

### Update the `proj` crate

- update the compressed `PROJ` version in [the proj repo](https://github.com/georust/proj/proj-sys/PROJSRC)
- Edit the adjacent [https://github.com/georust/proj/proj-sys/build.rs](`build.rs`) to look for the updated PROJ version
- Bump the `proj-sys` version and update `proj/Cargo.toml` to use it.

### Update the `geo` crate

- When the PR has merged and the `proj` crate has been published, you can update [geo](https://github.com/georust/geo) to use the new `proj` crate:
