#!/usr/bin/env zsh

declare -A pids
declare -A statuses
declare -a rust_versions

USAGE=$(cat <<-END
# $(basename $0)
Run a command for each version of rust

Usage to run for all versions:
    $(basename $0) --all -- <cmd>

Usage for specific versions:
    $(basename $0) <rust-version-1 rust-version-2> -- <cmd>


Example:
    $(basename $0) 1.56 1.57 -- make

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
    rust_versions=("${(f)"$(<rust-versions.txt)"}")
    shift
    expect_cmd $@
  ;;
*)
    rust_versions=()
    while [[ $1 != "" ]]; do
        next_arg=$1
        if [[ $next_arg == "--" ]]; then
            break
        fi
        rust_versions+=("$next_arg")
        shift
    done
    expect_cmd $@
  ;;
esac

if [[ -z $CMD ]]; then
    usage_violation "no cmd set"
fi

proj_version=$(sed '/^$/d' ./proj-version.txt)
# for every version of rust we support...
for rust_version in $rust_versions
do
    # run the given command for each rust-version in parallel
    (PROJ_VERSION="$proj_version" RUST_VERSION="$rust_version" $CMD)&
    pids[$rust_version]="$!"
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
