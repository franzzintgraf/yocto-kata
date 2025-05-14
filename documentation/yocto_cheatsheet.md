# Yocto / BitBake Cheat Sheet

## 🏗️ Project Structure Overview

### Project Structure

```bash
poky/                      # Yocto reference distribution
├── meta/                  # Core metadata
├── meta-poky/             # Poky distro layer
├── meta-yocto-bsp/        # BSPs for reference boards
├── build/                 # Build output dir
│   ├── conf/local.conf    # Local configuration
│   └── conf/bblayers.conf # List of active layers
```

### Recipe Folder Structure

```bash
recipes-<category>/
├── <recipe-name>/
│   ├── <recipe-name>_<version>.bb     # Main BitBake recipe file
│   ├── <recipe-name>.bbappend         # Optional recipe extension
│   ├── files/                         # Custom files like patches, configs, scripts
│   │   ├── fix-compile.patch          # Example patch file
│   │   └── custom.conf                # Example config file
│   └── README.md                      # Optional recipe-specific documentation
```

**Explanation:**

* `recipes-<category>/`: Logical grouping by category, e.g., `recipes-core`, `recipes-network`, `recipes-apps`.
* `<recipe-name>_<version>.bb`: Defines how to fetch, build, and package the software.
* `.bbappend`: Allows extending an existing recipe from another layer.
* `files/`: Contains static assets and patch files referenced in `SRC_URI`.
* `README.md`: Optional but useful for documentation.

### Key File Types

```bash
*.bb           # BitBake recipe
*.bbappend     # Recipe extension
*.bbclass      # Class (shared logic)
local.conf     # Project-wide config
bblayers.conf  # Layer config
machine.conf   # Machine-specific config
distro.conf    # Distro policy config
image.bb       # Custom image recipe
```

## ⚙️ System Configuration

### Discovering Configuration Info

```bash
bitbake -e virtual/kernel | grep '^LINUX_VERSION'  # Show kernel version
bitbake -e | grep '^MACHINE='                      # Show current machine
bitbake -e | grep '^DISTRO='                       # Show current distribution
```

### System-Wide Configuration Variables

```bash
MACHINE               # Target hardware machine (set in local.conf)
DISTRO                # Distribution policy (e.g., poky)
DL_DIR                # Download directory for source archives
SSTATE_DIR            # Shared state directory (sstate cache)
TMPDIR                # Temporary build directory
PACKAGE_CLASSES       # Package format (e.g., package_ipk, package_rpm)
INIT_MANAGER          # Init system used (e.g., sysvinit, systemd)
BASE_DIR              # Base directory of the build system
CONF_VERSION          # Configuration version compatibility indicator
SDKMACHINE            # Machine to build SDK for (e.g. x86_64)
BB_NUMBER_THREADS     # Number of threads BitBake can spawn
PARALLEL_MAKE         # Number of parallel make jobs
USER_CLASSES          # Extra build features (e.g. buildstats)
BBMASK                # Mask out recipes/layers matching this pattern
```

### Listing Machines and Distros

```bash
find ../ -type f -path "*/conf/machine/*.conf"   # List all available machines
find ../ -type f -path "*/conf/distro/*.conf"    # List available distro definitions
```

## 🔧 BitBake Command Reference

### Common BitBake Commands

```bash
bitbake <recipe>                      # Build the specified recipe
bitbake -c clean <recipe>             # Clean recipe build artifacts
bitbake -c cleansstate <recipe>       # Remove and re-fetch sources, rebuild from scratch
bitbake -c compile <recipe>           # Compile recipe (won't fetch/patch)
bitbake -c configure <recipe>         # Run configure step
bitbake -c menuconfig virtual/kernel  # Launch kernel config
bitbake -e <recipe>                   # Show environment for recipe
bitbake-layers show-layers            # List all layers
bitbake-layers show-recipes           # List all recipes
bitbake-layers show-appends           # Show bbappend usage
```

### Common Variables

```bash
PN                          # Recipe name
PV                          # Version
PR                          # Revision
SUMMARY                     # Short description of the recipe
DESCRIPTION                 # Long description
SECTION                     # Logical category (e.g., console/utils)
HOMEPAGE                    # Project homepage URL
BUGTRACKER                  # URL for bug tracking
SRC_URI                     # Source URLs for fetching source code
SRCREV                      # Git revision to fetch (when using git)
S                           # Source dir (after unpack)
B                           # Build dir
WORKDIR                     # Working directory
EXTRA_OECONF                # Extra options for configure step
EXTRA_OEMAKE                # Extra options for make step
CFLAGS, LDFLAGS             # Compiler and linker flags
DEPENDS                     # Build-time dependencies
RDEPENDS_${PN}              # Runtime dependencies
RRECOMMENDS_${PN}           # Recommended packages
FILES_${PN}                 # Files to include in package
INSANE_SKIP                 # Skip QA checks for specific issues
LICENSE                     # License (e.g., GPLv2, MIT)
LIC_FILES_CHKSUM            # License checksum (for compliance)
INHIBIT_PACKAGE_DEBUG_SPLIT # Avoid debug package generation (if needed)
```

### Important BitBake Tasks (do_*)

```bash
do_fetch        # Fetch sources from SRC_URI
do_unpack       # Unpack downloaded source archives
do_patch        # Apply patches specified in SRC_URI
do_configure    # Run configure step for the source
do_compile      # Compile the source code
do_install      # Install built artifacts to the D staging dir
do_package      # Package files into .ipk/.rpm/.deb
do_rootfs       # Generate the root filesystem
do_image        # Create image files (e.g. .ext4, .wic)
do_deploy       # Deploy images or artifacts to deploy dir
```

### CMake based example recipe

```bash
SUMMARY = "Short description of your project"
DESCRIPTION = "Longer explanation of what the project does"
HOMEPAGE = "https://example.com/myproject"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=<insert-correct-md5>"

SRC_URI = "git://github.com/yourname/myproject.git;branch=main"
SRCREV = "${AUTOREV}"  # or pin to a commit

S = "${WORKDIR}/git"

inherit cmake

# --- Build-time dependencies (for compilation, linking, headers) ---
DEPENDS = "boost openssl"

# --- Runtime dependencies (for installed binary to work) ---
RDEPENDS:${PN} += "libstdc++ libgcc"

# Optional: specify CMake flags
EXTRA_OECMAKE += "-DSOME_OPTION=ON"

# Optional: install to custom paths
do_install:append() {
    # install additional files if needed
    # install -m 0644 ${S}/config.ini ${D}${sysconfdir}/myproject/
}
```

### Makefile based example recipe

```bash
SUMMARY = "Short description of your project"
DESCRIPTION = "Longer explanation of what the project does"
HOMEPAGE = "https://example.com/myproject"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=<insert-correct-md5>"

SRC_URI = "git://github.com/yourname/myproject.git;branch=main"
SRCREV = "${AUTOREV}"

S = "${WORKDIR}/git"

inherit pkgconfig

# --- Build-time dependencies ---
DEPENDS = "openssl zlib"

# --- Runtime dependencies ---
RDEPENDS:${PN} += "libgcc libstdc++"

EXTRA_OEMAKE = " \
    CC='${CC}' \
    CXX='${CXX}' \
    LD='${LD}' \
    AR='${AR}' \
    STRIP='${STRIP}' \
    CFLAGS='${CFLAGS}' \
    LDFLAGS='${LDFLAGS}' \
"

do_compile() {
    oe_runmake
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 myproject ${D}${bindir}
}
```

## 📦 Image Management

### Building Images

```bash
bitbake core-image-minimal         # Smallest image
bitbake core-image-full-cmdline    # With more CLI tools
bitbake core-image-sato            # GUI example
```

### Creating a Custom Image

```bash
# my-image.bb
DESCRIPTION = "My custom image"
LICENSE = "MIT"
inherit core-image
IMAGE_INSTALL += "nano htop my-app"
```

### Finding Available Images

```bash
bitbake-layers show-recipes | grep image       # Show all available image recipes
```

## 🧪 Development Tools

### devtool Commands

```bash
devtool add <name> <srcpath>     # Add new recipe
devtool modify <recipe>          # Modify existing recipe
devtool build <recipe>           # Build recipe with changes
devtool finish <recipe> <layer>  # Save changes to layer
```

### Layer Management

```bash
bitbake-layers create-layer ../meta-mylayer
bitbake-layers add-layer ../meta-mylayer
```

## 🐞 Debugging and Inspection

### Recipe Debugging

```bash
bitbake -c devshell <recipe>     # Open dev shell in build env
bitbake -c log <task> <recipe>   # Show log (older Yocto)
less tmp/work/.../temp/log.do_compile.XXX
```

### Metadata & Recipe Searching

```bash
bitbake -s                        # Show available recipes
bitbake-layers show-overlayed    # Show overridden recipes
oe-pkgdata-util find-path <file>
```

## ✅ Best Practices

* Use `meta-` prefix for custom layers
* Use `bbappend` for extending existing recipes
* Place patches in `files/` directory and reference via `SRC_URI`
* Add custom layers to `bblayers.conf`
* Don’t modify upstream `meta/` layers directly

## 📚 Documentation Resources

* [Yocto Project Docs](https://docs.yoctoproject.org/)
* [BitBake User Manual](https://docs.yoctoproject.org/bitbake/)
* [OpenEmbedded Layer Index](https://layers.openembedded.org/)
* [Devtool Documentation](https://docs.yoctoproject.org/dev/dev-manual/devtool.html)

---
