# 🧩 Kata Part 8: Patching the Source of a Recipe Using `devtool`

In this kata, we learn how to apply a patch to the source of an existing Yocto recipe using the `devtool` utility — the preferred way for developers to quickly iterate on and extend upstream recipes without duplicating or breaking them.

---

## 🎯 Goals of This Part

- Understand the concept of patching recipes in Yocto
- Learn how to use `devtool` to modify, test, and finalize changes
- Understand the purpose of `.bbappend` files and Git-style patches
- Integrate the patched recipe into our custom layer

---

## 🧠 Background: Why Patching Matters

Patching is essential in embedded development:
- Vendors ship upstream packages — but you need to fix or extend them
- You don’t want to fork the whole recipe (maintenance nightmare)
- Yocto supports patches as **first-class citizens** through its metadata system

Patch files are typically stored under your custom layer and referenced from a `.bbappend` file, which "extends" the original recipe without modifying it.

---

## 🧰 Setup: Example Layer and Recipe

We integrate a new public layer:

```
https://github.com/franzzintgraf/meta-yocto-examples
```

It contains a simple recipe:
```
recipes-example/hello-world-cpp/hello-world-cpp_0.1.bb
```

This is a small C++ program that prints a message. Perfect for learning how to patch.

---

## 🧱 Step-by-Step Guide to Patching with `devtool`

### 🔹 Step 1: Add the Layer

In your `kas.yml`:

```yaml
  meta-yocto-examples:
    url: "https://github.com/franzzintgraf/meta-yocto-examples.git"
    branch: "dunfell"
    layers:
      .:
```

You can now confirm the recipe is available inside the bitbake shell:

```bash
bitbake -s | grep hello-world-cpp
```

---

### 🔹 Step 2: Start Modifying with `devtool`

```bash
devtool modify hello-world-cpp
```

This creates:
- A local source tree under: `build/workspace/sources/hello-world-cpp`
- A bbappend in the `workspace` layer
- BitBake will now build from your local modified version using devtool

---

### 🔹 Step 3: Make Your Changes

Edit in the local source tree the `main.cpp` and change the output text.

---

### 🔹 Step 4: Build the Patched Version

```bash
devtool build hello-world-cpp
```

This builds the local, modified source.

---

### 🔹 Step 5: Test It on Your Device

```bash
devtool deploy-target hello-world-cpp root@<ip-address>
```

This copies the built binary to `/usr/bin/` on your target device.
You can now SSH into your device and run the modified program:

```bash
ssh root@<ip-address>
hello-world-cpp
```
You should see the new message printed.

After verifying the changes, you can remove the binary from the target device:

```bash
devtool undeploy-target hello-world-cpp root@<ip-address>
```

This will remove the binary from `/usr/bin/` on your target device.

---

### 🔹 Step 6: Commit the Changes

Go into the workspace source tree:

```bash
cd build/workspace/sources/hello-world-cpp
git add .
git commit -m "Change greeting message for the yocto kata"
```

Only committed changes are turned into patch files.

---

### 🔹 Step 7: Finalize the Patch

```bash
cd build
devtool finish hello-world-cpp ../meta-myproject
```

This does several things:
- Generates a `0001-<change-message>.patch` in `meta-myproject/recipes-example/hello-world-cpp/hello-world-cpp/`
- Creates a `.bbappend` file with:

```bitbake
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://0001-<change-message>.patch"
```

---

### 🔹 Step 8: Add Recipe to Image

In `meta-myproject/recipes-core/images/myproject-image-dev.bb`, add:

```conf
hello-world-cpp \
```

to the `IMAGE_INSTALL` variable.

Then rebuild:

```bash
kas build kas.yml:kas/image/dev.yml:kas/machine/rpi4.yml
``` 

---

## 🧠 What is a `.bbappend`?

A `.bbappend` is a metadata extension to an existing recipe. It allows you to:
- Add patches
- Append steps to install/configure
- Add extra dependencies
- Change variables like `SRC_URI` or `EXTRA_OECONF`

The filename must match the base recipe, e.g.:

```
hello-world-cpp_0.1.bbappend
```

or

```
hello-world-cpp_%.bbappend
```

where the `%` wildcard matches any version.

---

## 🧠 What is a `0001-*.patch`?

This is a **Git-format patch** created from your commit by `git format-patch`.

The number (0001, 0002, ...) indicates patch order. This is the standard format in:
- Linux kernel development
- Yocto/OpenEmbedded layers
- Upstream mailing lists

The patch includes metadata:
- Commit message
- Author
- Date
- Code diff

---

## ✅ Summary

| Step                          | Purpose                                         |
|-------------------------------|-------------------------------------------------|
| `devtool modify`              | Creates a local editable copy of the recipe     |
| Edit + commit                 | Apply and track your changes                    |
| `devtool build`               | Build with changes locally                      |
| `devtool deploy-target`       | Quickly test on target without rebuilding image |
| `devtool finish`              | Turn changes into layer-tracked patch + bbappend |
| `devtool reset`               | Clean up and go back to upstream                |

---

## 📌 You’ve Learned

- How to patch a Yocto recipe cleanly and correctly
- Why `.bbappend` files are the backbone of recipe overrides
- How to use `devtool` to accelerate development
- How to version-control patches in your own layer

---