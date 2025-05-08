# 🧠 Yocto Kata – Part 4: Creating a Legacy Recipe to Prepare for Future Migrations

In Part 3, we created our own custom layer and added a simple `hello` recipe. Now in Part 4, we’ll take a very strategic step:

> Create a **recipe using deprecated BitBake syntax**, so we can **test migration paths** later when upgrading to a newer Yocto release.

This may seem odd — creating something that will break in the future — but it’s one of the best ways to **future-proof your workflow**.

---

## 🎯 Goal of This Step

- Understand how Yocto evolves and why old syntax breaks
- Write a recipe that intentionally uses **outdated or discouraged BitBake constructs**
- Use this recipe in your project as a **migration test case**
- Lay the foundation for migration tools or manual upgrades later

---

## 🔄 Why Yocto Versions Matter

The Yocto Project follows a regular release cycle:

| Release Name | Version | Release Type |
|--------------|---------|--------------|
| Dunfell      | 3.1     | LTS          |
| Hardknott    | 3.3     | Regular      |
| Kirkstone    | 4.0     | LTS          |
| Langdale     | 4.1     | Regular      |
| Scarthgap    | 5.0     | LTS          |

> Each version introduces new features, bug fixes, and **syntax changes**. Older constructs are deprecated and then removed.

If you stick with old syntax, **your build will eventually break** when moving to newer Yocto versions.

---

## 🧩 Versioning in Yocto and Layers

### 🔖 Layer Branching Strategy

Each Yocto release has its own **Git branch** in official layers:

- `poky` has a `dunfell`, `kirkstone`, etc.
- `meta-raspberrypi` has the same

This keeps everything aligned with compatible versions.

> 💡 Best Practice:
> When using Yocto, always ensure **all your layers use the same branch/release**.

If you use:
```bash
git clone -b dunfell ...
```
for each layer, you’ll ensure they’re version-matched.

---

## 🧪 What We'll Do in This Part

Create a recipe called `oldstyle` that:
- Uses `do_install_append()` (deprecated in newer releases)
- Uses `INHIBIT_PACKAGE_DEBUG_SPLIT` (no longer recommended)
- Uses classic `=` variable assignments instead of modern `:` syntax

---

## 🛠️ Step-by-Step: Create the `oldstyle` Recipe

### ✅ Step 1: Create Directory

```bash
cd meta-myproject
mkdir -p recipes-example/oldstyle/files
```

---

### ✍️ Step 2: Create the Script File

```bash
cat > recipes-example/oldstyle/files/greet.sh << 'EOF'
#!/bin/sh
echo "Greetings from the old school Yocto!"
EOF

chmod +x recipes-example/oldstyle/files/greet.sh
```

---

### 📄 Step 3: Create the Legacy Recipe

Create `oldstyle_1.0.bb`:

```bash
nano recipes-example/oldstyle/oldstyle_1.0.bb
```

Paste the following:

```bitbake
SUMMARY = "Old style example recipe with deprecated syntax"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835c5f5c6c4d7c8b6e65d106f63529c"

SRC_URI = "file://greet.sh"

S = "${WORKDIR}"

INHIBIT_PACKAGE_DEBUG_SPLIT = "1"

do_install_append() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/greet.sh ${D}${bindir}/greet
}
```

### 🔎 What’s “bad” about this recipe?

| Deprecated Pattern | Explanation |
|--------------------|-------------|
| `do_install_append()` | New syntax prefers `python do_install:append()` or anonymous functions |
| `INHIBIT_PACKAGE_DEBUG_SPLIT` | Discouraged, Yocto prefers keeping debug packages cleanly separated |
| `=` assignments | Replaced by `:` overrides (e.g., `IMAGE_INSTALL:append = ...`) in newer releases |

---

## ✅ Step 4: Build and Verify

Rebuild the image:

```bash
bitbake oldstyle
bitbake core-image-minimal
```

Boot the image and run:

```bash
/usr/bin/greet
```

You should see:

```
Greetings from the old school Yocto!
```

---

## 🧠 Why This Recipe Is Valuable

This “bad practice” recipe becomes a **canary** — when we later upgrade to:
- `kirkstone`
- `scarthgap`

… we can test:
- What breaks
- Which migration scripts are triggered
- How to fix or modernize real-world recipes

---

## 💡 Summary of What You Learned

| Concept | Value |
|--------|-------|
| Yocto versioning | Each release may deprecate syntax |
| Aligned layer branches | Ensure all layers use the same Yocto branch |
| Legacy recipes | Create test cases for upgrade validation |
| Future-proofing | Helps plan clean migrations |

---

In the next part, we’ll restructure your entire project to use **kas** for reproducible builds and portable configuration.

→ Continue to: [kata_part_5.md](kata_part_5.md)