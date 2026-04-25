# RunPod ComfyUI worker for FLUX.2 Klein 9B + snofs (sex/nudes v13).
# Base image already contains ComfyUI, comfy-cli, and ComfyUI-Manager.
FROM runpod/worker-comfyui:5.7.1-base

# --- custom nodes ----------------------------------------------------------
# Only ControlAltAI is required (FluxResolutionNode). Missing from ComfyRegistry,
# so install via git.
RUN cd /comfyui/custom_nodes && \
    git clone --depth=1 https://github.com/gseth/ControlAltAI-Nodes && \
    [ -f ControlAltAI-Nodes/requirements.txt ] && \
      pip install --no-cache-dir -r ControlAltAI-Nodes/requirements.txt || true

# --- models ----------------------------------------------------------------
# diffusion model (~17GB) — mirror on dl.pqhaz.cc (origin: civitai)
RUN comfy model download \
    --url https://dl.pqhaz.cc/snofsSexNudesAndOtherFunStuff_v13Base.safetensors \
    --relative-path models/diffusion_models \
    --filename snofsSexNudesAndOtherFunStuff_v13Base.safetensors

# LoRA (~1GB) — mirror on dl.pqhaz.cc (origin: civitai)
RUN comfy model download \
    --url https://dl.pqhaz.cc/loras/kleinSnofsV13.safetensors \
    --relative-path models/loras \
    --filename kleinSnofsV13.safetensors

# text encoder (~8.7GB) — Comfy-Org HF
RUN comfy model download \
    --url https://huggingface.co/Comfy-Org/vae-text-encorder-for-flux-klein-9b/resolve/main/split_files/text_encoders/qwen_3_8b_fp8mixed.safetensors \
    --relative-path models/text_encoders \
    --filename qwen_3_8b_fp8mixed.safetensors

# VAE (~336MB) — Comfy-Org HF
RUN comfy model download \
    --url https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors \
    --relative-path models/vae \
    --filename flux2-vae.safetensors
