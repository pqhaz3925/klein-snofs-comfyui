#!/bin/bash
# Launches ComfyUI on 8188 (background) + vast-pyworker (foreground).
# Vast autoscaler talks to pyworker, pyworker proxies to ComfyUI.
set -e

mkdir -p /workspace/state

# Start ComfyUI in background
(
  cd /comfyui
  python main.py --listen 127.0.0.1 --port 8188 --disable-auto-launch \
    --enable-cors-header 2>&1 | tee /workspace/state/comfyui.log
) &

# Wait for ComfyUI to be reachable before exposing pyworker
for i in $(seq 1 60); do
  if curl -fsS http://127.0.0.1:8188/system_stats >/dev/null 2>&1; then
    echo "[launch] ComfyUI up after ${i}x2s"
    break
  fi
  sleep 2
done

# Start vast-pyworker (foreground — keeps container alive)
export BACKEND=comfyui
cd /home/workspace/vast-pyworker
exec ./start_server.sh comfyui
