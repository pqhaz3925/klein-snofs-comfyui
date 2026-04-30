# Vast.ai serverless image for klein-snofs.
# FROM the existing baked image (all models + custom node + comfyui).
# We strip the runpod handler and run ComfyUI + vast-pyworker instead.
FROM ghcr.io/pqhaz3925/klein-snofs-comfyui:latest

# python3-venv for vast-pyworker install
RUN apt-get update -qq && \
    apt-get install -y -qq python3-venv && \
    rm -rf /var/lib/apt/lists/*

# Clone vast-pyworker + drop in our comfyui backend.
RUN mkdir -p /home/workspace && cd /home/workspace && \
    git clone --depth=1 https://github.com/vast-ai/vast-pyworker.git
COPY comfyui/ /home/workspace/vast-pyworker/comfyui/

# Pre-build the venv so first start doesn't pay the install cost.
RUN python3 -m venv /home/workspace/worker-env && \
    /home/workspace/worker-env/bin/pip install --no-cache-dir -q \
      requests psutil flask nltk pycryptodome numpy && \
    touch /root/hasbooted2 /root/.no_auto_tmux

COPY launch.sh /launch.sh
RUN chmod +x /launch.sh

ENTRYPOINT []
CMD ["/launch.sh"]
