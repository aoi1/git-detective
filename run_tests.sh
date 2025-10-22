#!/usr/bin/env bash
set -euo pipefail

PY_VER="3.12"

# --- 1) uv インストール確認 ---
if ! command -v uv >/dev/null 2>&1; then
  echo "[hint] uv not found. Installing..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi
# Windows Git Bash 対応：インストール直後に PATH を反映
if [ -f "$HOME/.local/bin/env" ]; then
  # shellcheck disable=SC1091
  source "$HOME/.local/bin/env"
fi

# --- 2) Python を確保 ---
echo "[info] Ensuring Python ${PY_VER}..."
uv python install "${PY_VER}"

# --- 3) 毎回クリーンな venv を作成 ---
echo "[info] Creating fresh .venv ..."
uv venv .venv --python "${PY_VER}" --clear

# --- 4) venv をアクティベート ---
if [ -f ".venv/Scripts/activate" ]; then
  # Windows Git Bash
  # shellcheck disable=SC1091
  source .venv/Scripts/activate
else
  # macOS / Ubuntu
  # shellcheck disable=SC1091
  source .venv/bin/activate
fi

# --- 5) 依存インストール ---
if [ -f requirements.txt ]; then
  echo "[info] Installing deps from requirements.txt..."
  uv pip install -r requirements.txt
else
  echo "[info] Installing pytest..."
  uv pip install pytest
fi

# --- 6) テスト実行 ---
echo "[info] Running pytest..."
PYTHONPATH=. uv run pytest -q
