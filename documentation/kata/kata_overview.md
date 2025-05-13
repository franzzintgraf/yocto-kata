# 🧠 Yocto Kata Overview

Welcome to the Yocto Kata series — a step-by-step learning path to master building custom embedded Linux systems with the Yocto Project.

Each part builds on the previous one, gradually introducing more powerful and maintainable workflows.

---

## 📚 Kata Parts

### 🔹 [Part 1: Project Aim, Yocto Background & Host Setup](kata_part_1.md)
Learn what the Yocto Project is, how it works, and why we’re using it. Then prepare your host system with all required tools to begin.

### 🔹 [Part 2: Setting Up the Yocto Build System](kata_part_2.md)
Clone the Yocto reference distribution (Poky) and the Raspberry Pi layer. Configure the build system and build your first minimal Linux image.

### 🔹 [Part 3: Custom Layer and First Recipe](kata_part_3.md)
Understand what Yocto layers and recipes are. Create your own layer and a simple `hello` recipe that runs on the Raspberry Pi.

### 🔹 [Part 4: Legacy Recipe for Migration Testing](kata_part_4.md)
Write a recipe using deprecated syntax to prepare for testing migration paths when upgrading to newer Yocto releases.

### 🔹 [Part 5: Restructuring with kas](kata_part_5.md)
Convert your manually configured project to a fully automated, reproducible setup using `kas`. Learn about `kas.yml` and why it’s a best practice.

### 🔹 [Part 6: IoT app and Azure integration](kata_part_6.md)
Integrate a real-world IoT application using the Azure IoT SDK. Build and run the application on your Raspberry Pi.

### 🔹 [Part 7: Custom Images](kata_part_7.md)
Create custom images (dev/prod) for your project and parametrize them with `kas`.

### 🔹 [Part 8: Patching the source for a recipe](kata_part_8.md)
Learn how to apply patches to recipes using the `devtool`

### 🔹 [Part 9: Patching a Linux Kernel CVE](kata_part_9.md)
Learn how to list all CVEs in the kernel and how to patch one CVE in our Linux kernel.

---

## 🛠️ Coming Next

- Preparing for Kernel and Yocto Version Migration

---

## 💡 How to Use

- Follow the parts in order
- Execute all commands as instructed
- Read the explanations to understand the *why*
- Use this overview as your navigation hub

Happy yoctoing! 🎉