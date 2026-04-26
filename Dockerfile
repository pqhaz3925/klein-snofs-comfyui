# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.8.5-base

# install custom nodes into comfyui
RUN comfy-node-install controlaltai-nodes

# download models into comfyui
# Diffusion model
RUN comfy model download --url https://dl.pqhaz.cc/snofsSexNudesAndOtherFunStuff_v13Base.safetensors --relative-path models/diffusion_models --filename snofsSexNudesAndOtherFunStuff_v13Base.safetensors

# LoRA
RUN comfy model download --url https://dl.pqhaz.cc/loras/kleinSnofsV13.safetensors --relative-path models/loras --filename kleinSnofsV13.safetensors

# CLIP text encoder
RUN comfy model download --url https://huggingface.co/Comfy-Org/vae-text-encorder-for-flux-klein-9b/resolve/main/split_files/text_encoders/qwen_3_8b_fp8mixed.safetensors --relative-path models/text_encoders --filename qwen_3_8b_fp8mixed.safetensors

# VAE
RUN comfy model download --url https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors --relative-path models/vae --filename flux2-vae.safetensors
