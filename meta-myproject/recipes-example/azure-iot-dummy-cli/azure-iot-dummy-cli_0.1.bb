SUMMARY = "Azure IoT dummy CLI app sending telemetry using connection string"
DESCRIPTION = "Minimal Azure IoT client using the Azure IoT SDK to send dummy temperature and humidity data"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://main.cpp \
           file://CMakeLists.txt"

S = "${WORKDIR}"

inherit cmake

DEPENDS = "azure-iot-sdk-c"
RDEPENDS:${PN} += "azure-iot-sdk-c"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${B}/azure-iot-dummy-cli ${D}${bindir}/azure-iot-dummy-cli
}