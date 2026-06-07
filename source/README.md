# Openwrt 14.5mcommunity build for EX3301-T0
## 📦 Large Files Download

Due to GitHub size limitations, large files are hosted externally. The following source files are required for building:

### Required Source Files

| File | Description |
|------|-------------|
| `OpenWrt-ImageBuilder-15.05.1-ar71xx-generic.Linux-x86_64.tar.bz2` | OpenWrt Image Builder (137 MB) |
| `OpenWrt-SDK-15.05.1-ar71xx-generic_gcc-4.8-linaro_uClibc-0.9.33.2.Linux-x86_64.tar.bz2` | OpenWrt SDK (75 MB) |
| `busybox-1.36.1.tar.bz2` | BusyBox utilities |
| `squashfs4.2.tar.gz` | SquashFS tools |

### Download Links

> **Note:** Download links will be provided after beta testing. Please check back later.

- [OpenWrt ImageBuilder](https://downloads.openwrt.org/releases/15.05.1/) (or use your own copy)
- [OpenWrt SDK](https://downloads.openwrt.org/releases/15.05.1/)
- [BusyBox](https://busybox.net/downloads/)
- [SquashFS](https://github.com/plougher/squashfs-tools)

## 🏗️ Building from Source

### Important Notice

> **Rootfs is the only part of the firmware that can be built with open-source code.** The remaining components are proprietary and not shared. It does not mean that you can not create a firmware , actually everything in firmware can be modified except Kernel.
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

## 📁 Directory Structure
Openwrt_Zyxel-EX3301-T0/
├── source/ # Required source files (download here)

├── xx3301/ # Build configuration

├── rootfs/ # Root filesystem (modify this)

├── docs/ # Documentation

├── final.bin # Generated firmware output

├── firmware.bin # Generated firmware output

├── README.md # This file

├── LICENSE # GPL v2 License

├── CHANGELOG.txt # Version history

└── QUICK-START.txt # Quick start guide

└── repack_firmware # repacking and signing utility


## ⚠️ License

This project is licensed under the GNU General Public License v2.0. Proprietary components remain the property of their respective owners and are not shared. The firmware leaves all property utilities on the router under the OEM hardware.

---

**Status:** stable release after v-16  
**Last Updated:** April 2026
