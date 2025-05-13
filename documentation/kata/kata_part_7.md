# ⚙️ Kata Part 7: Creating Custom Yocto Images and Restructuring kas Configuration

In this part of the kata, we evolve from appending packages into `local.conf` toward defining **production-grade Yocto image recipes** and a **flexible `kas` overlay structure**. This step is essential for turning your Yocto build setup into a scalable, maintainable, and CI-ready project.

---

## 🎯 Goals of This Phase

- Learn the concept and purpose of Yocto image recipes
- Define separate dev and production images using best practices
- Remove `IMAGE_INSTALL` logic from `local.conf`
- Implement a clean, scalable kas overlay configuration system

---

## 🧠 What Is a Yocto Image Recipe?

A Yocto **image recipe** (`*.bb`) defines what gets installed into the **root filesystem** of a Linux image.

It controls:

- Which packages are installed (`IMAGE_INSTALL`)
- What system features are enabled (`IMAGE_FEATURES`)
- The overall composition of the system rootfs

But importantly, it does **not** dictate how the hardware boots — that’s the job of the **machine configuration** (e.g., `meta-raspberrypi`).

Image recipes typically inherit:

```bitbake
inherit core-image
```

This brings in all the required functionality for assembling and packaging a rootfs image.

---

## ✅ Best Practices for Image Recipes

| Practice                          | Reason |
|----------------------------------|--------|
| Put image recipes in `recipes-core/images/` | Yocto community convention |
| Inherit `core-image`             | Simplifies image creation |
| Avoid `local.conf` for packages  | Keeps configuration clean, reproducible |
| Separate dev/prod images         | Different needs: debug vs. secure/minimal |
| Use `IMAGE_FEATURES` appropriately | Enables SSH, root login, etc. |

---

## 🧱 Creating Our Own Images

We define two image recipes in our `meta-myproject` layer:

### 📄 `myproject-image-dev.bb`

```bitbake
SUMMARY = "MyProject Development Image"
LICENSE = "MIT"

inherit core-image

IMAGE_FEATURES += "debug-tweaks ssh-server-dropbear"

IMAGE_INSTALL += " \
    azure-iot-sdk-c \
    hello \
    oldstyle \
    azure-iot-dummy-cli \
"
```

This development image:
- Enables root login (`debug-tweaks`)
- Includes SSH server (`dropbear`)
- Adds testing/demo apps

---

### 📄 `myproject-image-prod.bb`

```bitbake
SUMMARY = "MyProject Production Image"
LICENSE = "MIT"

inherit core-image

IMAGE_INSTALL += " \
    azure-iot-sdk-c \
    azure-iot-dummy-cli \
"
```

The production image:
- Removes root login access (no `debug-tweaks`)
- Strips away extra dev packages
- Keeps footprint smaller

---

## 🔄 Transitioning from `local.conf` to Image Recipes

Previously, `kas.yml` contained logic like:

```yaml
local_conf_header:
  meta-myproject: |
    IMAGE_INSTALL:append = " hello oldstyle azure-iot-dummy-cpp-simple azure-iot-sdk-c"
    IMAGE_FEATURES += "debug-tweaks ssh-server-dropbear"
```

We moved all of this into the image recipes to:
- Improve readability
- Prevent accidental changes to dev/prod environments
- Make the image self-contained and reusable across machines

---

## 🧰 kas Configuration: The Scalable Way

To support multiple images and boards without hardcoding, we restructured the `kas` setup into a layered overlay system:

### 📁 Directory Layout

```
kas/
├── image/
│   ├── dev.yml
│   └── prod.yml
├── machine/
│   ├── rpi3.yml
│   └── rpi4.yml
kas.yml
```

---

### 📄 `kas.yml` (base config)

This contains:
- The repo/layer definitions
- No image or machine hardcoded

```yaml
repos:
  poky: ...
  meta-myproject: ...
  meta-raspberrypi: ...
```

---

### 📄 `kas/image/dev.yml`

```yaml
header:
  version: 18

target: myproject-image-dev

local_conf_header:
  dev_enable_uart: |
    ENABLE_UART = "1"
```

---

### 📄 `kas/image/prod.yml`

```yaml
header:
  version: 18

target: myproject-image-prod

local_conf_header:
  prod_disable_uart: |
    ENABLE_UART = "0"
```

---

### 📄 `kas/machine/rpi3.yml`

We can easily add a new machine overlay for the Raspberry Pi 3:
```yaml
header:
  version: 18

machine: raspberrypi3

local_conf_header:
  rpi4_defaults: |
    IMAGE_FSTYPES += "wic.bz2"
    ENABLE_UART ??= "0"
```

### 📄 `kas/machine/rpi4.yml`

```yaml
header:
  version: 18

machine: raspberrypi4

local_conf_header:
  rpi4_defaults: |
    IMAGE_FSTYPES += "wic.bz2"
    ENABLE_UART ??= "0"
```

> The `??=` syntax sets a **default** that can be overridden by the image overlays — this keeps machine and image concerns cleanly separated.

---

## ✅ Build Examples

`Kas` supports building any combination of image and machine using an **overlay** syntax by specifiying the overlay files in the command line separated by `:`.

```bash
kas build kas.yml:kas/image/dev.yml:kas/machine/rpi4.yml
kas build kas.yml:kas/image/prod.yml:kas/machine/rpi3.yml
```

This lets you build any image/machine combo, without editing the `kas.yml` file — ideal for CI automation or multi-target builds.

---

## 🧠 Takeaways

- **Images define what’s in the rootfs** — and should not touch machine-specific settings
- **Machine overlays define hardware config** — and should be overridable by the image if needed
- **kas overlays scale** — enabling image, machine, and environment separation
- **`??=` is key** — it lets machines provide defaults and images override them safely

---

## ✅ Result

You now have:
- A dev image for local testing with debugging features
- A production image for release with minimal footprint
- A clean, modular kas config layout

---

In the next part, we’ll learn how to patch a component using the `devtool`.

→ Continue to: [kata_part_8.md](kata_part_8.md)