# 🧠 Yocto Kata – Part 1: Project Aim, Yocto Background, and Host Environment Setup

Welcome to Part 1 of the Yocto Kata series. In this series, we guide you through building and customizing a Linux distribution for the Raspberry Pi 4 using the Yocto Project, step by step. Each part builds on the previous one — with deep technical insight — so you can understand *why* each step is needed, not just *how* to do it.

---

## 🎯 Project Aim

The goal of this kata is to learn how to:

- Use Yocto to build a custom Linux image from scratch
- Understand the build system and how components interact
- Create your own layer and recipes
- Build reproducible, modular embedded Linux systems
- Migrate to newer Yocto releases and Linux kernels

By the end, you’ll be able to build your own Linux system tailored for your hardware, and confidently navigate Yocto’s ecosystem like a professional embedded developer.

---

## 🧠 What Is the Yocto Project?

The Yocto Project is **not a Linux distribution** — it is a *set of tools and metadata to build your own Linux distribution*.

➡️ [Official Yocto Project Website](https://www.yoctoproject.org/)  

Key components:

- [**BitBake**](https://docs.yoctoproject.org/bitbake/): The task execution engine. It processes recipes, executes tasks, and handles dependencies.  
- [**Poky**](https://docs.yoctoproject.org/ref-manual/terms.html#term-Poky): The reference distribution provided by Yocto. It includes BitBake, metadata, and layers.  
- **Metadata**: Layered configuration files and build instructions (called recipes) used to build software.

### 🔍 Why use Yocto?

| Reason | Explanation |
|--------|-------------|
| Customization | Build exactly what you need, and nothing more |
| Reproducibility | Bit-for-bit builds are possible with locked versions |
| Scalability | Used in hobbyist projects and large commercial systems |
| Layer System | Modular and maintainable configuration |

Yocto is complex, but powerful — and mastering it gives you full control over your Linux systems.

---

## 🗺️ Yocto Terminology Overview

| Term | Meaning |
|------|---------|
| **Layer** | A collection of recipes, configuration, and classes (e.g., meta-raspberrypi) |
| **Recipe (.bb)** | A build script describing how to fetch, build, and install a package |
| **Image** | A complete root filesystem, possibly bundled with bootloader and kernel |
| **Machine** | Defines hardware details (e.g., raspberrypi4) |
| **BitBake** | The engine that parses recipes and runs tasks |
| **Poky** | The Yocto reference distribution that includes BitBake and core layers |

For more terminology, see the [Yocto Project Terms](https://docs.yoctoproject.org/ref-manual/terms.html).

---

## 🧰 Part 1 Goal: Set Up the Host Environment

Before we dive into layers and images, we need to prepare your development environment. The Yocto Project requires a Linux system and some essential build tools.

---

## 🖥️ Supported Host OS

Yocto builds best on:

- Ubuntu (20.04 LTS or newer)
- Debian (10 or newer)
- Fedora (32 or newer)
- Any distro with a modern toolchain and Python 3

> **Note:** The required host OS version depends on the Yocto Project release you are using. For example:
> - **Dunfell (Yocto 3.1.x):** Officially supports Ubuntu 20.04 LTS and Ubuntu 22.04 LTS.
> - **Newer Yocto releases (e.g., Kirkstone, Mickledore):** Require Ubuntu 22.04 LTS or newer.

We’ll use Ubuntu/Debian-based commands in this kata.

---

## 🛠️ Step-by-Step: Installing Host Dependencies

> **Note:** In this kata, we use the **Dunfell (Yocto 3.1.x)** release as our baseline. The package list and requirements below are for Dunfell. In later parts of the kata, we may migrate to a newer Yocto release, which could require updated dependencies or a newer host OS. Always check the documentation for your Yocto version.

Make sure all the system requirements are installed for Dunfell. [See the official system requirements for Dunfell here](https://docs.yoctoproject.org/3.1.33/ref-manual/ref-system-requirements.html). If you use the provided devcontainer, all dependencies are already set up.

Remark: In general [Yocto's manual](https://docs.yoctoproject.org/ref-manual/system-requirements.html#supported-linux-distributions) describes very detailed all requirements for a full list per OS.

---

## ✅ You Are Ready for Part 2

You’ve prepared your system and installed all required dependencies. In Part 2, we’ll dive into setting up the Yocto build system by cloning Poky and Raspberry Pi support layers, and starting our first image build.

→ Continue to: [kata_part_2.md](kata_part_2.md)