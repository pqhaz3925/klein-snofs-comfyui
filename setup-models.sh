#!/bin/bash
# Symlinks /comfyui/models → /runpod-volume/models (network volume mount on
# serverless), then downloads any missing model files.
set -euo pipefail

VOLUME_MODELS=/runpod-volume/models
COMFY_MODELS=/comfyui/models

# If volume is mounted, point ComfyUI's models dir at it.
if [ -d /runpod-volume ]; then
  mkdir -p "$VOLUME_MODELS"
  if [ ! -L "$COMFY_MODELS" ]; then
    rm -rf "$COMFY_MODELS"
    ln -s "$VOLUME_MODELS" "$COMFY_MODELS"
  fi
fi

declare -A MODELS=(
  ["diffusion_models/snofsSexNudesAndOtherFunStuff_v13Base.safetensors"]="${DIFFUSION_URL:-https://dl.pqhaz.cc/snofsSexNudesAndOtherFunStuff_v13Base.safetensors}"
  ["loras/kleinSnofsV13.safetensors"]="${LORA_URL:-https://dl.pqhaz.cc/loras/kleinSnofsV13.safetensors}"
  ["text_encoders/qwen_3_8b_fp8mixed.safetensors"]="${TEXT_ENCODER_URL:-https://huggingface.co/Comfy-Org/vae-text-encorder-for-flux-klein-9b/resolve/main/split_files/text_encoders/qwen_3_8b_fp8mixed.safetensors}"
  ["vae/flux2-vae.safetensors"]="${VAE_URL:-https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors}"
)

for rel in "${!MODELS[@]}"; do
  full="$COMFY_MODELS/$rel"
  url="${MODELS[$rel]}"
  if [ -f "$full" ]; then
    echo "[setup-models] present: $rel"
    continue
  fi
  mkdir -p "$(dirname "$full")"
  echo "[setup-models] downloading $rel"
  curl -fSL --retry 3 --retry-delay 5 -o "$full.tmp" "$url"
  mv "$full.tmp" "$full"
done

exec "$@"
