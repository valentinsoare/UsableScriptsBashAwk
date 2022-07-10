#!/usr/bin/bash

pushd() {
    dirname="${1}"
    DIR_STACK=${dirname:-$PWD' '}
    cd ${dirname:?"missing directory name."}
    echo "${DIR_STACK}"
}

popd () {
    DIR_STACK="${DIR_STACK#* }"
    cd "${DIR_STACK%% *}"
    echo "${PWD}"
}

