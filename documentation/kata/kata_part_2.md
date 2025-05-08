# 🧠 Yocto Kata – Part 2: Setting Up the Build System and First Image Build

Welcome to Part 2 of the Yocto Kata. Now that your host is set up (see [Part 1](kata_part_1.md)), we’ll begin creating our own Yocto build environment:

- Clone and prepare Poky (Yocto reference distribution)
- Add Raspberry Pi support via meta-raspberrypi
- Understand the role of `bblayers.conf` and `local.conf`
- Build your first Linux image!

---

## 🗂️ Recap: What You Need Before Starting

- You’ve installed all host dependencies
- You’re using a Linux development machine
- You’ve got an internet connection and Git installed

---

## 📦 Step 1: Clone Poky

`poky` is the official Yocto Project reference distribution. It includes:

- BitBake (the task engine)
- Metadata (core recipes, images, configurations)
- Base layers: `meta`, `meta-poky`, `meta-yocto-bsp`

Clone it using:

```bash
git clone -b dunfell git://git.yoctoproject.org/poky
```

> 🔎 **Why `dunfell`?**  
> `dunfell` is an LTS (Long-Term Support) release, stable and widely used in production. By intend we are not using the latest version to be able to migrate to newer versions later in the kata.

---

## 🧩 Step 2: Clone the Raspberry Pi BSP Layer

To support Raspberry Pi 4, we need the official BSP (Board Support Package). You need to clone it into the `poky` directory:

```bash
cd poky
git clone -b dunfell https://git.yoctoproject.org/meta-raspberrypi
```

This layer contains:
- Raspberry Pi-specific kernel recipes
- Bootloader and GPU firmware setup
- Machine definitions for each Raspberry Pi model

---

## 📁 Step 3: Create the Build Directory

Now we initialize the build environment:

```bash
source oe-init-build-env rpi-build
```

This:
- Creates `rpi-build/`
- Sets up default config files under `rpi-build/conf/`
- Prepares your terminal session for BitBake commands

> You can replace `rpi-build` with any folder name — it's just your working build directory.

---

## ⚙️ Step 4: Understand `conf/bblayers.conf`

This file tells BitBake **which layers to use** in your build.

### Default example:

```conf
BBLAYERS ?= " \
  /path/to/poky/meta \
  /path/to/poky/meta-poky \
  /path/to/poky/meta-yocto-bsp \
"
```

### You must add `meta-raspberrypi`:

Edit `conf/bblayers.conf` and add:

```conf
  /path/to/meta-raspberrypi \
```

> 🧠 **Why layers?**  
> Layers allow you to isolate functionality, features, hardware, or even custom logic. This modularity is one of Yocto’s key strengths.

---

## 🛠️ Step 5: Understand `conf/local.conf`

This file controls **how** the build behaves. Think of it like a `Makefile.config`.

Key settings to add or modify:

```conf
MACHINE ?= "raspberrypi4"
IMAGE_FSTYPES += "wic.bz2"
ENABLE_UART = "1"
```

- `MACHINE`: tells BitBake which hardware config to use (from meta-raspberrypi)
- `IMAGE_FSTYPES`: sets output image formats (e.g. `.wic.bz2` = compressed disk image)
- `ENABLE_UART`: enables the serial console for debugging. This variable is used by the `meta-raspberrypi` layer to set up the UART console.

You can explore more settings later, but this is all you need to get started.

---

## 🧪 Step 6: Sanity Check

Make sure BitBake is available:

```bash
bitbake -p
```

If it outputs a long list of recipes, your setup is working.

---

## 🔨 Step 7: Build the First Image

```bash
bitbake core-image-minimal
```

This triggers:
- Recipe parsing
- Dependency resolution
- Kernel and rootfs build
- Image creation

> This will take some time — especially on the first run.

---

## 🏗️ How the Build Works

Yocto’s build system is structured as:

1. BitBake reads metadata (`.bb`, `.conf`, `.inc`)
2. Tasks are generated (e.g., `do_fetch`, `do_compile`, `do_install`)
3. Layers contribute to the final configuration
4. Images are built from the output of recipes

---

## 📤 Step 8: Find the Output

After the build completes, navigate to:

```
rpi-build/tmp/deploy/images/raspberrypi4/
```

You’ll find files like:

- `core-image-minimal-raspberrypi4.wic.bz2`
- `core-image-minimal.manifest`
- `zImage` or `Image` (kernel)
- `u-boot` (bootloader, if included)

---

## 💾 Step 9: Flash the Image to SD Card

Uncompress and flash:

```bash
bunzip2 core-image-minimal-raspberrypi4.wic.bz2
sudo dd if=core-image-minimal-raspberrypi4.wic of=/dev/sdX bs=4M conv=fsync status=progress
sync
```

Replace `/dev/sdX` with your actual SD card device.

You can also use the official Raspberry Pi Imager for a GUI approach.

---

## 🔌 Step 10: Boot and Verify

- Insert the SD card into your Raspberry Pi
- Connect via UART
- Power on the device

You should see kernel boot logs via serial (if `ENABLE_UART = "1"` was set).

---

## 🧠 What You Learned in Part 2

| Concept | Meaning |
|--------|---------|
| `poky` | The Yocto reference distribution |
| `meta-raspberrypi` | Hardware-specific layer |
| `bblayers.conf` | Controls which layers BitBake uses |
| `local.conf` | Controls machine, image type, and build options |
| `bitbake core-image-minimal` | Builds the smallest usable Linux image |
| `.wic` file | A disk image ready for flashing |

---

In the next part, you’ll:
- Create your own custom Yocto layer
- Add your first recipe (`hello`)
- Include it in your image

→ Continue to: [kata_part_3.md](kata_part_3.md)