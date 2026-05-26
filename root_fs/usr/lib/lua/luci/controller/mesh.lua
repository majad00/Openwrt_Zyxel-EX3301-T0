module("luci.controller.mesh", package.seeall)

function index()
    entry({"admin", "network", "mesh_backhaul"}, cbi("mesh_backhaul"), _("Mesh Backhaul"), 90)
end
module("luci.controller.mesh", package.seeall)

function index()
    entry({"admin", "network", "mesh_backhaul"}, cbi("mesh_backhaul"), _("Mesh Backhaul"), 90)
    entry({"admin", "network", "mesh_scan"}, call("action_scan"), nil).leaf = true
end

function action_scan()
    local sys = require "luci.sys"

    -- 1. Trigger the hardware site survey
    sys.exec("chroot /tmp/zyxel_root /usr/sbin/iwpriv ra0 set SiteSurvey=1")
    sys.exec("sleep 4")

    -- 2. Read directly from the Zyxel Mediatek driver
    local raw_scan = sys.exec("chroot /tmp/zyxel_root /usr/sbin/iwpriv ra0 get_site_survey 2>/dev/null")
    
    local results = {}
    
    if raw_scan then
        for line in raw_scan:gmatch("[^\r\n]+") do
            -- Skip header lines
            if not line:match("^No%s+Ch") and not line:match("get_site_survey") then
                
                -- EXACT PARSER FOR ZYXEL EX3301-T0:
                -- Matches: [Index] [Channel] [SSID] [MAC Address] [Security] [RSSI]
                local channel, ssid, bssid, signal = line:match("^%s*%d+%s+(%d+)%s+(.-)%s+([%x]+:[%x]+:[%x]+:[%x]+:[%x]+:[%x]+)%s+%S+%s+(%-%d+)")
                
                if bssid then
                    -- Clean up any rogue trailing spaces from the SSID
                    ssid = ssid:match("^%s*(.-)%s*$")
                    if ssid == "" then ssid = "Hidden" end

                    table.insert(results, {bssid=bssid, ssid=ssid, channel=channel, signal=signal})
                end
            end
        end
    end

    -- 3. Build JSON response
    local json_str = "["
    local first = true
    for _, net in ipairs(results) do
        if not first then json_str = json_str .. "," end
        local safe_ssid = string.gsub(net.ssid, '"', '\\"')
        json_str = json_str .. string.format('{"bssid":"%s","ssid":"%s","channel":"%s","signal":"%s"}', 
            net.bssid, safe_ssid, net.channel, net.signal)
        first = false
    end
    json_str = json_str .. "]"

    luci.http.prepare_content("application/json")
    luci.http.write(json_str)
end
module("luci.controller.mesh", package.seeall)

function index()
    entry({"admin", "network", "mesh_backhaul"}, cbi("mesh_backhaul"), _("Mesh Backhaul"), 90)
    entry({"admin", "network", "mesh_scan"}, call("action_scan"), nil).leaf = true
end

function action_scan()
    local sys = require "luci.sys"


    sys.exec("chroot /tmp/zyxel_root /usr/sbin/iwpriv ra0 set SiteSurvey=1")
    sys.exec("sleep 4")

    local raw_scan = sys.exec("chroot /tmp/zyxel_root /usr/sbin/iwpriv ra0 get_site_survey 2>/dev/null")
    
    local results = {}
    
    if raw_scan then
        for line in raw_scan:gmatch("[^\r\n]+") do

            if not line:match("^No%s+Ch") and not line:match("get_site_survey") then
                
                -- EXACT PARSER FOR ZYXEL EX3301-T0:
                -- Matches: [Index] [Channel] [SSID] [MAC Address] [Security] [RSSI]
                local channel, ssid, bssid, signal = line:match("^%s*%d+%s+(%d+)%s+(.-)%s+([%x]+:[%x]+:[%x]+:[%x]+:[%x]+:[%x]+)%s+%S+%s+(%-%d+)")
                
                if bssid then

                    ssid = ssid:match("^%s*(.-)%s*$")
                    if ssid == "" then ssid = "Hidden" end

                    table.insert(results, {bssid=bssid, ssid=ssid, channel=channel, signal=signal})
                end
            end
        end
    end
 
    local json_str = "["
    local first = true
    for _, net in ipairs(results) do
        if not first then json_str = json_str .. "," end
        local safe_ssid = string.gsub(net.ssid, '"', '\\"')
        json_str = json_str .. string.format('{"bssid":"%s","ssid":"%s","channel":"%s","signal":"%s"}', 
            net.bssid, safe_ssid, net.channel, net.signal)
        first = false
    end
    json_str = json_str .. "]"

    luci.http.prepare_content("application/json")
    luci.http.write(json_str)
end
