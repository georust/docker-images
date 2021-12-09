#!/usr/bin/env bash

pids=()

# for every version of rust we support...
for rust_dir in rust-* 
do   
    # run the given command in that rust-dir in parallel
    (cd $rust_dir && $@)&
    pids+=($!)
done  

for pid in "${pids[@]}"; do
    wait "$pid"
    echo "waited pid: $pid"
done
