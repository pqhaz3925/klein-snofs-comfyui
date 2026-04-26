# RunPod ComfyUI worker for FLUX.2 Klein 9B + snofs (sex/nudes v13).
# Models are NOT baked into the image — they download on first container start
# (and persist if /comfyui/models is on a RunPod volume).
FROM runpod/worker-comfyui:5.7.1-base

# --- custom nodes ----------------------------------------------------------
# Only ControlAltAI is required (FluxResolutionNode). Missing from
# ComfyRegistry, so install via git.
RUN cd /comfyui/custom_nodes && \
    git clone --depth=1 https://github.com/gseth/ControlAltAI-Nodes && \
    [ -f ControlAltAI-Nodes/requirements.txt ] && \
      pip install --no-cache-dir -r ControlAltAI-Nodes/requirements.txt || true

# --- model bootstrap on container start ------------------------------------
# Downloads on first run, skips if files already exist (volume-aware).
# Override URLs via env vars: DIFFUSION_URL, LORA_URL, TEXT_ENCODER_URL, VAE_URL.
COPY setup-models.sh /usr/local/bin/setup-models.sh
RUN chmod +x /usr/local/bin/setup-models.sh

ENTRYPOINT ["/usr/local/bin/setup-models.sh"]
# CMD inherited from base image (["/start.sh"]).
