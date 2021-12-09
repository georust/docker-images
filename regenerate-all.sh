#!/usr/bin/env bash

set -e
for RUST_DIR in rust-*
do
    RUST_VERSION=$(echo $RUST_DIR | sed 's/rust-//')
    rm -r $RUST_DIR
    ./add-version.sh $RUST_VERSION
done

