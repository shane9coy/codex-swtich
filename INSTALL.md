# INSTALL.md — Agent-friendly install instructions

These instructions are designed to be copy-pasted into an AI agent (Claude Code, Codex CLI, Hermes, Cursor, etc.) for autonomous setup. They include explicit verification steps so the agent can confirm each stage worked before moving to the next.

## One-shot prompt

Paste this into your agent:

> Install `codex-swtich` from https://github.com/shane9coy/codex-swtich on this machine. Follow the steps in `INSTALL.md` step by step. Run `./install/install-agent.sh` from the repo root. Do not prompt me. After install, run `codex-switch status` and report the output. If any step fails, stop and tell me which step and the exact error message.

## Manual step-by-step

If you're installing by hand or want to understand what the agent does:

### Step 1: Prereqs

- macOS (Apple Silicon or Intel)
- Codex Desktop installed at `/Applications/Codex.app`
- A MiniMax API key from https://platform.minimax.io/user-center/payment/token-plan (one-time purchase of the Token Plan)

Verify with:

```sh
test -d "/Applications/Codex.app" && echo "codex desktop: OK"
echo "$MINIMAX_API_KEY" | head -c 4 | grep -q "eyJ" && echo "minimax key: OK" || echo "minimax key: MISSING"
```

### Step 2: Clone + install

```sh
git clone https://github.com/shane9coy/codex-swtich.git /tmp/codex-swtich
cd /tmp/codex-swtich
./install/install-agent.sh
```

Expected output:

```
installed: /Users/<you>/.local/bin/codex-switch
ok: agent install complete
```

### Step 3: Set the API key

For the shell:

```sh
echo 'export MINIMAX_API_KEY="your-key-here"' >> ~/.zshenv
source ~/.zshenv
```

For the Codex Desktop GUI app (the script pushes this on every swap, but to bootstrap):

```sh
launchctl setenv MINIMAX_API_KEY "your-key-here"
```

### Step 4: Wire up the provider in `~/.codex/config.toml`

Add this block to your `~/.codex/config.toml`:

```toml
model = "MiniMax-M3"
model_provider = "minimax"

[model_providers.minimax]
name = "MiniMax"
base_url = "https://api.minimax.io/v1"
env_key = "MINIMAX_API_KEY"
wire_api = "responses"
requires_openai_auth = false
```

`wire_api = "responses"` and `requires_openai_auth = false` are explicit even though they're the defaults. Being explicit removes one variable when Codex's feature flags shift.

### Step 5: Switch

```sh
codex-switch minimax
```

Expected output:

```
==> Switching Codex to: MiniMax-M3 (provider: minimax)
Quitting Codex desktop...
Patched /Users/sc/.codex/config.toml
  MINIMAX_API_KEY already in launchd (length 125).
Relaunching Codex...
  Codex is running.

==> Done. Active config:
  model = "MiniMax-M3"
  model_provider = "minimax"
  service_tier = "fast"
```

### Step 6: Verify

```sh
codex-switch status
```

Expected:

```
Active Codex model:     MiniMax-M3
Active provider:        minimax
Service tier:           fast

Codex desktop:          RUNNING
MINIMAX_API_KEY (shell): set (length 125)
MINIMAX_API_KEY (GUI):   set in launchd (length 125) — Codex desktop will see this
```

Then run a live tool-call to confirm:

```sh
cd ~
codex --profile minimax exec --skip-git-repo-check 'Run `date` via the shell tool and report the output.'
```

If you see `Current local time:` followed by a date, you're done.

## What the installer does

`./install/install-agent.sh`:

1. Copies `bin/codex-switch` to `~/.local/bin/codex-switch` with `0755` perms (atomic via `install(1)`).
2. Warns (does not fail) if `~/.local/bin` is not on PATH.
3. Runs `codex-switch status` to verify the script works.

It does NOT:
- Modify `~/.zshrc`, `~/.zshenv`, `~/.bashrc`, or any shell rc file.
- Touch `~/.codex/config.toml` (you do that in step 4).
- Push API keys into launchd on its own (the script does that on every `codex-switch` invocation).
- Install Codex Desktop itself.

## Adding the OpenAI provider block

The shipped `codex-switch` only knows two profiles: `minimax` and `gpt-5.5`. To use `codex-switch gpt-5.5`, you need an OpenAI `[model_providers.openai]` block in your config. Codex ships with a built-in `openai` provider, so in most cases you don't need to add anything. If you want to use your own OpenAI API key (not ChatGPT session), add:

```toml
[model_providers.openai]
name = "OpenAI"
base_url = "https://api.openai.com/v1"
env_key = "OPENAI_API_KEY"
wire_api = "responses"
requires_openai_auth = false
```

Then set `OPENAI_API_KEY` in your shell env or launchd domain. `codex-switch` does not currently push `OPENAI_API_KEY` into launchd — only `MINIMAX_API_KEY`. Add that capability to the script if you need it (the relevant function is `push_minimax_env`).

## Troubleshooting

**`codex-switch: command not found`**

`~/.local/bin` is not on PATH. Add to `~/.zshrc`:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

Then `source ~/.zshrc`.

**`codex-switch` runs but Codex doesn't see the API key**

The launchd push happens inside the script. Run `launchctl getenv MINIMAX_API_KEY` — if it's empty, the script's launchctl step failed. Check System Settings → Privacy & Security → Full Disk Access to make sure your terminal has the permission.

**`codex doctor` reports `config could not be loaded`**

You probably have a `model_catalog_json` line in your config that this Codex version doesn't support. Remove it.

**`codex doctor` reports `npm install -g @openai/codex would update a different install`**

You have two competing Codex installs. The fix:

```sh
echo "prefix=$(npm config get prefix)" > ~/.npmrc  # if you're on nvm
# OR if you use system node:
sudo chown -R $USER /usr/local/lib/node_modules/@openai/codex
```

See `F5` notes in the conversation log for the full fix.

## Uninstall

```sh
rm ~/.local/bin/codex-switch
# Optional: remove the [model_providers.minimax] block from ~/.codex/config.toml
# Optional: unset MINIMAX_API_KEY from ~/.zshenv and launchctl
```
