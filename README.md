# WAI-illustrious-SDXL — RunPod Serverless worker

A ready-to-build [RunPod Serverless](https://runpod.io?ref=qpguwapm) worker for **WAI-illustrious-SDXL** by WAI0731, an anime SDXL checkpoint (Illustrious). Based on the official [`runpod/worker-comfyui`](https://github.com/runpod-workers/worker-comfyui).

Models are baked into the image, so a cold start does not re-download anything.

> 18+ model. You download it with your own Civitai account and are responsible for following the model licenses.

## What's inside

| File | Source | Size |
|---|---|---|
| `checkpoints/wai_illustrious_sdxl_v17.safetensors` | Civitai 827184 / version 2883731 (fp16 pruned) | 6.8 GB |

Just the model as its creator released it — no LoRAs, no extra nodes, no upscalers. The VAE is built into the checkpoint. The file is checked by SHA-256 at build time. SDXL runs on the ComfyUI of the base image, so nothing else is installed.

## Setup (about 10 minutes + build time)

New to this? Follow the [step-by-step setup guide](https://cobaltpear.github.io/guide.html).

1. **Make your own private copy** — click **Use this template** → **Create a new repository** → choose **Private**.
   (Your Civitai token will be in it, so it must stay private.)
2. **Add your Civitai token** — get one at civitai.com → Account settings → Security & Apps → API Keys.
   In your copy, open `Dockerfile` → ✏️ edit → replace `PASTE_YOUR_CIVITAI_TOKEN_HERE` on line 5 → Commit.
   No RunPod account yet? [Sign up here](https://runpod.io?ref=qpguwapm) — a referral link: after you first add $10, RunPod gives you a bonus credit (usually $5–10) and this repo a small credit.
3. **Create the endpoint** — see [Create the endpoint](#create-the-endpoint) below.
4. **Create an API key** — RunPod → Settings → API Keys → **Restricted**, allow only this endpoint.

## Create the endpoint

RunPod → **Serverless** → **New Endpoint** → **Deploy from a GitHub repository** → pick your copy (the first time, **Edit connection** lets RunPod see it). Then, top to bottom on the page:

| Where on the page | What to set |
|---|---|
| **Endpoint name** | anything — your copy's name is fine |
| **GPU configuration** | tick a box of 16 GB or more (more boxes = easier to get a GPU) |
| **Max workers** | `1` |
| Click **Advanced settings** to open it: | |
| → **Active workers** | `0` — nothing to pay while idle |
| → **GPU count** | `1` |
| → **Idle timeout** | `5` sec |
| → **Enable FlashBoot** | on (the switch) · **Standard** |
| → **Enable execution timeout** | on · **Execution timeout** `600` sec |
| → click **Container configuration** to open it → **Container disk** | 20 GB |

Leave everything else as it is, then **Deploy** at the bottom. The first build takes about 15 minutes. The very first request after that waits another 3–10 minutes while a worker pulls the image; later cold starts are much faster.

## Updates

Your copy only holds the token. The build steps (`build.sh`, `handler.py`) are downloaded from this repo on every build, so when something changes upstream (a model file is replaced, ComfyUI needs an update) it is fixed here — you just rebuild your endpoint.

To rebuild: commit any change to the `main` branch of your copy — RunPod builds again on every push to `main` (the endpoint's **Builds** tab shows it). Nothing to change? Edit `README.md` (✏️), add a line, **Commit changes…** → **Commit changes**.

### Model version

`main` always follows the version the model's creator currently recommends. Now: **v17.0, Civitai version 2883731**.
When it moves to a new version, the old one is kept as a tag (e.g. `v2883731`). To stay on it, replace `main` with that tag in both `ADD` lines of your `Dockerfile`.

## Use it

Any client that sends ComfyUI API-format workflows to RunPod works. `pack.json` in this repo holds the workflow and tells a client where the prompt, seed and size go (format `pack/1`, engine `comfyui`).

Raw request:

```bash
curl -X POST https://api.runpod.ai/v2/<ENDPOINT_ID>/runsync \
  -H "Authorization: Bearer <API_KEY>" -H "Content-Type: application/json" \
  -d "{\"input\": {\"workflow\": $(jq .workflow pack.json | jq '.["6"].inputs.text = "1girl, solo, reading a book in a cafe, masterpiece, best quality, amazing quality" | .["3"].inputs.seed = 1 | .["5"].inputs.width = 1024 | .["5"].inputs.height = 1344')}}"
```

The image comes back as base64 in `output.images[0].data`.

Tips: 25 steps, CFG 6, Euler a — the creator recommends 15–30 steps, CFG 5–7, Euler a and sizes above 1024×1024 (samples use 1024×1344). Start the prompt with `masterpiece, best quality, amazing quality,` and keep the negative short (`bad quality, worst quality, worst detail, sketch, censor`) — the creator warns that long quality tags and negatives make pictures blurrier. Rating tags: `general`, `sensitive`, `nsfw`, `explicit`. SDXL sizes: about 1 megapixel, multiples of 64.

### Compatible clients

- [Cobalt Pear](https://cobaltpear.github.io/) — a one-page web app: add this repo's URL, your endpoint ID and API key, then just type a prompt. Everything stays in your browser. [Try the demo](https://cobaltpear.github.io/demo/) without RunPod.

Questions or ideas: [Discussions](https://github.com/cobaltpear/cobaltpear.github.io/discussions).
