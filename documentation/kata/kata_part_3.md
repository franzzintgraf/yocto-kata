# 🧠 Yocto Kata – Part 3: Yocto Layers and Custom Recipe Creation

Welcome to Part 3 of the Yocto Kata! In the last part, we successfully built and booted a minimal Linux image for the Raspberry Pi 4 using Yocto. Now, we’ll begin **customizing** that image by:

- Understanding Yocto’s layer system
- Creating your own custom layer using `bitbake-layers`
- Writing your first BitBake recipe
- Including your custom application in the image

---

## 🧩 What Is a Layer in Yocto?

A **Yocto layer** is a modular unit that contains metadata, recipes, configurations, and optional classes.

Layers help structure and organize large embedded projects. Think of them as the "plugin" architecture of Yocto.

### 📁 A Layer Typically Contains:

```
meta-myproject/
├── conf/
│   └── layer.conf
├── recipes-*/               # Organized by feature/domain
│   └── <recipe name>/
│       ├── <recipe>.bb
│       └── files/
└── README
```

---

## 🔍 Why Layers Matter

| Benefit           | Description |
|------------------|-------------|
| **Modularity**   | Group related recipes and logic |
| **Reusability**  | Share or reuse layers across products |
| **Separation**   | Keep vendor, hardware, and project logic apart |
| **Scalability**  | Layers can depend on other layers and override logic |

---

## 🧾 What Is a Recipe?

A **BitBake recipe** (`.bb` file) tells Yocto:

- Where to get the source code
- How to configure/build/install it
- What license it uses
- Which tasks it provides (`do_compile`, `do_install`, etc.)

Think of it as a “Makefile + package definition + install script” all in one.

---

## 🏗️ Step-by-Step: Create Your Own Layer

We’ll create a new layer called `meta-myproject`.

### ✅ Step 1: Enter Your Build Directory

```bash
cd poky
source oe-init-build-env rpi-build
```

> Always enter your build env before running BitBake commands.

---

### 🛠️ Step 2: Create a Custom Layer

```bash
bitbake-layers create-layer ../meta-myproject
```

This creates:

```
../meta-myproject/
├── conf/
│   └── layer.conf
└── README
```

### 📄 `layer.conf` Explained

This file tells BitBake:
- The name of the layer (`BBFILE_COLLECTIONS`)
- Where to find recipes (`BBFILES`)
- Layer priority

Example entries:

```conf
BBFILE_COLLECTIONS += "myproject"
BBFILE_PATTERN_myproject := "^${LAYERDIR}/"
BBFILE_PRIORITY_myproject = "6"
```

---

### ➕ Step 3: Register the Layer in Your Build

We have just created a layer but it’s not yet registered in your build.
To do this, run:

```bash
bitbake-layers add-layer ../meta-myproject
```

This updates `bblayers.conf` to include your custom layer.

You can now add recipes that will be visible to BitBake.

---

## 🧪 Step-by-Step: Create Your First Recipe (`hello`)

We’ll add a simple "hello world" shell script to demonstrate how a recipe works.

### ✅ Step 1: Create Directory Structure

```bash
cd ../meta-myproject
mkdir -p recipes-example/hello/files
```

This is a convention: `recipes-<category>/<name>/files`

---

### ✍️ Step 2: Add the Source File

Create the script:

```bash
cat > recipes-example/hello/files/hello.sh << 'EOF'
#!/bin/sh
echo "Hello from Yocto!"
EOF

chmod +x recipes-example/hello/files/hello.sh
```

---

### 📄 Step 3: Write the Recipe

Create `hello_0.1.bb`:

```bash
nano recipes-example/hello/hello_0.1.bb
```

Paste:

```bitbake
SUMMARY = "Simple Hello World script"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://hello.sh"

S = "${WORKDIR}"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/hello.sh ${D}${bindir}/hello
}
```

> **Explanation**:
> - `SUMMARY`: Short description
> - `LICENSE` + `LIC_FILES_CHKSUM`: Required for legal compliance
> - `SRC_URI`: Where to get the source (local file in this case)
> - `S`: Where BitBake "cds" into
> - `do_install()`: Copies script into target `/usr/bin`

---

### 🔍 What Is `${D}`, `${S}`, `${WORKDIR}`?

| Variable | Meaning |
|----------|---------|
| `${D}` | Destination root (image rootfs) |
| `${S}` | Source directory (inside build) |
| `${WORKDIR}` | Recipe's temporary working folder |

---

## 📦 Step 4: Build the Recipe

```bash
bitbake hello
```

Output will appear under:

```
tmp/deploy/ipk/
tmp/work/.../hello/
```

This proves that BitBake can find and process your recipe.

---

## 🧩 Step 5: Add Recipe to Image

In `conf/local.conf`, add:

```conf
IMAGE_INSTALL:append = " hello"
```

Then rebuild:

```bash
bitbake core-image-minimal
```

Now `/usr/bin/hello` will be present in your image. You can try it out by booting the image on your Raspberry Pi and run:

```bash
/usr/bin/hello
```
You should see:

```
Hello from Yocto!
```

---

## 🧠 What You Learned in Part 3

| Concept | Meaning |
|--------|---------|
| Layer | Logical group of recipes and configs |
| Recipe | Build instructions for software or scripts |
| bitbake-layers | Tool to create/manage layers |
| IMAGE_INSTALL | List of packages to include in the rootfs |

---

In the next parts, we’ll:
- Add another recipe using deprecated syntax for migration testing
- Learn how to manage reproducible builds using `kas`

→ Continue to: [kata_part_4.md](kata_part_4.md)