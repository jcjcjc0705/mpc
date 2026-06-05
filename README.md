# MPC Isaac — Docker 執行環境（Windows + WSL2）

ROS2 Humble container，搭配 Isaac Sim 5.x 執行四輪車 MPC 控制。
本 branch 適用於 **Windows 主機執行 Isaac Sim + WSL2 執行 Docker container** 的環境。

## 專案結構

```
mpc_isaac/          ← 主專案根目錄（需自行 clone）
├── src/            ← ROS2 package（掛入 container）
├── model/          ← PyTorch 模型（掛入 container）
├── config.json     ← MPC 設定（掛入 container）
└── docker/         ← 本 repo 的檔案放這裡
    ├── compose/
    │   ├── .env                   # image 與 ROS_DOMAIN_ID 設定
    │   ├── docker-compose-mpc.yml
    │   └── fastdds_wsl.xml        # FastDDS unicast 設定（Windows IP 動態注入）
    └── scripts/
        └── mpc.sh                 # 唯一入口
```

## 環境需求

- Windows 11 + WSL2（Ubuntu 22.04）
- Docker Desktop for Windows（WSL2 backend）
- Isaac Sim 5.x（Windows 原生執行）
- ROS2 Humble for Windows（讓 Isaac Sim 可發布 topic）

## 首次設定

### 1. Windows 防火牆

開放 Isaac Sim → WSL2 的 ROS2 DDS 通訊埠（inbound UDP）：

```powershell
New-NetFirewallRule -DisplayName "ROS2 DDS" -Direction Inbound `
  -Protocol UDP -LocalPort 7400-7500 -Action Allow
```

### 2. 取得 docker 檔案

```bash
# 在 WSL2 內，放到主專案的 docker/ 下
cd ~/mpc_isaac
git clone https://github.com/jcjcjc0705/mpc.git -b wsl docker
```

## Isaac Sim 啟動方式

每次啟動前，在 PowerShell 設好環境變數再開 Isaac Sim：

```powershell
$env:FASTDDS_BUILTIN_TRANSPORTS = "UDPv4"
$env:ROS_DOMAIN_ID = "0"
cd C:\path\to\isaac_sim_5.1
.\isaac-sim.selector.bat
```

啟動後：
1. **Window → Extensions** → 搜尋 `ros2_bridge` → 確認啟用
2. 開啟 `mpc.usd` 場景
3. 在 Stage 中 Shift+選取車體 prim 和 BasisCurves 路徑 prim
4. 按 **Play（▶）**

## 執行

```bash
# 在 WSL2 內，從主專案根目錄執行
./docker/scripts/mpc.sh
```

腳本會自動：
1. 從 `/etc/resolv.conf` 解析 Windows host IP
2. 注入 FastDDS unicast 設定
3. Pull 最新 image
4. 啟動 container 並進入 shell

## Container 內初次執行

```bash
r                                        # colcon build + source
ros2 run car_control_pkg car_control_node
```

## 參數調整

修改 `docker/compose/.env`：

```env
IMAGE=registry.screamtrumpet.csie.ncku.edu.tw/pochun/mpc_isaac_image:latest
ROS_DOMAIN_ID=0
```
