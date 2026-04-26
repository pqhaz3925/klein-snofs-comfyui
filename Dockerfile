# RunPod ComfyUI worker for FLUX.2 Klein 9B + snofs (sex/nudes v13).
# All models baked in — built on netcup where the mirror at dl.pqhaz.cc is
# local (full LAN speed downloads). Final image ~30GB.
FROM runpod/worker-comfyui:5.8.5-base

# --- custom nodes ----------------------------------------------------------
# Only ControlAltAI is required (FluxResolutionNode). Missing from
# ComfyRegistry, so install via git.
RUN cd /comfyui/custom_nodes && \
    git clone --depth=1 https://github.com/gseth/ControlAltAI-Nodes && \
    [ -f ControlAltAI-Nodes/requirements.txt ] && \
      pip install --no-cache-dir -r ControlAltAI-Nodes/requirements.txt || true

# --- models ----------------------------------------------------------------
# Single RUN = single layer. URLs hit dl.pqhaz.cc which is the same host
# during build, so transfer is loopback. HF assets fetched normally.
RUN set -e && \
    comfy model download \
      --url https://dl.pqhaz.cc/snofsSexNudesAndOtherFunStuff_v13Base.safetensors \
      --relative-path models/diffusion_models \
      --filename snofsSexNudesAndOtherFunStuff_v13Base.safetensors && \
    comfy model download \
      --url https://dl.pqhaz.cc/loras/kleinSnofsV13.safetensors \
      --relative-path models/loras \
      --filename kleinSnofsV13.safetensors && \
    comfy model download \
      --url https://huggingface.co/Comfy-Org/vae-text-encorder-for-flux-klein-9b/resolve/main/split_files/text_encoders/qwen_3_8b_fp8mixed.safetensors \
      --relative-path models/text_encoders \
      --filename qwen_3_8b_fp8mixed.safetensors && \
    comfy model download \
      --url https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors \
      --relative-path models/vae \
      --filename flux2-vae.safetensors
