# UniFi UCG-Fiber PoE Fan Control
Automated PoE-based fan control script for UniFi UCG-Fiber. Uses local API to toggle PoE on port 4 according to PON module temperature, powering an external cooling fan.

基于 PoE 的 UniFi UCG-Fiber 自动风扇控制脚本。通过本地 API 根据 PON 模块温度控制 4 号端口的 PoE 供电，从而驱动外接散热风扇。

This repository provides a Bash script to control an external cooling fan for the UniFi UCG-Fiber gateway.  
The fan is powered by PoE from port 4, and the script automatically enables or disables PoE based on the temperature of the PON module.


### Features
- Periodically reads PON module temperature using `ethtool`.
- Toggles PoE on port 4 through the local UniFi API.
- Uses configurable high and low temperature thresholds for hysteresis control.
- Designed to run via `cron` on the UCG-Fiber itself.

### Prerequisites
- UniFi UCG-Fiber with firmware supporting local API.
- API key generated in UniFi Console (Settings → Control Plane → Integrations).
- External fan connected to port 4 (PoE powered).
- PON module inserted in port 7 (SFP+).
- SSH access to UCG-Fiber.

### Installation
1. Generate an API key in the UniFi Console, name it `PON_Fan_Control`, and save it securely.
2. SSH into UCG-Fiber and retrieve device information:
   ```
   curl -k -X GET 'https://127.0.0.1/proxy/network/api/s/default/stat/device' \
        -H 'X-API-KEY: YOUR_API_KEY' \
        -H 'Accept: application/json' \
        -o '/persistent/ucg_devices.json'
   ```
3. Download /persistent/ucg_devices.json and identify the correct device_id corresponding to UCG-Fiber (look for the entry with public IP).
4. Edit pon_fan_control.sh, configure your API key and device ID.
5. Upload the script to /persistent/scripts and make it executable:
`chmod +x /persistent/scripts/pon_fan_control.sh`
Schedule the script with cron (every 5 minutes):
```
crontab -e
*/5 * * * * /persistent/scripts/pon_fan_control.sh
```
