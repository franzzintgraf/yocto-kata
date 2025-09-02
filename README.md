# 🌐 Yocto Raspberry Pi Kata

This repository contains a customizable, production-grade embedded Linux system built using the **Yocto Project**. The target hardware is the **Raspberry Pi 4**, and the aim is to learn Yocto by doing - using a kata-style structured approach.

---

## 🎯 Project Aim

The goal of this project is to:

- Learn Yocto by doing — using a kata-style structured approach
- Build a minimal but extensible Linux image for the Raspberry Pi 4
- Integrate a real-world IoT telemetry application (Azure IoT)
- Use best practices for maintainability, reproducibility, and versioning
- Prepare for kernel and Yocto upgrades through legacy testing and migration

The resulting system will be lightweight, modular, and fully under version control, supporting both local development and CI/CD pipelines.

---

## 📘 Yocto Kata Documentation

This project is accompanied by a structured learning path broken into multiple parts.

📂 See: [`documentation/kata/`](documentation/kata/)

📑 Start here: [`kata_overview.md`](documentation/kata/kata_overview.md)

The kata documents walk you through:
- Setting up Yocto and your build host
- Building and customizing your own image
- Creating layers and recipes
- Reorganizing with `kas`
- Adding real applications and sensors
- Migrating and modernizing older code

---

## 🧰 Tooling Used

- **Yocto** — Custom Linux build system
- **BitBake** — Yocto's task executor
- **kas** — Configuration and build automation

---

## 🚀 Quick Start (inside Devcontainer)

```bash
kas build kas.yml:kas/image/dev.yml:kas/machine/rpi4.yml
```

---

## 📦 Status

✅ Core image builds  
✅ Custom layer and recipes  
✅ Configuration and build automation with `kas`  
✅ IoT app and Azure integration  
✅ Custom Image Recipe(s)  
✅ Patching recipe(s) using `devtool`  
✅ Analyze CVEs and apply a kernel patch  
🕐 Kernel version update — planned  

---

## 🙌 Credits

This project and its accompanying Yocto Kata documentation were created with the continuous help of **ChatGPT** by OpenAI.

> Without the guidance, explanations, and structured assistance from ChatGPT, this level of depth and clarity in the Yocto learning process would not have been possible.