FROM runpod/worker-comfyui:5.8.5-base

# Custom node + all models in one RUN = one layer = single export, single push.
# Splitting into multiple RUNs hits RunPod Hub's 30 min cap on layer export.
RUN cd /comfyui/custom_nodes && \
    git clone --depth=1 https://github.com/gseth/ControlAltAI-Nodes && \
    comfy model download --url https://huggingface.co/pqhaz/klein-snofs/resolve/main/snofsSexNudesAndOtherFunStuff_v13Base.safetensors --relative-path models/diffusion_models --filename snofsSexNudesAndOtherFunStuff_v13Base.safetensors && \
    comfy model download --url https://huggingface.co/pqhaz/klein-snofs/resolve/main/kleinSnofsV13.safetensors --relative-path models/loras --filename kleinSnofsV13.safetensors && \
    comfy model download --url https://huggingface.co/Comfy-Org/vae-text-encorder-for-flux-klein-9b/resolve/main/split_files/text_encoders/qwen_3_8b_fp8mixed.safetensors --relative-path models/text_encoders --filename qwen_3_8b_fp8mixed.safetensors && \
    comfy model download --url https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors --relative-path models/vae --filename flux2-vae.safetensors
