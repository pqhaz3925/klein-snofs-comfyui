# klein-snofs-comfyui

RunPod ComfyUI worker image for FLUX.2 Klein 9B with snofs v13 LoRA / base.

## Build

```bash
docker build -t klein-snofs-comfyui .
```

## Contents

| asset | path inside image | size |
|---|---|---|
| snofsSexNudesAndOtherFunStuff_v13Base | `models/diffusion_models/` | ~17GB |
| kleinSnofsV13 (LoRA) | `models/loras/` | ~1GB |
| qwen_3_8b_fp8mixed (text encoder) | `models/text_encoders/` | ~8.7GB |
| flux2-vae | `models/vae/` | ~336MB |
| ControlAltAI-Nodes (FluxResolutionNode) | `custom_nodes/` | — |

Final image: ~32GB on disk (excluding base layer).

## RunPod template

- Container image: `<registry>/klein-snofs-comfyui:<tag>`
- Container disk: 50GB+
- Volume mount: optional (`/comfyui/output` for persisting generations)
- Expose port: 8188 (ComfyUI)
