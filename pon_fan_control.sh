#!/bin/bash
# UniFi UCG-Fiber 温度控制 PoE 脚本

# ========== 配置 ==========
DEVICE_ID="your_device_id"	# 替换为实际 Device ID
API_KEY="your_api_key"		# 替换为实际 API Key
PORT_IDX=4					# 端口号 (从1开始计数，UCG-Fiber填4)
HIGH_TEMP=50				# 超过此温度打开 PoE
LOW_TEMP=43					# 低于此温度关闭 PoE
# ==========================

# 状态文件放在脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STATE_FILE="$SCRIPT_DIR/poe_temp_state"

# 获取温度（取第一行 Module temperature）
TEMP=$(ethtool -m eth6 2>/dev/null | grep "Module temperature" | head -n1 | awk '{print $4}')

if [[ -z "$TEMP" ]]; then
    echo "$(date) [WARN] 无法获取温度"
    exit 1
fi

# 读取上次状态 (auto/off)
if [[ -f "$STATE_FILE" ]]; then
    LAST_STATE=$(cat "$STATE_FILE")
else
    LAST_STATE="unknown"
fi

# 控制函数
set_poe_mode() {
    local MODE=$1
    curl -sk -X PUT \
        "https://127.0.0.1/proxy/network/api/s/default/rest/device/$DEVICE_ID" \
        -H "X-API-KEY: $API_KEY" \
        -H "Accept: application/json" \
        --data "{
          \"port_overrides\": [
            { \"port_idx\": $PORT_IDX, \"poe_mode\": \"$MODE\" }
          ]
        }" >/dev/null
    echo "$MODE" > "$STATE_FILE"
    echo "$(date) [INFO] 温度=${TEMP}°C, 设置PoE=$MODE"
}

# 判断逻辑 (浮点比较)
if awk "BEGIN{exit !($TEMP >= $HIGH_TEMP)}"; then
    if [[ "$LAST_STATE" != "auto" ]]; then
        set_poe_mode "auto"
    fi
elif awk "BEGIN{exit !($TEMP <= $LOW_TEMP)}"; then
    if [[ "$LAST_STATE" != "off" ]]; then
        set_poe_mode "off"
    fi
else
    echo "$(date) [INFO] 温度=${TEMP}°C, 状态保持=$LAST_STATE"
fi
