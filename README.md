# UniFi UCG-Fiber PoE Fan Control
Automated PoE-based fan control script for UniFi UCG-Fiber. Uses local API to toggle PoE on port 4 according to PON module temperature, powering an external cooling fan.

基于 PoE 的 UniFi UCG-Fiber 自动风扇控制脚本。通过本地 API 根据 PON 模块温度控制 4 号端口的 PoE 供电，从而驱动外接散热风扇。

This repository provides a Bash script to control an external cooling fan for the UniFi UCG-Fiber gateway.  
The fan is powered by PoE from port 4, and the script automatically enables or disables PoE based on the temperature of the PON module.
本仓库提供一个 Bash 脚本，用于为 UniFi UCG-Fiber 网关控制外接散热风扇。
风扇通过 4 号端口的 PoE 供电，脚本会根据 PON 模块温度自动启用或关闭 PoE。


### Features
- Reads PON module temperature using `ethtool`.
- Toggles PoE on port 4 through the local UniFi API.
- Uses configurable high and low temperature thresholds for hysteresis control.
- Designed to run via `cron` on the UCG-Fiber itself.
### 功能
- 使用 `ethtool` 读取 PON 模块温度。
- 通过内置的 UniFi API 切换 4 号端口的 PoE。
- 使用可配置的高温和低温阈值，实现滞后启动的控制。
- 在 UCG-Fiber 上通过 `cron` 定时运行。

### Prerequisites
- UniFi UCG-Fiber with firmware supporting local API.
- API key generated in UniFi Console (Settings → Control Plane → Integrations).
- External fan connected to port 4 (PoE powered).
- PON module inserted in port 7 (SFP+).
- SSH access to UCG-Fiber.
### 前提条件
- UniFi UCG-Fiber 固件版本需支持 API。
- 在 UniFi 控制台中生成 API Key（设置 → 控制平面 → 集成）。
- 风扇连接至 4 号端口（PoE 供电）。
- PON 模块插入 7 号端口（SFP+）。
- 可通过 SSH 访问 UCG-Fiber。

### Installation
1. Generate an API key in the UniFi Console, name it `PON_Fan_Control`, and save it securely.
2. SSH into UCG-Fiber and retrieve device information:
   ```
   curl -k -X GET 'https://127.0.0.1/proxy/network/api/s/default/stat/device' \
        -H 'X-API-KEY: YOUR_API_KEY' \
        -H 'Accept: application/json' \
        -o '/persistent/ucg_devices.json'
   ```
3. Download `/persistent/ucg_devices.json` and identify the correct `device_id` corresponding to UCG-Fiber (look for the entry with public IP).
4. Edit `pon_fan_control.sh`, configure your API key and device ID.
5. Upload the script to `/persistent/scripts` and make it executable:
`chmod +x /persistent/scripts/pon_fan_control.sh`
Schedule the script with cron (every 5 minutes):
   ```
   crontab -e
   */5 * * * * /persistent/scripts/pon_fan_control.sh
   ```

### 安装步骤
1. 在 UniFi 控制台生成 API Key，名称建议设为 PON_Fan_Control，并妥善保存。
2. SSH 登录 UCG-Fiber，获取设备信息：
   ```
   curl -k -X GET 'https://127.0.0.1/proxy/network/api/s/default/stat/device' \
     -H 'X-API-KEY: YOUR_API_KEY' \
     -H 'Accept: application/json' \
     -o '/persistent/ucg_devices.json'
   ```
3. 下载 `/persistent/ucg_devices.json` 文件，找到带公网 IP 的条目，即为 UCG-Fiber 的 `device_id`。
4. 编辑 `pon_fan_control.sh`，填写 API Key 和设备 ID。
5. 将脚本上传至 `/persistent/scripts` 并赋予可执行权限：
`chmod +x /persistent/scripts/pon_fan_control.sh`
使用 cron 定时运行脚本（每 5 分钟执行一次）：
   ```
   crontab -e
   */5 * * * * /persistent/scripts/pon_fan_control.sh
   ```
