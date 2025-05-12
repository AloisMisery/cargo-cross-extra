#!/bin/bash
set -eu -o pipefail

# -----------------------------------------------------------------------------

function get_macos_sdk_url() {
    local sdk_version="$1"
    echo "https://github.com/joseluisq/macosx-sdks/releases/download/${sdk_version}/MacOSX${sdk_version}.sdk.tar.xz"
}

# -----------------------------------------------------------------------------

mkdir -p ./_build

cd ./_build

git clone https://github.com/cross-rs/cross
cd cross
git submodule update --init --remote



COMMON_OPTS=(
    # '--repository=ghcr.io/aloismisery'
    '--repository=docker.io/aloismisery'
    '--tag=extra'

    '-v'
    '--push'

    # --cache-from 'type=registry,ref={base_name}:main'
    # --cache-to
)


if [[ -n ${CI:-} ]]; then
    COMMON_OPTS+=(
        '--cache-from=type=gha'
        '--cache-to=type=gha,mode=max'
    )
fi



build__x86_64-pc-windows-msvc() {
    cargo build-docker-image x86_64-pc-windows-msvc-cross "${COMMON_OPTS[@]}"
}

build__i686-pc-windows-msvc() {
    cargo build-docker-image i686-pc-windows-msvc-cross "${COMMON_OPTS[@]}"
}

build__aarch64-pc-windows-msvc() {
    cargo build-docker-image aarch64-pc-windows-msvc-cross "${COMMON_OPTS[@]}"
}

build__x86_64-apple-darwin() {
    cargo build-docker-image x86_64-apple-darwin-cross "${COMMON_OPTS[@]}" \
        --build-arg "MACOS_SDK_URL=$(get_macos_sdk_url "11.3")"
}

build__i686-apple-darwin() {
    cargo build-docker-image i686-apple-darwin-cross "${COMMON_OPTS[@]}" \
        --build-arg "MACOS_SDK_URL=$(get_macos_sdk_url "10.9")"
}

build__aarch64-apple-darwin() {
    cargo build-docker-image aarch64-apple-darwin-cross "${COMMON_OPTS[@]}" \
        --build-arg "MACOS_SDK_URL=$(get_macos_sdk_url "12.3")"
}


build__"$1"
