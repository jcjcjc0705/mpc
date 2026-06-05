# MPC Isaac — Docker 執行環境（Linux）

ROS2 Humble container，搭配 Isaac Sim 5.x 執行四輪車 MPC 控制。
本 branch 適用於 **Linux 主機同時執行 Isaac Sim 與 Docker container** 的環境。

> WSL2（Windows + WSL2）環境請切換至 [`wsl` branch](../../tree/wsl)。

## 專案結構

```
mpc_isaac/          ← 主專案根目錄（需自行 clone）
├── src/            ← ROS2 package（掛入 container）
├── model/          ← PyTorch 模型（掛入 container）
├── config.json     ← MPC 設定（掛入 container）
└── docker/         ← 本 repo 的檔案放這裡
    ├── compose/
    │   ├── .env                   # image 與 ROS_DOMAIN_ID 設定
    │   └── docker-compose-mpc.yml
    └── scripts/
        └── mpc.sh                 # 唯一入口
```

## 環境需求

- Ubuntu 22.04
- Docker Engine
- Isaac Sim 5.x（同一台主機）
- ROS2 Humble（讓 Isaac Sim 可發布 topic）

## 取得 docker 檔案

```bash
# 放到主專案的 docker/ 下
cd ~/mpc_isaac
git clone https://github.com/jcjcjc0705/mpc.git docker
```

## Isaac Sim 啟動方式

Isaac Sim 必須從有 source ROS2 的終端機啟動：

```bash
source /opt/ros/humble/setup.bash
export FASTDDS_BUILTIN_TRANSPORTS=UDPv4
cd ~/Desktop/isaac_sim_5.1
./isaac-sim.selector.sh
```

啟動後：
1. **Window → Extensions** → 搜尋 `ros2_bridge` → 確認啟用
2. 開啟 `mpc.usd` 場景
3. 在 Stage 中 Shift+選取車體 prim 和 BasisCurves 路徑 prim
4. 按 **Play（▶）**

## 執行

```bash
# 從主專案根目錄執行
./docker/scripts/mpc.sh
```

腳本會依序：
1. Pull 最新 image
2. 啟動 container（掛載 src/model/config）
3. 進入 shell

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
