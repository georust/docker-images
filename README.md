# Georust Docker Images

## Instructions for updating `proj` Docker images, the `proj` crate, and the `proj` version in use by the `geo` crate

In this example, we'll be updating to `PROJ 7.2.1`, using the tag name `proj-7.2.1`


1. Edit `libproj-builder.Dockerfile` to download and build `PROJ` 7.2.1
2. Build the image, tagging it with the new `PROJ` version: `docker build -t georust/libproj-builder:proj-7.2.1 -f libproj-builder.Dockerfile .`
3. Push the new tag to Docker Hub: `docker push georust/libproj-builder:proj-7.2.1`
4. You can now update the two child `proj` Dockerfiles in this repo to use the new `libproj-builder` tag. Then build and push them:
5. `docker build -t georust/proj-ci:proj-7.2.1 -f proj-ci.Dockerfile .`
6. `docker push georust/proj-ci:proj-7.2.1`
7. `docker build -t georust/proj-ci-without-system-proj:proj-7.2.1 -f proj-ci-without-system-proj.Dockerfile .`
8. `docker push georust/proj-ci-without-system-proj:proj-7.2.1`
9. The three images should now each have a new tag, `proj-7.2.1` on Docker Hub
10. You can now update the compressed `PROJ` version in [the proj repo](https://github.com/georust/proj/proj-sys/PROJSRC)
11. Edit the adjacent [https://github.com/georust/proj/proj-sys/build.rs](`build.rs`) to look for the updated version
12. Finally, edit https://github.com/georust/proj/.github/workflows/test.yml to use the Docker images with the new tag, and open a PR to test your changes
13. When the PR has merged and the `proj` crate has been published, you can update [geo](https://github.com/georust/geo) to use the new `proj` crate:
14. Modify `geo-ci.Dockerfile` to use the latest `libproj-builder` tag, then build _it_ with a new tag, and push it to Docker hub
15. You can now modify the `geo` test script to use the new `geo-ci` Docker tag, allowing the updated `proj` crate version in use by `geo` to be tested using the correct Docker images.
