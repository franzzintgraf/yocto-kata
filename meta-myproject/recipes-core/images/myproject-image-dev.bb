SUMMARY = "MyProject Development Image"
LICENSE = "MIT"

inherit core-image

IMAGE_FEATURES += "debug-tweaks ssh-server-dropbear"

IMAGE_INSTALL += "\
    hello \
    azure-iot-dummy-cli \
    hello-world-cpp \
"
