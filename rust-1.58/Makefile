GEORUST_ROOT=$(CURDIR)/../..
DOCKER_TAG=rust-1.58
DOCKER_BUILD_CMD=docker build
DOCKER_RUN_CMD=docker run -v $(GEORUST_ROOT):/tmp/georust -e CARGO_TARGET_DIR=/tmp/cargo-target

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
	$(DOCKER_RUN_CMD) -ti georust/geo-ci:$(DOCKER_TAG) bash -l

libproj-builder-shell:
	$(DOCKER_RUN_CMD) -ti georust/libproj-builder:$(DOCKER_TAG) bash -l

proj-ci-without-system-proj-shell:
	$(DOCKER_RUN_CMD) -ti georust/proj-ci-without-system-proj:$(DOCKER_TAG) bash -l

proj-ci-shell:
	$(DOCKER_RUN_CMD) -ti -w /tmp/georust/proj georust/proj-ci:$(DOCKER_TAG) bash -l

test-all: test-proj-ci test-proj-sys-ci test-geo-ci

test-geo-ci:
	echo 1 \
		&& $(DOCKER_RUN_CMD) -w /tmp/georust/geo georust/geo-ci:$(DOCKER_TAG) /bin/bash -c "cargo test --no-default-features && cargo test && cargo test --all-features"

test-proj-ci:
	echo 1 \
		&& $(DOCKER_RUN_CMD) -w /tmp/georust/proj georust/proj-ci:$(DOCKER_TAG) cargo test --no-default-features \
		&& $(DOCKER_RUN_CMD) -w /tmp/georust/proj georust/proj-ci:$(DOCKER_TAG) cargo test --features bundled_proj \
		&& $(DOCKER_RUN_CMD) -w /tmp/georust/proj georust/proj-ci:$(DOCKER_TAG) cargo test --features network

test-proj-sys-ci:
	echo 1 \
		&& $(DOCKER_RUN_CMD) -w /tmp/georust/proj/proj-sys --env "_PROJ_SYS_TEST_EXPECT_BUILD_FROM_SRC=1" georust/proj-ci-without-system-proj:$(DOCKER_TAG) cargo test \
	    && $(DOCKER_RUN_CMD) -w /tmp/georust/proj/proj-sys --env "_PROJ_SYS_TEST_EXPECT_BUILD_FROM_SRC=0" georust/proj-ci:$(DOCKER_TAG) cargo test \
	    && $(DOCKER_RUN_CMD) -w /tmp/georust/proj/proj-sys --env "_PROJ_SYS_TEST_EXPECT_BUILD_FROM_SRC=1" georust/proj-ci:$(DOCKER_TAG) cargo test --features bundled_proj
