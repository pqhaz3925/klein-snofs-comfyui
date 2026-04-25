# RunPod ComfyUI worker for FLUX.2 Klein 9B + snofs (sex/nudes v13).
# Base image already contains ComfyUI, comfy-cli, and ComfyUI-Manager.
FROM runpod/worker-comfyui:5.7.1-base

# --- custom nodes ----------------------------------------------------------
# ControlAltAI is missing from ComfyRegistry, so install all three by git
# (uniform handling, no registry surprises).
RUN cd /comfyui/custom_nodes && \
    git clone --depth=1 https://github.com/KGBicheno/ComfyUI_Image_Size_Tool && \
    git clone --depth=1 https://github.com/WASasquatch/was-node-suite-comfyui && \
    git clone --depth=1 https://github.com/gseth/ControlAltAI-Nodes && \
    for d in ComfyUI_Image_Size_Tool was-node-suite-comfyui ControlAltAI-Nodes; do \
      [ -f "$d/requirements.txt" ] && pip install --no-cache-dir -r "$d/requirements.txt" || true; \
    done

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
