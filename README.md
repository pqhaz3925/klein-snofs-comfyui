# klein-snofs-comfyui

RunPod ComfyUI worker image for FLUX.2 Klein 9B with snofs v13 LoRA / base.

## Build

```bash
docker build -t klein-snofs-comfyui .
```

## Contents

| asset | downloaded at runtime to | size | overridable env |
|---|---|---|---|
| snofsSexNudesAndOtherFunStuff_v13Base | `models/diffusion_models/` | ~17GB | `DIFFUSION_URL` |
| kleinSnofsV13 (LoRA) | `models/loras/` | ~1GB | `LORA_URL` |
| qwen_3_8b_fp8mixed (text encoder) | `models/text_encoders/` | ~8.7GB | `TEXT_ENCODER_URL` |
| flux2-vae | `models/vae/` | ~336MB | `VAE_URL` |
| ControlAltAI-Nodes (FluxResolutionNode) | `custom_nodes/` (baked in) | — | — |

Image itself is ~3GB (base + custom nodes). Models stream on container start
via `setup-models.sh`. If `/comfyui/models` is on a persistent volume, the
download happens once.

## CI / image hosting

GitHub Actions builds on every push to `main` and pushes to GHCR (private):

```
ghcr.io/pqhaz3925/klein-snofs-comfyui:latest
ghcr.io/pqhaz3925/klein-snofs-comfyui:<sha>
```

`ubuntu-latest` only has ~14GB free, so the workflow uses
`jlumbroso/free-disk-space` to reclaim ~30GB by removing unused pre-installed
SDKs (Android, .NET, Haskell, etc).

## RunPod template

- Container image: `ghcr.io/pqhaz3925/klein-snofs-comfyui:latest`
- Container disk: 50GB+
- Volume mount: optional (`/comfyui/output` for persisting generations)
- Expose port: 8188 (ComfyUI)

Since the package is private, add registry credentials in the template:

- Registry: `ghcr.io`
- Username: `pqhaz3925`
- Password: GitHub PAT with `read:packages` scope
  (create at https://github.com/settings/tokens)
