GEORUST_ROOT=$(CURDIR)/../..
DOCKER_TAG=rust-%RUST_VERSION%
# On x86 Linux or Mac, you should be able to do a plain `docker build`
DOCKER_BUILD_CMD=docker build

# WIP: On macos w/ apple silicon (aarch64), you'll need buildx to output the proper
# platform/arch for CI.
# Currently though, this seems to output a libproj.a that's not usable.
# DOCKER_BUILD_CMD=docker buildx build --platform linux/amd64 --push

default: build-all

build-all: libproj-builder proj-ci-without-system-proj proj-ci geo-ci

geo-ci:
	$(DOCKER_BUILD_CMD) -f geo-ci.Dockerfile -t georust/geo-ci:$(DOCKER_TAG) .

proj-ci:
	$(DOCKER_BUILD_CMD) -f proj-ci.Dockerfile -t georust/proj-ci:$(DOCKER_TAG) .

proj-ci-without-system-proj:
	$(DOCKER_BUILD_CMD) -f proj-ci-without-system-proj.Dockerfile -t georust/proj-ci-without-system-proj:$(DOCKER_TAG) .

libproj-builder:
	$(DOCKER_BUILD_CMD) -f libproj-builder.Dockerfile -t georust/libproj-builder:$(DOCKER_TAG) .

publish-all: publish-libproj-builder publish-proj-ci-without-system-proj publish-proj-ci publish-geo-ci

publish-all-latest: DOCKER_TAG=latest
publish-all-latest: publish-all

publish-geo-ci:
	docker push georust/geo-ci:$(DOCKER_TAG)

publish-proj-ci:
	docker push georust/proj-ci:$(DOCKER_TAG)

publish-proj-ci-without-system-proj:
	docker push georust/proj-ci-without-system-proj:$(DOCKER_TAG)

publish-libproj-builder:
	docker push georust/libproj-builder:$(DOCKER_TAG)

geo-ci-shell:
	docker run -ti -v $(GEORUST_ROOT):/tmp/georust georust/geo-ci:$(DOCKER_TAG) bash -l

libproj-builder-shell:
	docker run -ti -v $(GEORUST_ROOT):/tmp/georust georust/libproj-builder:$(DOCKER_TAG) bash -l

proj-ci-without-system-proj-shell:
	docker run -ti -v $(GEORUST_ROOT):/tmp/georust georust/proj-ci-without-system-proj:$(DOCKER_TAG) bash -l

proj-ci-shell:
	docker run -ti -v $(GEORUST_ROOT):/tmp/georust -w /tmp/georust/proj georust/proj-ci$(DOCKER_TAG) bash -l

run-all: run-proj-ci run-proj-sys-ci run-geo-ci

run-geo-ci:
	echo 1 \
		&& docker run -v $(GEORUST_ROOT):/tmp/georust -w /tmp/georust/geo georust/geo-ci:$(DOCKER_TAG) /bin/bash -c "cargo test --no-default-features && cargo test && cargo test --all-features"

run-proj-ci:
	echo 1 \
		&& docker run -v $(GEORUST_ROOT):/tmp/georust -w /tmp/georust/proj georust/proj-ci:$(DOCKER_TAG) cargo test --no-default-features \
		&& docker run -v $(GEORUST_ROOT):/tmp/georust -w /tmp/georust/proj georust/proj-ci:$(DOCKER_TAG) cargo test --features bundled_proj \
		&& docker run -v $(GEORUST_ROOT):/tmp/georust -w /tmp/georust/proj georust/proj-ci:$(DOCKER_TAG) cargo test --features network

run-proj-sys-ci:
	echo 1 \
		&& docker run -v $(GEORUST_ROOT):/tmp/georust -w /tmp/georust/proj/proj-sys --env "_PROJ_SYS_TEST_EXPECT_BUILD_FROM_SRC=1" georust/proj-ci-without-system-proj:$(DOCKER_TAG) cargo test \
	    && docker run -v $(GEORUST_ROOT):/tmp/georust -w /tmp/georust/proj/proj-sys --env "_PROJ_SYS_TEST_EXPECT_BUILD_FROM_SRC=0" georust/proj-ci:$(DOCKER_TAG) cargo test \
	    && docker run -v $(GEORUST_ROOT):/tmp/georust -w /tmp/georust/proj/proj-sys --env "_PROJ_SYS_TEST_EXPECT_BUILD_FROM_SRC=1" georust/proj-ci:$(DOCKER_TAG) cargo test --features bundled_proj
