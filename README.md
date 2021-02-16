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

i.e. assume we're adding support for rust 1.50.

    cp -r rust-1.49 rust-1.50
    # edit all Dockerfiles and tags to refer to rust-1.50 instead of rust-1.49
    vim rust-1.50/*

    # optionally drop support for old unsupported versions
    rm -fr rust-1.49

Push this to a branch, i.e. "mkirk/rust-1.50" and open a Draft PR, e.g.
https://github.com/georust/docker-images/pulls/11

### add builds to Dockerhub

1. Add a new automated build to dockerhub for each container for the new rust
   version.  Note: The libproj-builder's container build must be done before
   the others, since our other containers depend on libproj-builder.
  1. https://hub.docker.com/repository/docker/georust/libproj-builder/builds/edit
  2. Add new "Build Rule" with:
    1. Source Type: branch
    2. Source: mkirk/rust-1.50 (after our PR is merged, we'll have to replace this with `master`)
    3. Docker Tag: rust-1.50
    4. Dockerfile location: rust-1.50/libproj-builder.Dockerfile
  3. Save and start that build. Once it's complete, you can repeat the process
     for the other containers (geo-ci, proj-ci, proj-ci-without-system-proj)

### Verify the new containers work

Open a PR in the affected repositories referencing the new containers, e.g. https://github.com/georust/docker-images/pull/11.

Make sure that CI successfully runs against the new containers.

### Merge ahoy!

If your new CI containers passed their tests, everything can be merged. 

The Dockerhub builds added should be updated to build from master, rather than
your PR branch. This is annoying, but I'm not sure of a better way.

## How to Update Proj

libproj (the cpp lib) is built using the [docker container builder
pattern](https://docs.docker.com/develop/develop-images/multistage-build/), and
then reused by multiple CI containers.

In this example, we'll be updating to `PROJ 7.2.1` for rust-1.49.

1. cd rust-1.49
2. Edit `libproj-builder.Dockerfile` to download and build `PROJ` 7.2.1
3. Build the image, tagging it with the corresponding rust version: `docker build -t georust/libproj-builder:rust-1.50 -f libproj-builder.Dockerfile .`
4. You can now update the two child `proj` Dockerfiles in this repo to use the new `libproj-builder` tag.
5. `docker build -t georust/proj-ci:rust-1.50 -f proj-ci.Dockerfile .`
6. `docker build -t georust/proj-ci-without-system-proj:rust-1.50 -f proj-ci-without-system-proj.Dockerfile .`
7. Clobber the existing `rust-1.50` tag for these three images on Docker Hub
  - `docker push georust/libproj-builder:rust-1.50`
  - `docker push georust/proj-ci:rust-1.50`
  - `docker push georust/proj-ci-without-system-proj:rust-1.50`
8. Update the `proj` crate
  - update the compressed `PROJ` version in [the proj repo](https://github.com/georust/proj/proj-sys/PROJSRC)
  - Edit the adjacent [https://github.com/georust/proj/proj-sys/build.rs](`build.rs`) to look for the updated PROJ version
  - Bump the `proj-sys` version and update `proj/Cargo.toml` to use it.
9. Update the `geo` crate
  - When the PR has merged and the `proj` crate has been published, you can update [geo](https://github.com/georust/geo) to use the new `proj` crate:
10. Rebuild the `geo-ci.Dockerfile` which will pull in the updated `libproj-builder` tag, then push it to Docker hub.
