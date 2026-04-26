[![Runpod](https://api.runpod.io/badge/pqhaz3925/klein-snofs-comfyui)](https://console.runpod.io/hub/pqhaz3925/klein-snofs-comfyui)

# klein-snofs-comfyui

RunPod Serverless ComfyUI worker for **FLUX.2 Klein 9B**.

Models, LoRA, text encoder, VAE and ControlAltAI nodes baked in.
Base image: `runpod/worker-comfyui:5.8.5-base` — handler ships with it.

## Usage

POST to `https://api.runpod.ai/v2/<ENDPOINT_ID>/run`:

```json
{
  "input": {
    "workflow": { ... },
    "images": []
  }
}
```

See `workflow.json` for the reference workflow.
