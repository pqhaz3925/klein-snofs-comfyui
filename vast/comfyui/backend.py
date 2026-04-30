"""ComfyUI backend for vast-pyworker.

Wraps ComfyUI's async HTTP API (POST /prompt → poll /history/<id> → GET /view)
into a single synchronous endpoint that returns the first generated image.
"""
import time
import uuid
import requests
from flask import abort

from backend import GenericBackend
from comfyui.metrics import Metrics

MODEL_SERVER = "127.0.0.1:8188"
POLL_INTERVAL = 0.5
MAX_POLL_SECS = 600


class Backend(GenericBackend):
    def __init__(self, container_id, control_server_url, master_token, send_data):
        metrics = Metrics(
            id=container_id,
            master_token=master_token,
            control_server_url=control_server_url,
            send_server_data=send_data,
        )
        super().__init__(master_token=master_token, metrics=metrics)
        self.model_server_addr = MODEL_SERVER

    def generate(self, model_request, metrics=True):
        if metrics:
            self.metrics.start_req(model_request)

        workflow = model_request.get("workflow") or model_request.get("prompt")
        if not workflow:
            if metrics:
                self.metrics.error_req(model_request, 400)
            return 400, b'{"error":"missing workflow"}', None

        client_id = uuid.uuid4().hex
        t1 = time.time()

        try:
            r = requests.post(
                f"http://{self.model_server_addr}/prompt",
                json={"prompt": workflow, "client_id": client_id},
                timeout=30,
            )
            if r.status_code != 200:
                code = r.status_code
                if metrics:
                    self.metrics.error_req(model_request, code)
                return code, r.content, None
            prompt_id = r.json()["prompt_id"]
        except requests.exceptions.RequestException as e:
            if metrics:
                self.metrics.error_req(model_request, 500)
            return 500, str(e).encode(), None

        deadline = t1 + MAX_POLL_SECS
        while time.time() < deadline:
            time.sleep(POLL_INTERVAL)
            try:
                h = requests.get(
                    f"http://{self.model_server_addr}/history/{prompt_id}", timeout=10
                ).json()
            except requests.exceptions.RequestException:
                continue
            if prompt_id not in h:
                continue
            outputs = h[prompt_id].get("outputs", {})
            for _, out in outputs.items():
                imgs = out.get("images") or []
                for img in imgs:
                    iv = requests.get(
                        f"http://{self.model_server_addr}/view",
                        params={
                            "filename": img["filename"],
                            "subfolder": img.get("subfolder", ""),
                            "type": img.get("type", "output"),
                        },
                        timeout=30,
                    )
                    if iv.status_code == 200:
                        t2 = time.time()
                        elapsed = t2 - t1
                        if metrics:
                            model_request["time_elapsed"] = elapsed
                            self.metrics.finish_req(model_request)
                        return 200, iv.content, elapsed
            break

        if metrics:
            self.metrics.error_req(model_request, 504)
        return 504, b'{"error":"timeout waiting for result"}', None


# ----------------------- flask handlers ------------------------

def generate_handler(backend, request):
    auth_dict, model_dict = backend.format_request(request.json)
    if auth_dict and not backend.check_signature(**auth_dict):
        abort(401)
    code, content, _ = backend.generate(model_dict)
    if code == 200:
        return content, 200, {"Content-Type": "image/png"}
    abort(code)


flask_dict = {
    "POST": {
        "generate": generate_handler,
        "prompt": generate_handler,  # alias matching ComfyUI's native path
    }
}
