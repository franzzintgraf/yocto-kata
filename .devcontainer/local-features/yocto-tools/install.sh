#!/usr/bin/env bash

set -e

function Error() {
    echo "Error: $1" >&2
    exit 1
}

function AptInstall() {
    apt-get update || return $?
    apt-get install -y --no-install-recommends \
        build-essential \
        chrpath \
        cpio \
        debianutils \
        diffstat \
        file \
        gawk \
        gcc \
        git \
        iputils-ping \
        libacl1 \
        liblz4-tool \
        locales \
        python3 \
        python3-git \
        python3-jinja2 \
        python3-pexpect \
        python3-pip \
        python3-subunit \
        socat \
        texinfo \
        unzip \
        wget \
        xz-utils \
        zstd || return $?
}

function PipInstall() {
    python3 -m pip install -U kas || return $?
}

AptInstall || Error "Failed to install apt packages"
PipInstall || Error "Failed to install pip packages"

echo "Done"
