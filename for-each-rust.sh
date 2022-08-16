#!/usr/bin/env zsh

declare -A pids
declare -A statuses

USAGE=$(cat <<-END
# $(basename $0)
Run a command for each version of rust

Usage to run for all versions:
    $(basename $0) --all -- <cmd>

Usage for specific versions:
    $(basename $0) <rust-dir-1 rust-dir-2> -- <cmd>


Example:
    $(basename $0) rust-1.56 rust-1.57 -- make

END
)

function usage_violation {
    echo "error: $@ \n"
    echo $USAGE
    exit 1
}

function expect_cmd {
    if [[ $1 == "--" ]]; then
        shift
        CMD=($@)
    else
        usage_violation 'expected `--` to start cmd'
    fi
}

case $1 in
"" | --help)
    echo "$USAGE"
    exit 0
  ;;
--all)
    rust_dirs=(rust-*)
    shift
    expect_cmd $@
  ;;
*)
    rust_dirs=()
    while [[ $1 != "" ]]; do
        next_arg=$1
        if [[ $next_arg == "--" ]]; then
            break
        fi

        if [ -d "$next_arg" ]; then
            rust_dirs+=("$next_arg")
            shift
        else
            usage_violation "directory doesn't exist: $next_arg"
            exit 1
        fi
    done
    expect_cmd $@
  ;;
esac

if [[ -z $CMD ]]; then
    usage_violation "no cmd set"
fi

# for every version of rust we support...
for rust_dir in $rust_dirs
do
    # run the given command in that rust-dir in parallel
    (cd $rust_dir && $CMD)&
    pids[$rust_dir]="$!"
done

echo pids $pids
for key pid in "${(@kv)pids}"
do
    wait $pid
    local pid_status=$?
    echo "finished $key (pid: $pid) with status: $pid_status"
    statuses[$key]=$pid_status
done

for key val in "${(@kv)statuses}"
do
    echo "$key completed with status: $val"
done
