# 000542-ollama.sh — Ollama local LLM runtime + model pulls
# Installs: ollama (extra repo)
# Links:    —
# Enables:  ollama.service (system service, port 11434)
# Note: Ollama runs as a system service on http://localhost:11434. Models are
#       pulled idempotently (skipped if already present in ~/.ollama). The model
#       list is sized for THIS machine: Intel Core Ultra 7 165H, 30 GB RAM, no
#       discrete GPU (Intel Meteor Lake i915, shared RAM). CPU-only inference —
#       7B/8B Q4 models (~5GB each) are the sweet spot; 27B+ would be too slow
#       for interactive use. Embedding model included for RAG/search.
#
#       pi integration: ~/.pi/agent/settings.json (in the dotfiles repo, linked
#       by the pi-agent migration 000206) sets defaultProvider="ollama" and
#       defaultModel="qwen2.5-coder:7b". The ollama.ts extension in
#       root/home/.pi/agent/extensions/ fetches http://localhost:11434/v1/models
#       at runtime and registers Ollama as an OpenAI-compatible provider, so the
#       models appear in pi once Ollama is running. enabledModels lists the
#       pulled chat models for Ctrl+P cycling.

[[ -n "${_COMMON_LOADED:-}" ]] || source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

section "ollama"

install_pacman ollama

# Ollama ships a systemd system service (ollama.service) that listens on
# 127.0.0.1:11434. Enable + start it so models can be pulled immediately.
enable_system_service "ollama.service"

# Wait briefly for the daemon to be reachable before pulling models.
info "waiting for ollama daemon..."
_ready=false
for _i in $(seq 1 15); do
  if curl -sf --max-time 2 http://localhost:11434/api/tags &>/dev/null; then
    _ready=true
    break
  fi
  sleep 1
done
if [[ "$_ready" != "true" ]]; then
  fail "ollama daemon not reachable on :11434 after 15s — skipping model pulls"
  _add_error "ollama daemon not reachable; models not pulled"
  exit 1
fi
ok "ollama daemon ready"

# ── Model list ──────────────────────────────────────────────────────────────
# Sized for 30 GB RAM, CPU-only inference (no discrete GPU). All Q4_K_M-ish
# quantizations shipped by the Ollama registry. Total disk ~22 GB.
#
#   qwen2.5:7b          ~4.7GB  general + coding
#   qwen2.5-coder:7b    ~4.7GB  dedicated coding
#   deepseek-r1:8b      ~4.9GB  reasoning / math
#   llama3.1:8b         ~4.9GB  general-purpose fallback
#   phi3:mini            ~2.2GB lightweight / fast
#   nomic-embed-text     ~274MB  embeddings for RAG / search
OLLAMA_MODELS=(
  "qwen2.5:7b"
  "qwen2.5-coder:7b"
  "deepseek-r1:8b"
  "llama3.1:8b"
  "phi3:mini"
  "nomic-embed-text"
)

# Pull each model idempotently. `ollama list` shows installed models; we check
# for the model name there before pulling to avoid re-downloading GBs.
_installed=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

for _model in "${OLLAMA_MODELS[@]}"; do
  if grep -qx "$_model" <<<"$_installed" 2>/dev/null; then
    skip "$_model (already pulled)"
  else
    info "pulling $_model..."
    if ollama pull "$_model"; then
      ok "$_model pulled"
    else
      warn "failed to pull $_model — continuing"
      _add_warning "ollama model pull failed: $_model"
    fi
  fi
done

ok "ollama + models ready (http://localhost:11434)"
