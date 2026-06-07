# Building Zyxel-Matrix Hybrid Firmware

## Build Application
To build application for router you need to cross compile from source.


## 🔧 Cross-Compilation Guide

### Setting Up the Build Environment


cd ./xx3301

# Set SDK path
export SDK_PATH=./xx3301

# Add toolchain to PATH
export PATH=$PATH:$SDK_PATH/staging_dir/toolchain-mips_34kc_gcc-4.8-linaro_uClibc-0.9.33.2/bin

# Set cross-compilation variables
export CROSS_COMPILE=mips-openwrt-linux-uclibc-
export STAGING_DIR=$SDK_PATH/staging_dir

# Set library paths
export LDFLAGS="-L$STAGING_DIR/target-mips_34kc_uClibc-0.9.33.2/usr/lib"
export CPPFLAGS="-I$STAGING_DIR/target-mips_34kc_uClibc-0.9.33.2/usr/include"

# Set compiler
export CC="mips-openwrt-linux-uclibc-gcc"
export CFLAGS="-march=mips32r2 -msoft-float"
export LDFLAGS="-static"

# Compile
mips-openwrt-linux-uclibc-gcc \
    -march=mips32r2 \
    -msoft-float \
    -static \
    source.c -o binary_name

# Example
# Create a test program
cat > hello.c << EOF
#include <stdio.h>
int main() {
    printf("Hello from Zyxel-Matrix!\n");
    return 0;
}
EOF

# Compile for the router
mips-openwrt-linux-uclibc-gcc \
    -march=mips32r2 \
    -msoft-float \
    -static \
    hello.c -o hello_router

# Check the compiled binary
file hello_router
 Output: hello_router: ELF 32-bit MSB executable, MIPS, MIPS32 rel2 version 1

# Compiling Example with additional include and library paths
mips-openwrt-linux-uclibc-gcc \
    -march=mips32r2 \
    -msoft-float \
    -static \
    -I/path/to/includes \
    -L/path/to/libraries \
    -lmylib \
    source.c -o binary_name


## Build The router Rootfs
The approach to build Openwrt is quite different than main stream Openwrt workflow.
To build firmware for the Zyxel EX3301-T0 / DX3310-T0 routers, two main components need to work together:

| Component | Percentage | Description |
|-----------|------------|-------------|
| **Kernel** | ~10% | Handles low-level hardware communication |
| **RootFS** | ~90% | Contains the operating system, applications, and tools |

## The Hybrid Approach

Zyxel's approach leaves the **kernel untouched** on the router, allowing it to communicate effectively with the device hardware at a low level. This means:

- ✅ No need to rebuild the kernel from scratch
- ✅ Hardware compatibility is maintained
- ✅ Proprietary drivers remain functional

## Building a Compatible RootFS

The First step is to build a compatible rootfs that the kernel can accept. Approximately **90% of the router's operating system** consists of the rootfs.

### What This Means

We can **change, create, modify, or add new software** only within the root filesystem. Kernel modifications typically require building specific kernel modules, but in many cases, we can try loading pre-compiled and compatible kernel modules to do the things done.

## Tools Required

Due to GitHub size limitations, large files are hosted externally. The following source files are required for building:

### Required Source Files

| File | Description |
|------|-------------|
| `OpenWrt-ImageBuilder-15.05.1-ar71xx-generic.Linux-x86_64.tar.bz2` | OpenWrt Image Builder (137 MB) |
| `OpenWrt-SDK-15.05.1-ar71xx-generic_gcc-4.8-linaro_uClibc-0.9.33.2.Linux-x86_64.tar.bz2` | OpenWrt SDK (75 MB) |
| `busybox-1.36.1.tar.bz2` | BusyBox utilities |
| `squashfs4.2.tar.gz` | SquashFS tools |

### Download Links

- [OpenWrt ImageBuilder](https://downloads.openwrt.org/releases/15.05.1/) (or use your own copy)
- [OpenWrt SDK](https://downloads.openwrt.org/releases/15.05.1/)
- [BusyBox](https://busybox.net/downloads/)
- [SquashFS](https://github.com/plougher/squashfs-tools)

## 🏗️ Building from Source

### Important Notice

> **Rootfs is the only part of the firmware that can be built with open-source code.** The remaining components are proprietary and not shared in repo , except if you want to use them you have to install firmware.

### Build Process

1. Download the required source files listed above
2. Place them in the `source/` directory
3. Make changes to code
4. Use cross compile guide to add utilities
5. Use the repack_firmware to sign the firmware

### using repack_firmware

⚠️ **IMPORTANT**: Please use the repack script without any modification to the source (root_fs) and check the size of final.bin at the end if it match to the sysupgrade firmware provided, then you are ready to modify root_Fs


Clone the repository:  
   ```
   git clone https://github.com/majad00/Openwrt_Zyxel-EX3301-T0.git
   ```

2. **Navigate to the Project Directory:**  
   Change into the project's directory:  
   ```
   cd Openwrt_Zyxel-EX3301-T0
   ```

3. **Make the Script Executable:**  
   Run the following command to change the permission of the script:  
   ```
   chmod +x repack_firmware
   ```

4. **Run the Firmware Repack Script:**  
   Execute the script with superuser privileges:  it will repack firmware and sign it as well.
   ```
   sudo ./repack_firmware_v17
   ```

5. **Custome firmware:**  
   You can find the custom firmware in the root directory named "final.bin".



⚠️ **Note**: If you are on vendor-specific ISP firmware that prevents you from flashing generic firmware, copy the ISP-provided firmware to the project root directory and rename it to "zyxel-3.3-squashfs-rollback.bin." 
Run the "repack_firmware" , it will transfer the signature from the ISP-specific firmware to your custom OpenWrt build (final.bin).


## Target Chipset

The tools will work specifically with:

| Component | Specification |
|-----------|---------------|
| **Chipset** | MediaTek/Airoha EN751627 |
| **Target Routers** | Zyxel EX3301-T0, Zyxel DX3310-T0 |


## License

This project is licensed under the GNU General Public License v2.0.
Most of the code was taken from opensource , some part is written by students of embedded engineering and reviewed by project researcher.

---

**Status:** Beta Testing  
**Last Updated:** April 2026

#
