SUMMARY = "Old style example recipe with deprecated syntax"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://greet.sh"

S = "${WORKDIR}"

INHIBIT_PACKAGE_DEBUG_SPLIT = "1"

do_install_append() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/greet.sh ${D}${bindir}/greet
}
