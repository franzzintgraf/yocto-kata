#!/usr/bin/env bash

set -e

# VERSION is set by the devcontainer feature system
YOCTO_VERSION="${VERSION:-dunfell}"
echo "Installing Yocto tools for version: $YOCTO_VERSION"

function Error() {
    echo "Error: $1" >&2
    exit 1
}

function CheckSupportedDistro_dunfell() {
    . /etc/os-release
    case "$ID" in
        ubuntu)
            if [[ "$VERSION_ID" == "20.04" || "$VERSION_ID" == "22.04" ]]; then
                return 0
            fi
            ;;
    esac
    Error "Unsupported Linux distribution/version for dunfell: $PRETTY_NAME"
}

function CheckSupportedDistro_scarthgap() {
    . /etc/os-release
    case "$ID" in
        ubuntu)
            if [[ "$VERSION_ID" == "20.04" || "$VERSION_ID" == "22.04" || "$VERSION_ID" == "23.04" ]]; then
                return 0
            fi
            ;;
    esac
    Error "Unsupported Linux distribution/version for scarthgap: $PRETTY_NAME"
}

function InstallYoctoPackages_dunfell() {
    # https://docs.yoctoproject.org/3.1.33/ref-manual/ref-system-requirements.html
    CheckSupportedDistro_dunfell

    PACKAGES_YOCTO_ESSENTIALS="gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev xterm python3-subunit mesa-common-dev"
    PACKAGES_ADDITIONAL="file"

    apt-get update || return $?
    apt-get install -y --no-install-recommends \
        $PACKAGES_YOCTO_ESSENTIALS $PACKAGES_ADDITIONAL \
        || return $?

    # The official yocto documentation for dunfell still mentions to install pylint via apt, but it is not available in the ubuntu 20.04 repositories.
    # So we install it via pip.
    python3 -m pip install -U pylint || return $?
}

function InstallYoctoPackages_scarthgap() {
    # https://docs.yoctoproject.org/5.0.10/ref-manual/system-requirements.html
    CheckSupportedDistro_scarthgap

    PACKAGES_YOCTO_ESSENTIALS="build-essential chrpath cpio debianutils diffstat file gawk gcc git iputils-ping libacl1 liblz4-tool locales python3 python3-git python3-jinja2 python3-pexpect python3-pip python3-subunit socat texinfo unzip wget xz-utils zstd"

    apt-get update || return $?
    apt-get install -y --no-install-recommends \
        $PACKAGES_YOCTO_ESSENTIALS \
        || return $?
}

function InstallYoctoPackages() {
    local version="$1"
    case "$version" in
        dunfell)
            InstallYoctoPackages_dunfell
            ;;
        scarthgap)
            InstallYoctoPackages_scarthgap
            ;;
        # Add more Yocto versions here as needed
        *)
            Error "Unsupported Yocto version: $version. Please update install.sh for this version."
            ;;
    esac
}

function InstallKas() {
    python3 -m pip install -U kas || return $?
}

InstallYoctoPackages "$YOCTO_VERSION" || Error "Failed to install yocto packages"
InstallKas || Error "Failed to install python kas package"

echo "Done"
