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

**New images are built by Github Actions and published to the Github Container Registry if tests pass**

## How to Update the Rust Version


### Add a new Rust version

edit the `.github/workflows/imagebuild.yml` file

Add the Rust version you wish to add to the **two** `rust_version` matrices:  

#### Example

    Before:  rust_version: [1.74, 1.75, 1.76]
    After:  rust_version: [1.74, 1.75, 1.76, 1.77]

## How to Update Proj

libproj (the cpp lib) is built using the [docker container builder
pattern](https://docs.docker.com/develop/develop-images/multistage-build/), and
then reused by multiple CI containers.

    edit the `LIBPROJ_VERSION` variable in `imagebuild.yml`


### Update the `proj` crate

- update the compressed `PROJ` version in [the proj repo](https://github.com/georust/proj/proj-sys/PROJSRC)
- Edit the adjacent [https://github.com/georust/proj/proj-sys/build.rs](`build.rs`) to look for the updated PROJ version
- Bump the `proj-sys` version and update `proj/Cargo.toml` to use it.

### Update the `geo` crate

- When the PR has merged and the `proj` crate has been published, you can update [geo](https://github.com/georust/geo) to use the new `proj` crate:

