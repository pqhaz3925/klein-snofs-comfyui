# RunPod ComfyUI worker for FLUX.2 Klein 9B + snofs (sex/nudes v13).
# Slim image (~3GB). Models live on a RunPod network volume mounted at
# /comfyui/models — populated by setup-models.sh on first start.
FROM runpod/worker-comfyui:5.8.5-base

# Custom node: ControlAltAI (FluxResolutionNode). Missing from ComfyRegistry,
# so install via git.
RUN cd /comfyui/custom_nodes && \
    git clone --depth=1 https://github.com/gseth/ControlAltAI-Nodes && \
    [ -f ControlAltAI-Nodes/requirements.txt ] && \
      pip install --no-cache-dir -r ControlAltAI-Nodes/requirements.txt || true

# Model bootstrap. Downloads to /comfyui/models if missing (idempotent —
# skips on warm starts when volume already populated).
COPY setup-models.sh /usr/local/bin/setup-models.sh
RUN chmod +x /usr/local/bin/setup-models.sh

ENTRYPOINT ["/usr/local/bin/setup-models.sh"]
# CMD inherited from base image (["/start.sh"]).
