#!/bin/sh

# written by Qureshi Majad for LUCI on ex3301-T0
ENABLED=$(uci -q get wireless.mesh.enabled)

if [ "$ENABLED" != "1" ]; then
    echo "Mesh disabled. Restoring default routing..."

    killall -CONT zyMAPSteer 2>/dev/null
    killall -CONT wapp 2>/dev/null
    killall -CONT mapd 2>/dev/null
    for pid in $(ps | grep chk_do_power_save | grep -v grep | awk '{print $1}'); do
        kill -CONT $pid 2>/dev/null
    done

    chroot /tmp/zyxel_root /usr/sbin/iwpriv apcli0 set ApCliEnable=0
    ifdown mesh 2>/dev/null
    
    chroot /tmp/zyxel_root /usr/sbin/iptables -t nat -F
    chroot /tmp/zyxel_root /usr/sbin/iptables -t nat -A POSTROUTING -o nas10 -j MASQUERADE
    exit 0
fi

# no sleep
#killall -STOP zyMAPSteer 2>/dev/null
#killall -STOP wapp 2>/dev/null
#killall -STOP mapd 2>/dev/null
#for pid in $(ps | grep chk_do_power_save | grep -v grep | awk '{print $1}'); do
#    kill -STOP $pid 2>/dev/null
#done

ifconfig ra1 down 2>/dev/null
ifconfig ra2 down 2>/dev/null
ifconfig ra3 down 2>/dev/null

SSID=$(uci -q get wireless.mesh.ssid)
BSSID=$(uci -q get wireless.mesh.bssid)
PASS=$(uci -q get wireless.mesh.password)
CH=$(uci -q get wireless.mesh.channel)
CH=${CH:-1}

ifconfig apcli0 down
ifconfig apcli0 up
chroot /tmp/zyxel_root /usr/sbin/iwpriv apcli0 set ApCliEnable=0
chroot /tmp/zyxel_root /usr/sbin/iwpriv ra0 set Psm=0
chroot /tmp/zyxel_root /usr/sbin/iwpriv apcli0 set Psm=0
chroot /tmp/zyxel_root /usr/sbin/iwpriv ra0 set AutoChannelSel=0
chroot /tmp/zyxel_root /usr/sbin/iwpriv ra0 set Channel=$CH
chroot /tmp/zyxel_root /usr/sbin/iwpriv ra0 set HtBw=0
chroot /tmp/zyxel_root /usr/sbin/iwpriv ra0 set GreenAP=0

chroot /tmp/zyxel_root /usr/sbin/iwpriv ra0 set SiteSurvey=1
sleep 8

chroot /tmp/zyxel_root /usr/sbin/iwpriv apcli0 set ApCliAuthMode=WPA2PSK
chroot /tmp/zyxel_root /usr/sbin/iwpriv apcli0 set ApCliEncrypType=AES
chroot /tmp/zyxel_root /usr/sbin/iwpriv apcli0 set ApCliSsid="$SSID"
chroot /tmp/zyxel_root /usr/sbin/iwpriv apcli0 set ApCliWPAPSK="$PASS"
chroot /tmp/zyxel_root /usr/sbin/iwpriv apcli0 set ApCliBssid="$BSSID"


chroot /tmp/zyxel_root /usr/sbin/iwpriv apcli0 set ApCliEnable=1
chroot /tmp/zyxel_root /usr/sbin/iwpriv ra0 set RadioOn=0
sleep 3
chroot /tmp/zyxel_root /usr/sbin/iwpriv ra0 set RadioOn=1
#chroot /tmp/zyxel_root /usr/sbin/iwpriv ra0 set AutoChannelSel=0
#chroot /tmp/zyxel_root /usr/sbin/iwpriv ra0 set Channel=$CH

sleep 5

# Openwrt will do it
ifup mesh
# double nat
chroot /tmp/zyxel_root /usr/sbin/iptables -t nat -F
chroot /tmp/zyxel_root /usr/sbin/iptables -t nat -A POSTROUTING -o nas10 -j MASQUERADE
chroot /tmp/zyxel_root /usr/sbin/iptables -t nat -A POSTROUTING -o br-mesh -j MASQUERADE
chroot /tmp/zyxel_root /usr/sbin/iptables -t mangle -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
chroot /tmp/zyxel_root /usr/sbin/iptables -P FORWARD ACCEPT
echo 1 > /proc/sys/net/ipv4/ip_forward
#leave it
#echo 1 > /proc/tc3162/hwnat_off
