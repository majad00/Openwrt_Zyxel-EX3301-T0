local nw = require "luci.model.network"
local sys = require "luci.sys"
local http = require "luci.http"
local dsp = require "luci.dispatcher"

local scan_api_url = dsp.build_url("admin", "network", "mesh_scan")


local apply_msg = ""
if http.formvalue("cbi.apply") then
    apply_msg = [[
    <div id="mesh-loading" style="padding: 15px; background-color: #fff3cd; color: #856404; border: 1px solid #ffeeba; margin-bottom: 20px; font-weight: bold; border-radius: 4px;">
        <span id="mesh-timer">Applying Mesh Settings... Please wait 20 seconds. (20)</span>
    </div>
    <script type="text/javascript">
        var btns = document.querySelectorAll('.cbi-button-apply, .cbi-button-save');
        btns.forEach(function(b){ b.disabled = true; b.style.opacity = '0.5'; });
        var timeLeft = 20;
        var timer = setInterval(function() {
            timeLeft--;
            var timerEl = document.getElementById('mesh-timer');
            if (timerEl) { timerEl.innerText = 'Applying Mesh Settings in the background... Please wait ' + timeLeft + ' seconds.'; }
            if (timeLeft <= 0) {
                clearInterval(timer);
                window.location.replace(window.location.pathname + window.location.search);
            }
        }, 1000);
    </script>
    ]]
end


local scanner_js = [[
<script type="text/javascript">
    function openScanner() {
        var modal = document.createElement('div');
        modal.id = 'wifi-modal';
        modal.style.cssText = 'position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.7);z-index:9999;display:flex;justify-content:center;align-items:center;';
        
        var content = document.createElement('div');
        content.style.cssText = 'background:#fff;padding:20px;border-radius:8px;width:90%;max-width:700px;max-height:80%;overflow-y:auto;box-shadow: 0 4px 20px rgba(0,0,0,0.5);';
        content.innerHTML = '<h3 style="margin-top:0;">Scanning Airspace...</h3><p>Waking up the radio and looking for networks. This may takes time...</p>';
        
        modal.appendChild(content);
        document.body.appendChild(modal);

        var xhr = new XMLHttpRequest();
        xhr.open('GET', ']] .. scan_api_url .. [[', true);
        xhr.onload = function() {
            if (xhr.status === 200) {
                try {
                    var nets = JSON.parse(xhr.responseText);
                    var html = '<h3 style="margin-top:0;">Select Parent Network</h3>';
                    html += '<table class="table cbi-section-table" style="width:100%; text-align:left;">';
                    html += '<tr><th>Signal</th><th>SSID</th><th>BSSID (MAC)</th><th>Channel</th><th>Action</th></tr>';
                    
                    nets.sort((a,b) => parseInt(b.signal) - parseInt(a.signal));  
                    
                    nets.forEach(function(net) {
                        if (net.ssid && net.ssid !== "Hidden") {
                            var safeSsid = net.ssid.replace(/'/g, "\\'");
                            html += '<tr style="border-bottom: 1px solid #ddd;">' +
                                '<td style="padding:8px;"><strong>' + net.signal + ' dBm</strong></td>' +
                                '<td style="padding:8px; color:#0069d9; font-weight:bold;">' + net.ssid + '</td>' +
                                '<td style="padding:8px; font-family:monospace;">' + net.bssid + '</td>' +
                                '<td style="padding:8px;">' + net.channel + '</td>' +
                                '<td style="padding:8px;"><button class="btn cbi-button cbi-button-apply" onclick="selectWifi(\'' + safeSsid + '\', \'' + net.bssid + '\', ' + net.channel + ')">Select</button></td>' +
                                '</tr>';
                        }
                    });
                    html += '</table><br><div style="text-align:right;"><button class="btn cbi-button cbi-button-reset" onclick="closeScanner()">Cancel</button></div>';
                    content.innerHTML = html;
                } catch(e) {
                    content.innerHTML = '<h3>Error</h3><p>Could not parse scan results.</p><button class="btn cbi-button" onclick="closeScanner()">Close</button>';
                }
            } else {
                content.innerHTML = '<h3>Error</h3><p>Failed to scan airspace.</p><button class="btn cbi-button" onclick="closeScanner()">Close</button>';
            }
        };
        xhr.send();
    }

    function closeScanner() {
        var modal = document.getElementById('wifi-modal');
        if (modal) modal.remove();
    }

    function selectWifi(ssid, bssid, channel) {
        document.querySelector('input[name="cbid.wireless.mesh.ssid"]').value = ssid;
        document.querySelector('input[name="cbid.wireless.mesh.bssid"]').value = bssid;
        document.querySelector('input[name="cbid.wireless.mesh.channel"]').value = channel;
        closeScanner();
    }
</script>
]]

m = Map("wireless", translate("Mesh Wi-Fi Backhaul"), 
    translate("Creating a Wi-Fi mesh backbone will replace the physical WAN port.") .. "<br/><br/>" .. apply_msg .. scanner_js)

s_status = m:section(TypedSection, "wifi-mesh", translate("Live Connection Status"))
s_status.anonymous = true
s_status.addremove = false

ip = s_status:option(DummyValue, "_ip", translate("Interface IP"))
ip.value = "Not Connected"
local device = luci.sys.exec("ifconfig br-mesh 2>/dev/null | grep 'inet addr' | awk '{print $2}' | cut -d: -f2")
if device and #device > 0 then ip.value = device end

rssi = s_status:option(DummyValue, "_rssi", translate("Signal Strength"))
rssi.value = "No Signal"
local signal = luci.sys.exec("chroot /tmp/zyxel_root /usr/sbin/iwpriv apcli0 stat | grep Rssi | awk '{print $2}'")
if signal and #signal > 0 and signal ~= "0" then rssi.value = signal .. " dBm" end

s = m:section(NamedSection, "mesh", "wifi-mesh", translate("Main Wi-Fi AP"))
s.anonymous = true

e = s:option(ListValue, "enabled", translate("Mesh Backhaul Status"))
e:value("1", translate("Enabled"))
e:value("0", translate("Disabled"))

local function validate_required(self, value, section)
    local is_enabled = self.map:formvalue("cbid.wireless." .. section .. ".enabled")
    if is_enabled == "1" then
        if not value or value == "" then return nil, translate("This field is REQUIRED when Mesh is Enabled.") end
    end
    return value
end

ssid = s:option(Value, "ssid", translate("Parent SSID"))
ssid.description = '<br/><button type="button" class="cbi-button cbi-button-action" onclick="openScanner()" style="padding:5px 10px; margin-top:5px;">Scan Nearby Networks</button>'
ssid:depends("enabled", "1")
ssid.validate = validate_required

bssid = s:option(Value, "bssid", translate("Parent BSSID"))
bssid:depends("enabled", "1")
bssid.datatype = "macaddr"
bssid.validate = validate_required

p = s:option(Value, "password", translate("Password"))
p.password = true
p:depends("enabled", "1")
p.validate = validate_required

c = s:option(Value, "channel", translate("Target Channel"))
c:depends("enabled", "1")
c.datatype = "uinteger"
c.validate = validate_required

m.on_after_commit = function(self)
    luci.sys.call("( sleep 2 && /usr/bin/wifi-backhaul.sh >/dev/null 2>&1 & )")
end

return m
