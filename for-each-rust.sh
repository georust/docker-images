#!/usr/bin/env zsh

declare -A pids
declare -A statuses

# for every version of rust we support...
for rust_dir in rust-*
do
    # run the given command in that rust-dir in parallel
    (cd $rust_dir && $@)&
    pids[$rust_dir]="$!"
done

echo pids $pids
for key pid in "${(@kv)pids}"
do
    wait $pid
    echo "finished $key (pid: $pid)"
    statuses[$key]=$?
done

for key val in "${(@kv)statuses}"
do
    echo "$key completed with status: $val"
done
