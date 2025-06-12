# 🛡️ Kata Part 8: Patching a Kernel CVE

In this kata, we learn how to detect, investigate, and patch a known Linux kernel vulnerability (CVE) using Yocto best practices. You’ll use the `cve-check` tool to identify vulnerabilities, locate the correct upstream patch, and then integrate it into your custom layer via a `.bbappend`.

---

## 🎯 Goals

- Run Yocto's `cve-check` tool to detect known vulnerabilities
- Investigate a real CVE affecting your current kernel
- Find and verify the upstream patch in the correct branch
- Apply the patch using `.bbappend` in your custom layer
- Understand the structure and workflow behind CVE mitigation in Yocto

---

## 🛠️ Step 1: Enable `cve-check` in a kas Overlay

Yocto supports CVE scanning via the `cve-check` class. We'll enable it using a `kas` overlay so it's modular and clean.

1. Create `kas/features/cve-check.yml`:

```yaml
header:
  version: 18

local_conf_header:
  cve-check: |
    INHERIT += "cve-check"
```

2. Build with CVE checking enabled:

```bash
kas build kas.yml:kas/features/cve-check.yml:kas/image/dev.yml:kas/machine/rpi4.yml
```

3. After the build, inspect the CVE report:

```bash
tmp/deploy/images/raspberrypi4/*.cve
```

This file lists all known CVEs that match the built package versions. You’ll find columns like package, CVE ID, status, severity, and description.

---

## 🔍 Step 2: Investigate a CVE — CVE-2021-3640

Let’s focus on `CVE-2021-3640`, which affects Bluetooth SCO sockets in the Linux kernel.

### ✅ Check Your Kernel Version

Boot your device and run:

```bash
uname -a
```

Or from BitBake:

```bash
bitbake -e virtual/kernel | grep ^LINUX_VERSION
```

Assume you’re running version 5.4.72 — a common stable version used by Raspberry Pi builds.

---

## 📥 Step 3: Find the Correct Patch in the Kernel Repository

Start by looking up the CVE on the NVD:

- [CVE-2021-3640](https://nvd.nist.gov/vuln/detail/CVE-2021-3640)

From there, we identify the **original upstream fix**:

- Commit in Linus’ mainline tree:
  - https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/net/bluetooth/sco.c?id=99c23da0eed4fd20cae8243f2b51e10e66aa0951

This fix was later **backported into the official stable `linux-5.4.y` tree**:
- https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/commit/?h=linux-5.4.y&id=d416020f1a9cc5f903ae66649b2c56d9ad5256ab

However — and this is crucial — our Yocto image (using `meta-raspberrypi`) does **not** build from the official `linux-5.4.y` tree.

### 🧠 Instead: Our Build Uses the Raspberry Pi Foundation Kernel

You can confirm this with:

```bash
bitbake -e virtual/kernel | grep ^SRC_URI=
bitbake -e virtual/kernel | grep ^SRCREV=
```

This typically shows:

```
SRC_URI = "git://github.com/raspberrypi/linux.git;name=machine;branch=rpi-5.4.y ..."
SRCREV = "<commit>"
```

This means you are using:
- The **Raspberry Pi Foundation fork of Linux**
- Which may have different file paths, added patches, or altered subsystem logic

### ✅ Best Practice: Use the Patch from the Kernel Source You Actually Use

Therefore, search for the patch (or equivalent logic) in the RPi kernel tree:
- https://github.com/raspberrypi/linux/commits/rpi-5.4.y

Use the git search to find commits matching the upstream commit content. Often, the mainline commit ID will be included in the commit message, so you can search for that too.

E.g. use this git command:

```bash
git log --grep="CVE-2021-3640" --oneline
```

or

```bash
git log --grep="99c23da0eed4fd20cae8243f2b51e10e66aa0951" --oneline
```

If the patch exists there, use that version.  
If it does not, and the upstream patch applies cleanly — you may proceed, but be sure to test it thoroughly on the device.

> 📌 Summary: Always match your patch source to the actual kernel tree in use. Don’t assume upstream stable = your build base.

> In our case, the Raspberry Pi Foundation kernel does not have the patch, so we will use the upstream stable version.

---

## 📂 Step 4: Download and Organize the Patch

Save the raw patch file from:

```
https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/patch/?id=d416020f1a9cc5f903ae66649b2c56d9ad5256ab
```

Place it into your custom layer:

```bash
meta-myproject/
└── recipes-kernel/
    └── linux/
        └── files/
            └── cve-2021-3640.patch
```

If the patch would contain multiple files, make sure to organize them in an alphabetical order. This is important for the `do_patch` task to apply them correctly. Common is to prefix the filenames with a number, e.g., `0001-`, `0002-`, etc.

---

## 🧩 Step 5: Create the `.bbappend` File

Create the file:  
`meta-myproject/recipes-kernel/linux/linux-raspberrypi_5.4.bbappend`

Contents:

```bitbake
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://cve-2021-3640.patch"
```

This tells BitBake to:
- Look in `files/` for additional content
- Include your patch in the `do_patch` phase of the kernel build

---

## 🧪 Step 6: Rebuild the Kernel and Image

1. Clean the kernel build to ensure your patch is applied cleanly:

```bash
bitbake -c clean virtual/kernel
```

2. Rebuild:

```bash
bitbake virtual/kernel
```

3. Rebuild your image to include the updated kernel:

```bash
kas build kas.yml:kas/features/cve-check.yml:kas/image/dev.yml:kas/machine/rpi4.yml
```

After that you can verify again the CVE report where the CVE should be marked as patched.

---

## 🔐 Summary

| Step | What You Did |
|------|--------------|
| `cve-check` | Scanned your build for known vulnerabilities |
| CVE selection | Picked CVE-2021-3640 affecting your kernel |
| Patch sourcing | Verified upstream and backported patch in linux-5.4.y |
| Integration | Used `.bbappend` to cleanly inject the patch |
| Validation | Rebuilt and checked the patched image |

---

## 🧠 What You Learned

- How to detect and trace CVEs relevant to your build
- How to verify whether a CVE is fixed in your current kernel
- How to fetch a clean upstream patch from the stable branch
- How to apply patches using `.bbappend`

---