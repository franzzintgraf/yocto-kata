SUMMARY = "MyProject Production Image"
LICENSE = "MIT"

inherit core-image

IMAGE_INSTALL += "\
    azure-iot-dummy-cli \
"
