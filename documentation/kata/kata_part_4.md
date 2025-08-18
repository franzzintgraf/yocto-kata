# 🧠 Yocto Kata – Part 4: Restructuring the Project Using `kas` for Reproducibility and Maintainability

In previous parts, we manually cloned repositories, configured `local.conf` and `bblayers.conf`, and invoked `bitbake` directly to build our image. That worked — but it’s **not scalable**.

Now, in **Part 4**, we’ll restructure the project to use **`kas`**, a powerful configuration tool designed to automate and manage Yocto builds reproducibly.

---

## 🎯 Why Restructure with kas?

Here’s the issue with the approach we used so far:

| Manual Step | Problem |
|-------------|---------|
| Cloning layers manually | Tedious, error-prone, inconsistent |
| Editing config files | Can drift across environments |
| Sharing setup | Difficult — others must repeat all steps |
| Reproducing builds | Nearly impossible without a fixed method |
| Upgrading versions | Requires manual work and careful coordination |

> The more layers and customization you add, the worse it gets.

This is where `kas` shines.

---

## 🧰 What Is `kas`?

**`kas`** is a tool that provides a YAML-based configuration for:

- Cloning and pinning layer repositories
- Defining the machine, image, distro
- Applying config fragments (like `local.conf`)
- Launching builds and shells

It simplifies collaboration, reproducibility, CI/CD integration, and upgrades.

---

## 🔄 Comparison: kas vs repo

Some teams use **`repo`**, an Android-derived tool for managing Git checkouts. While `repo` is great for large mono-repos, it doesn’t understand Yocto.

### 🔍 Comparison Table

| Feature | `kas` | `repo` |
|--------|-------|--------|
| Yocto-native concepts (layers, conf, images) | ✅ Yes | ❌ No |
| Declarative build config (in YAML) | ✅ Yes | ❌ No |
| Requires scripting | ❌ Minimal | ✅ Needed |
| Shared by file | ✅ Single `.yml` file | ✅ Multiple manifest XMLs |
| Used in Yocto industry projects | ✅ Widely | ✅ In some complex projects |
| Easy for CI/CD | ✅ Very | ⚠️ Requires glue code |

> 🧠 Conclusion: `repo` is powerful, but `kas` is **better suited for Yocto-based workflows**.

---

## 🗂️ Project Restructure with kas

Here’s how your project structure evolves:

### 🧱 Old Setup

```
poky/
├── meta-raspberrypi/
├── meta-myproject/
├── rpi-build/
├── ...
```

### 🆕 New Setup

```
yocto-kata/
├── kas.yml
├── meta-myproject/
│   └── recipes-example/
├── .gitignore
├── build/            # created by kas automatically
```

Everything is now **driven by kas.yml**.

---

## 🛠️ Step-by-Step: Create Your kas Project

### ✅ Step 1: Install kas

```bash
pip3 install kas
```

---

### ✅ Step 2: Create the Project Directory

```bash
mkdir yocto-kata
cd yocto-kata
git init
```

Add your `.gitignore`:

```bash
echo -e "build/
.kas_shell_history
meta-*/
!meta-myproject/
poky/ > .gitignore
```

---

### ✅ Step 3: Create kas.yml

```yaml
header:
  version: 18
machine: raspberrypi4
target: core-image-minimal
build_system: oe

repos:
  poky:
    url: "https://git.yoctoproject.org/poky"
    branch: "dunfell"
    layers:
      meta:
      meta-poky:
      meta-yocto-bsp:

  meta-raspberrypi:
    url: "https://git.yoctoproject.org/meta-raspberrypi"
    branch: "dunfell"
    layers:
      .:

  meta-myproject:
    path: "meta-myproject"
    layers:
      .:

local_conf_header:
  meta-myproject: |
    IMAGE_FSTYPES += "wic.bz2"
    ENABLE_UART = "1"
    IMAGE_INSTALL:append = " hello"
```

## 📄 Deep Dive: Understanding the `kas.yml` File

The `kas.yml` file is the **heart of your Yocto project configuration** when using `kas`. It defines everything kas needs to:

- Fetch and prepare your sources (layers)
- Configure your build environment
- Apply specific customizations
- Trigger builds reproducibly

Let’s break it down **line by line** using our working example.

---

### 🧱 Basic Structure

```yaml
header:
  version: 18
machine: raspberrypi4
target: core-image-minimal
build_system: oe
```

| Field | Explanation |
|-------|-------------|
| `header.version` | Required kas config version. `18` is used in kas 4.7. |
| `machine` | Sets the Yocto machine configuration (`raspberrypi4`). Tells BitBake which kernel, bootloader, and settings to use. |
| `target` | The image recipe you want to build (`core-image-minimal`). |
| `build_system` | Tells kas what build system to use (`oe` = OpenEmbedded/Yocto). |

---

### 📦 Repos Section

```yaml
repos:
  poky:
    url: "https://git.yoctoproject.org/poky"
    branch: "dunfell"
    layers:
      meta:
      meta-poky:
      meta-yocto-bsp:
```

This defines:
- A repository (`poky`)
- Where to clone it from (`url`)
- Which branch or revision to use (`branch`)
- Which subdirectories are actual layers (`layers`)

Each repo must list all included layers explicitly.

---

### 🧱 Example: meta-raspberrypi

```yaml
  meta-raspberrypi:
    url: "https://git.yoctoproject.org/meta-raspberrypi"
    branch: "dunfell"
    layers:
      .:
```

This layer is structured differently — the layer lives at the top level of the repo, so we use `.:` as the path.

> Note: `.:` means "use this folder as the layer".

---

### 🧱 Example: meta-myproject (local layer)

```yaml
  meta-myproject:
    path: "meta-myproject"
    layers:
      .:
```

- `path`: Points to a **local directory** on disk.
- `layers`: Again, we use `.:` because the layer is at the top level.

No `url` or `branch` is needed for local layers.

---

### 🧩 Configuration Overrides (local_conf_header)

```yaml
local_conf_header:
  meta-myproject: |
    IMAGE_FSTYPES += "wic.bz2"
    ENABLE_UART = "1"
    IMAGE_INSTALL:append = " hello"
```

This section **injects text** into `local.conf` under a named header block.

> It’s equivalent to editing `local.conf`, but now **version-controlled** and **reproducible**.

Here:
- We add a `.wic.bz2` image output
- Enable UART for serial console debugging
- Install the `hello` package

---

### 🧪 Tips and Best Practices

- Each layer **must** be explicitly listed with its relative path
- Use **separate folders** for each remote repo (don't clone manually!)
- Use `branch` to pin to a branch (e.g., `dunfell`, `kirkstone`)
- Optionally use `commit:` or `tag:` to lock versions even harder
- Use `local_conf_header` for small, project-specific tweaks

---

### 📌 Example: Locking a repo to a tag

```yaml
repos:
  poky:
    url: "https://git.yoctoproject.org/poky"
    tag: "yocto-3.1.24"
    layers:
      meta:
      meta-poky:
```

This makes your build even more reproducible — you’ll always build the exact same thing.

---

### ✅ Summary

| Section | Purpose |
|---------|---------|
| `header` | kas version declaration |
| `machine` | Target hardware (e.g., Raspberry Pi) |
| `target` | The image recipe (e.g., core-image-minimal) |
| `repos` | All Git-based or local repositories with metadata |
| `layers` | List of included Yocto layers within each repo |
| `local_conf_header` | Injects configuration into local.conf dynamically |

---

By learning and structuring `kas.yml` well, you make your Yocto project **predictable**, **portable**, and **CI-friendly**.

---

## 🚀 Step 4: Build the Image

```bash
kas build kas.yml
```

What this does:
- Clones all Git repos using the correct branch/tag
- Applies `local.conf` fragment
- Configures `bblayers.conf`
- Runs BitBake

The result is **exactly the same** as what we built manually — but now fully automated.

---

## 🧪 kas shell: Development Environment

Run:

```bash
kas shell kas.yml
```

This drops you into a fully configured BitBake environment — just like sourcing `oe-init-build-env`.

From there you can:

```bash
bitbake hello
bitbake core-image-minimal -c clean
```

> This is great for iterative testing, patching, or debugging.

---

## 🧠 Summary of What You Learned

| Concept | Value |
|--------|-------|
| kas | Declarative, reproducible build config for Yocto |
| kas.yml | Defines layers, machine, image, and local.conf |
| repo vs kas | kas is Yocto-aware, simpler for embedded teams |
| kas shell | Quick way to jump into BitBake shell |
| Project structure | Cleaned up, maintainable, and shareable |

---

In the next part, we’ll add a tiny IoT application using the **Azure IoT SDK** to our image.

→ Continue to: [kata_part_5.md](kata_part_5.md)