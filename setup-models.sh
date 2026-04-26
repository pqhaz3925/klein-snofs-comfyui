#!/bin/bash
# Downloads models into /comfyui/models on first start. If a network volume
# is mounted at /comfyui/models, files persist across cold starts (instant
# mount on subsequent runs).
set -euo pipefail

MODELS_DIR=/comfyui/models

declare -A MODELS=(
  ["diffusion_models/snofsSexNudesAndOtherFunStuff_v13Base.safetensors"]="${DIFFUSION_URL:-https://dl.pqhaz.cc/snofsSexNudesAndOtherFunStuff_v13Base.safetensors}"
  ["loras/kleinSnofsV13.safetensors"]="${LORA_URL:-https://dl.pqhaz.cc/loras/kleinSnofsV13.safetensors}"
  ["text_encoders/qwen_3_8b_fp8mixed.safetensors"]="${TEXT_ENCODER_URL:-https://huggingface.co/Comfy-Org/vae-text-encorder-for-flux-klein-9b/resolve/main/split_files/text_encoders/qwen_3_8b_fp8mixed.safetensors}"
  ["vae/flux2-vae.safetensors"]="${VAE_URL:-https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors}"
)

for rel in "${!MODELS[@]}"; do
  full="$MODELS_DIR/$rel"
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
