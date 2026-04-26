# klein-snofs-comfyui

RunPod ComfyUI worker image for FLUX.2 Klein 9B with snofs v13 LoRA / base.

## Build

Built on netcup (where the `dl.pqhaz.cc` mirror lives — downloads are loopback,
~5 min total). GH Actions runners don't have enough disk for the ~30GB image.

```bash
ssh netcup
git clone https://github.com/pqhaz3925/klein-snofs-comfyui /tmp/build
cd /tmp/build
docker build -t ghcr.io/pqhaz3925/klein-snofs-comfyui:latest .
echo "$GHCR_PAT" | docker login ghcr.io -u pqhaz3925 --password-stdin
docker push ghcr.io/pqhaz3925/klein-snofs-comfyui:latest
```

## Contents

| asset | path inside image | size |
|---|---|---|
| snofsSexNudesAndOtherFunStuff_v13Base | `models/diffusion_models/` | ~17GB |
| kleinSnofsV13 (LoRA) | `models/loras/` | ~1GB |
| qwen_3_8b_fp8mixed (text encoder) | `models/text_encoders/` | ~8.7GB |
| flux2-vae | `models/vae/` | ~336MB |
| ControlAltAI-Nodes (FluxResolutionNode) | `custom_nodes/` | — |

Final image: ~30GB. Cold start on RunPod serverless = image pull only
(no model downloads), so latency is bounded by network.

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
