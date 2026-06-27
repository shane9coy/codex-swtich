# codex-swtich

Swap the active model and provider in OpenAI Codex desktop from the command line.

`codex-switch` quits Codex desktop, patches `~/.codex/config.toml`, and relaunches the app pointing at a different provider. Designed for round-tripping between providers (e.g. `minimax` <-> `gpt-5.5`) without manual edits.

## Install

Two scripts, two audiences.

### For AI agents and subagents

Non-interactive, idempotent, no prompts:

```sh
./install/install-agent.sh
```

What it does:
1. Copies `bin/codex-switch` to `~/.local/bin/codex-switch` with `0755` perms.
2. Warns (does not fail) if `~/.local/bin` is not on `PATH` in the current shell.
3. Runs `codex-switch status` to verify the install.

### For humans

Interactive, prompts for PATH, alias name, and API key reminders:

```sh
./install/install-human.sh
```

What it does:
1. Same copy + perms as the agent installer.
2. If `~/.local/bin` is not on `PATH`, asks before continuing and prints the fix.
3. Optionally appends a short alias (e.g. `cs`, `swap`) to `~/.zshrc` or `~/.bashrc`.
4. Prints the API key setup steps for both shell and GUI Codex desktop.
5. Runs `codex-switch status` to verify.

## Usage

```sh
codex-switch minimax      # switch to MiniMax-M3 / minimax
codex-switch gpt-5.5      # switch to gpt-5.5 / openai
codex-switch openai       # alias for gpt-5.5
codex-switch m3           # alias for minimax
codex-switch              # interactive picker
codex-switch status       # show current active model + provider + env state
```

### Overriding the model name

The switcher reads `MINIMAX_MODEL` and `GPT55_MODEL` from the environment before falling back to the canonical name. This lets you experiment with vendor-prefixed or alternative model IDs without the switcher silently clobbering them on every swap:

```sh
# Use the vendor-prefixed form (when supported by your Codex version)
export MINIMAX_MODEL=minimax/MiniMax-M3
codex-switch minimax

# Or point at a different MiniMax model
export MINIMAX_MODEL=MiniMax-M2.7
codex-switch minimax

# Same for OpenAI
export GPT55_MODEL=gpt-5.5-high
codex-switch gpt-5.5
```

With no env var set, the canonical model name is used, matching prior behavior.

## What it does (under the hood)

1. `osascript -e 'quit app "Codex"'` — sends Codex desktop a clean Apple-quit signal.
2. Waits up to 5s for Codex to exit; force-kills via `pkill` if it doesn't.
3. Patches the top-level `model` and `model_provider` lines in `~/.codex/config.toml` using Python, with word-boundary matching so `model` doesn't accidentally match `model_provider`.
4. `open -a "/Applications/Codex.app"` — relaunches the desktop app.
5. Prints the new active config so you can see what was loaded.

## API key setup (required)

`codex-switch` only swaps the model/provider. You still need the API key for your provider in scope.

For interactive shells, put it in `~/.zshenv`:

```sh
export MINIMAX_API_KEY="your-key-here"
```

For the Codex **desktop app** (GUI), the key must be in the user launchd domain so launchd-spawned apps can see it:

```sh
launchctl setenv MINIMAX_API_KEY "your-key-here"
```

GUI apps do not inherit `~/.zshenv`. This is the most common reason Codex desktop reports "not connecting to anything" after a swap. `codex-switch` calls `launchctl setenv` automatically on every swap so you do not need to do this manually.

## Recommended `~/.codex/config.toml` block for a custom provider

For a custom provider like MiniMax, the following block is the minimum needed to keep tool calling, vision, and the Responses wire path working:

```toml
model = "MiniMax-M3"
model_provider = "minimax"

[model_providers.minimax]
name = "MiniMax"
base_url = "https://api.minimax.io/v1"
env_key = "MINIMAX_API_KEY"
wire_api = "responses"             # explicit, even though it's the default
requires_openai_auth = false       # explicit, even though false is the default
http_headers = { "X-Custom-Provider" = "minimax-m3" }  # optional tag, harmless if ignored
```

Notes on each field:

- `wire_api = "responses"` — explicit so the runtime picks the OpenAI Responses wire path regardless of feature-flag state.
- `requires_openai_auth = false` — explicit so Codex never tries to use the ChatGPT session token against the MiniMax base_url.
- `http_headers` — an optional tag Codex sends with every request. Harmless if the provider ignores it. Drop the line if MiniMax support ever asks.

### Why not `model_catalog_json`?

The Codex docs mention a `model_catalog_json` config key that lets you declare capabilities (context window, tool support, vision, etc.) for non-built-in models. Without it, Codex falls back to "safe defaults" that can silently disable tool calling for unrecognized models.

**This key was added in a recent Codex version (post-0.140).** On older versions (verified on 0.137.0) it causes the entire config to fail to load. If you are on a version that supports it, the format is:

```toml
model_catalog_json = "~/.codex/model_catalog.json"
```

with a JSON sidecar at that path declaring each model's capabilities. If `codex doctor` reports `config could not be loaded` after you add this key, remove it — your Codex is too old.

## Speech-to-text is not model-dependent

If Codex desktop's voice dictation fails with "Unable to transcribe audio," the cause is **not** your provider choice. Speech-to-text is handled by OpenAI's transcription endpoint directly inside the Codex desktop app — your custom provider is not in the loop.

This is a known upstream bug tracked at:

- [openai/codex#18460](https://github.com/openai/codex/issues/18460) — Persistent "Unable to transcribe audio"
- [openai/codex#24535](https://github.com/openai/codex/issues/24535) — Voice transcription failures can discard unrecoverable audio

Workaround: use the dictation key (`^M` / `Fn Fn` on macOS) which sometimes routes around the failing path.

## Files

```
codex-swtich/
├── bin/
│   └── codex-switch          # the swap script (~260 lines)
├── install/
│   ├── install-agent.sh      # non-interactive install
│   └── install-human.sh      # interactive install
├── .gitignore
├── LICENSE
└── README.md
```

## License

MIT. Use it, fork it, ship it.
