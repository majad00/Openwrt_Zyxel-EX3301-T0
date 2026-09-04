# Openwrt for Zyxel EX3301-T0 

[![License: GPL v2](https://img.shields.io/badge/License-GPL%20v2-blue.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/majad00/Openwrt_Zyxel-EX3301-T0)](https://github.com/majad00/Openwrt_Zyxel_EX3310-T0/releases)
[![Downloads](https://img.shields.io/github/downloads/majad00/Openwrt_Zyxel-EX3301-T0/releases/tag/Openwrt)](https://github.com/majad00/Openwrt_Zyxel-EX3301-T0/releases/tag/Openwrt)

OpenWrt for Zyxel EX3301-T0 is a community-built version developed using ImageBuilder and the OpenWrt 15.05 source code. After flashing it through the OEM firmware upgrade, you can start using this OpenWrt build immediately. If needed, you can revert to the OEM firmware by using a rollback firmware or by installing the latest Zyxel firmware.
>
**Version V-17 is stable release which includes support for Wi-Fi backhaul.**
## Troubleshooting
> If you are on vender specific ISP please rebuild custom firmware ( see section "Build from source")

## Quick Download

**[Download Latest Release](https://github.com/majad00/Openwrt_Zyxel-EX3301-T0/releases/download/Openwrt/Openwrt_Zyxel_EX3301-T0-v-17.zip)**
	Current version : v-17 sha256:51f54da0664e07d09ea402921952b7b1886704f3d9f7cae75819464bc0a12f4e
The download includes:
- `openwrt-15.5-zyxel-matrix-v-17-squashfs-sysupgrade.bin` - Zyxel-Matrix for DX3301-T0 and EX3301-T0
- `zyxel-3.3-squashfs-rollback.bin` - Roll Back to Zyxal factory firmware
- `README.txt` - Complete instructions
- `CHANGELOG.txt` - Version history
- `docs` - for detail documentations and installation
  
## Flashing  

1. **Connect** Ethernet cable from PC to router
2. **Login to router**: Login to OEM Zyxel router through web
3. **Flash**: From drop down menu Select Maintenance → click Firmware Upgrade
4. **Wait** 2-3 minutes for first boot
5. **Connect WiFi**: `Zyxel_Matrix` / `12345678` ( Enable through LUCI)
6. **Configure**: http://192.168.1.1 (root/no passwrod )

> ⚠️ **IMPORTANT**: Change password after first boot!, on successfull boot the network LED starts blinking


##  Flashing using UART (safe for testing or recovery from brick)
1. **Connect** Using TX, RX and GND, rename the firmware to RAS.bin (optional)
2. **Get to Shell**: Intrupt boot process by pressing any button
3. **Prepare**: Type "ATUR RAS.bin" ( router will start a tftp server and wait for the file)
4. **Flash**: Send RAS.bin file using TFTP, tftp 192.168.1.1 
5. **Wait**: Bootloader will write RAS.bin to proper offsets, Power LED is red
6. **First Boot**: router will reboot, wait for 2-3 minutes for first boot

##  Build from source

⚠️ **IMPORTANT**: Please use instruction below without modification to the source (root_fs) and check the size of "final.bin" at the end if it match to the provided BIN of sysupgrade firmware , then your build setup is good.


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
   chmod +x repack_firmware_v17
   ```

4. **Run the Firmware Repack Script:**  
   Execute the script with superuser privileges:  it will repack firmware and sign it as well.
   ```
   sudo ./repack_firmware_v17
   ```

5. **Custome firmware:**  
   The custom firmware  will be in the root directory under the name "final.bin." If your custom firmware causes the router to become unresponsive, please refer to the UART installation guide. Only proceed with flashing custom firmware (final.bin) if you have UART recovery available or if you are confident in your abilities.



⚠️ **Note**: If you are on vendor-specific ISP firmware that prevents you from flashing generic firmware, copy the ISP-provided firmware to the project root directory and rename it to "zyxel-3.3-squashfs-rollback.bin." 
Run the "repack_firmware" , it will transfer the signature from the ISP-specific firmware to your custom OpenWrt build (final.bin).

## 📋 Detailed Documentation

- [Building from Source](docs/build_guide.md)
- [Changelog](CHANGELOG.txt)

## 🔧 Default Settings

| Mode | IP Address | WiFi SSID | WiFi Password | Login |
|------|------------|-----------|---------------|-------|
| **AP Mode** | 192.168.1.1 | Zyxel_Matrix | 12345678 | root/1234 |

## 🔥 Custom firewall rules and logging

This firmware does not ship the OpenWrt firewall service (`/etc/init.d/firewall` / `fw3`):
netfilter is configured by the Zyxel side (`zyxel_lan`, `wifi-backhaul.sh`). Because of that,
rules written to `/etc/firewall.user` (LuCI → Network → Firewall → Custom Rules) were never
executed and silently disappeared on every reboot.

Since this change `/usr/sbin/apply-firewall-user` runs `/etc/firewall.user`:

- at the end of boot (`zyxel_lan`),
- after every NAT flush done by `wifi-backhaul.sh`,
- on every `ifup` of the WAN interface (hotplug), i.e. after each PPPoE reconnect.

The file is therefore executed several times: write **idempotent** rules, for example

```sh
# block a LAN device from reaching the Internet
iptables -C FORWARD -s 192.168.1.50 -o pppoe-wan -j DROP 2>/dev/null || \
  iptables -I FORWARD 1 -s 192.168.1.50 -o pppoe-wan -j DROP
```

**Logs.** The default `logd` ring buffer was 16 KiB (a couple of minutes of Zyxel `zcmd`
chatter) and nothing survives a reboot. The default is now 256 KiB (`log_size` in
`/etc/config/system`). To keep the last lines before a crash/reboot, send the log to another
machine on the LAN:

```sh
uci set system.@system[0].log_ip='192.168.1.10'   # any host running a syslog UDP receiver
uci set system.@system[0].log_port='514'
uci set system.@system[0].log_proto='udp'
uci commit system && /etc/init.d/log restart
```

## 🛠️ Development

This project include busybox based on OpenWrt. To build from source:
See Source, for installing precompiled firmware see Release,
