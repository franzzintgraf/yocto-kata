# 📦 Kata Part 5: Integrating an Azure IoT Application with meta-iot-cloud

In this step, we expand our custom Yocto image by integrating a real application: a simple CLI-based telemetry sender for Azure IoT Hub using the Azure IoT SDK. This is an excellent way to practice using external layers, managing dependencies, and structuring recipes that interact with third-party CMake-based libraries.

---

## 🎯 Objective

- Choose and add a layer that provides the Azure IoT SDK
- Create a custom application (`azure-iot-dummy-cli`) that links against the SDK
- Use BitBake features (`DEPENDS`, `RDEPENDS`, `CMake`, `IMAGE_INSTALL`) to build and bundle the app into the root filesystem
- Troubleshoot issues like missing libraries, include paths, and login access

---

## 🔎 Step 1: Find a Suitable Azure Layer

We start by searching for "azure" in the official **Yocto Layer Index**:

📍 https://layers.openembedded.org/layerindex/branch/master/recipes/

The result:
- `meta-iot-cloud` (maintained by Intel IoT DevKit)
- Provides: `azure-iot-sdk-c`, `uamqp`, etc.

---

## 📥 Step 2: Add the Layer to Your Project

Clone the layer next to your other repositories (or let `kas` do it for you soon):

```bash
git clone -b dunfell https://github.com/intel-iot-devkit/meta-iot-cloud
```

Then add it to `kas.yml`:

```yaml
  meta-iot-cloud:
    url: "https://github.com/intel-iot-devkit/meta-iot-cloud"
    branch: "dunfell"
    layers:
      .:
```

---

## 🔗 Step 3: Resolve Layer Dependencies

When building with `bitbake` this will fail due to missing dependencies:

```
ERROR: Layer 'iot-cloud' depends on layer 'meta-python'
```

You can have a look into the readme of the layer to see what it depends on. In this case, `meta-iot-cloud` requires `meta-python` and `meta-networking` from `meta-openembedded`. This is a common pattern in Yocto layers, where one layer depends on another for additional functionality or libraries.
In addition you can look at the `LAYERDEPENDS` declaration in the layer’s `layer.conf` of the `meta-iot-cloud` layer.

To resolve it, we add the required sublayers from `meta-openembedded` to our `kas.yml`:

```yaml
  meta-openembedded:
    url: "https://github.com/openembedded/meta-openembedded"
    branch: "dunfell"
    layers:
      meta-oe:
      meta-python:
      meta-networking:
```

These layers provide common libraries used by many IoT/cloud-related packages.

---

## 🛠 Step 4: Write the Application Recipe

We add a custom C++ CLI app using the high-level Azure IoT SDK API. It accepts a connection string as a parameter and sends dummy telemetry.

### Directory structure:

```
meta-myproject/
└── recipes-example/
    └── azure-iot-dummy-cli/
        ├── azure-iot-dummy-cli_0.1.bb
        └── files/
            ├── main.cpp
            └── CMakeLists.txt
```

### BitBake recipe:

```bitbake
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
```

### 🧠 What is DEPENDS vs. RDEPENDS?

| Variable   | Meaning |
|------------|---------|
| `DEPENDS`  | Build-time dependency: the SDK or library must be built before compiling your recipe |
| `RDEPENDS` | Runtime dependency: the final image must include this package so your app works |

In our case, we needed them, because the recipe links dynamically to `azure-iot-sdk-c`, and that package is explicitly added to the image via `IMAGE_INSTALL`.


### CMake integration:

Have a look at the `CMakeLists.txt` file, not all projects use CMake files that are compatible with Yocto. In our case, we use the following:

```cmake
find_package(azure_iot_sdks REQUIRED)
target_link_libraries(azure-iot-dummy iothub_client uamqp)
```

This ensures correct linking.

---

## 🧪 Step 5: Add to the Image

In `kas.yml` under `local_conf_header`, extend the `IMAGE_INSTALL` variable to include your app:

```yaml
IMAGE_INSTALL:append = " azure-iot-dummy-cli"
```

This:
- Installs your app
- It's enough to just include the `azure-iot-dummy-cli` and the required shared libraries (from the Azure IoT SDK) will be pulled in automatically as they are defined in the `RDEPENDS` of the `azure-iot-dummy-cli` recipe.

---

## 🔐 Optional: Enable Console Login for Testing

In `kas.yml`:

```yaml
EXTRA_IMAGE_FEATURES += "debug-tweaks"
```

This allows:
- Root login without password on serial console
- Bash history and easier development

> ⚠️ Never use this in production.

## Run the app:
After building the image, boot it on your device. You can use the serial console to access the device.

```bash
azure-iot-dummy-cli "<your_connection_string>"
```
> Replace the placeholders with your actual Azure IoT Hub connection string. You can find the connection string in the Azure portal under your IoT Hub's "IoT devices" section. Select your device and copy the "Connection string (primary key)" value.

> ⚠️ Make sure that the date and time are set correctly on your device. If the date is not set, the connection to Azure IoT Hub will fail.

---

## ✅ Result

You now have:
- A real C++ app integrated with the Azure IoT SDK
- A fully automated build that includes the SDK and app
- Insight into real-world Yocto development with external layers

---

In the next part, we’ll learn how to create custom image(s) and how to build them with a restructured kas setup.

→ Continue to: [kata_part_6.md](kata_part_6.md)