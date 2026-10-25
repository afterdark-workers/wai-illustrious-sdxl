#!/bin/sh
# WAI-illustrious-SDXL — everything the worker image needs. The Dockerfile in your copy downloads this file
# from the original repo on every build, so fixes made there reach you with a rebuild.
set -eu
case "${CIVITAI_TOKEN:-}" in ""|PASTE_*) echo "ERROR: set CIVITAI_TOKEN at the top of the Dockerfile" >&2; exit 1;; esac

# file <dest> <url> <sha256>
file() {
  wget -q -O "$1" "$2"
  echo "$3  $1" | sha256sum -c - || { echo "ERROR: $1 changed upstream — wait for an update of the original repo, then rebuild" >&2; exit 1; }
}

# WAI-illustrious-SDXL v17.0 — SDXL checkpoint, fp16 pruned (Civitai model 827184 / version 2883731, 6.8GB)
file /comfyui/models/checkpoints/wai_illustrious_sdxl_v17.safetensors \
  "https://civitai.com/api/download/models/2883731?type=Model&format=SafeTensor&size=pruned&fp=fp16&token=${CIVITAI_TOKEN}" \
  f116b0c78ff441467b0cdc8f1936e1ed18ea31e9997c7b132b1b8db533f0bd04
# SDXL runs on the ComfyUI of the base image as is
