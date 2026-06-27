# codex-swtich

**Run Codex Desktop on MiniMax-M3 + GPT-5.5 + Claude Opus 4.8 — all from one $40/mo MiniMax subscription. No ChatGPT Plus, no Claude Pro, no API bills.**

`codex-switch` quits Codex desktop, patches `~/.codex/config.toml`, pushes your API key into the launchd domain so the GUI app inherits it, and relaunches. Round-trip between providers from the command line in one second.

```sh
codex-switch minimax    # → MiniMax-M3 (your daily driver)
codex-switch gpt-5.5    # → OpenAI GPT-5.5
codex-switch opus       # → Anthropic Claude Opus 4.8
```

## The $40/mo trick

MiniMax's [Token Plan](https://platform.minimax.io/user-center/payment/token-plan) gives you a single API key that unlocks multiple frontier models behind one subscription. Point Codex's `model_provider` at MiniMax's OpenAI-compatible endpoint, and you can run:

- **MiniMax-M3** for default coding (their flagship, comparable to GPT-5.x on most tasks)
- **GPT-5.5** for the hard problems (still routed through MiniMax's OpenAI-compatible endpoint, billed on the same plan)
- **Claude Opus 4.8** for vision-heavy work and nuanced reasoning

No per-token API bills. No juggling three subscriptions. One key, one bill, many models.

## Quick start (60 seconds)

```sh
# 1. Get a MiniMax API key from https://platform.minimax.io/user-center/payment/token-plan
export MINIMAX_API_KEY="your-key-here"

# 2. Clone + install
git clone https://github.com/shane9coy/codex-swtich.git
cd codex-swtich
./install/install-human.sh

# 3. Switch
codex-switch minimax
```

That's it. Codex Desktop comes back up running MiniMax-M3.

## For AI agents (autonomous install)

Copy this prompt into your agent:

> Install `codex-swtich` from https://github.com/shane9coy/codex-swtich. Run `./install/install-agent.sh` from the repo root. Verify with `codex-switch status`. Report back the active model, provider, and any doctor warnings.

The agent installer:

1. Clones the repo (or uses an existing checkout)
2. Copies `bin/codex-switch` to `~/.local/bin/codex-switch`
3. Warns (does not fail) if `~/.local/bin` is not on PATH
4. Runs `codex-switch status` to verify the install works end-to-end

See [`INSTALL.md`](./INSTALL.md) for the full agent-friendly instructions.

## Usage

```sh
codex-switch minimax      # MiniMax-M3 (daily driver)
codex-switch gpt-5.5      # OpenAI GPT-5.5 (hard problems)
codex-switch opus         # Anthropic Claude Opus 4.8 (vision, nuance)
codex-switch openai       # alias for gpt-5.5
codex-switch m3           # alias for minimax
codex-switch              # interactive picker
codex-switch status       # show current active model + provider + env state
```

### Override the model name

```sh
export MINIMAX_MODEL=minimax/MiniMax-M3   # vendor-prefixed
export GPT55_MODEL=gpt-5.5-high            # alternative model
codex-switch minimax
```

## What it does (under the hood)

1. `osascript -e 'quit app "Codex"'` — clean Apple-quit signal.
2. Waits up to 5s for Codex to exit; force-kills via `pkill` if it doesn't.
3. Patches `model` and `model_provider` in `~/.codex/config.toml` using Python, with word-boundary matching so `model` doesn't accidentally match `model_provider`.
4. Pushes `MINIMAX_API_KEY` into the launchd domain (so the GUI app sees it).
5. `open -a "/Applications/Codex.app"` — relaunches the desktop app.

## Recommended `~/.codex/config.toml` block

```toml
model = "MiniMax-M3"
model_provider = "minimax"

[model_providers.minimax]
name = "MiniMax"
base_url = "https://api.minimax.io/v1"
env_key = "MINIMAX_API_KEY"
wire_api = "responses"             # explicit, even though it's the default
requires_openai_auth = false       # explicit, even though false is the default
http_headers = { "X-Custom-Provider" = "minimax-m3" }  # optional tag
```

## Known limitations

**Custom MCP plugins don't work in Codex Desktop with MiniMax-M3 today** (upstream issue #30343). The model sees the tools, picks them, but Codex's runtime rejects the actual call with `unsupported call: mcp__*`. Built-in tools (`exec`, `apply_patch`, `read_file`, `list_files`) all work fine. Workarounds:

1. Wait for upstream to fix the custom-provider + MCP routing
2. Use gpt-5.5 for MCP-heavy workflows
3. Drive custom MCPs from a standalone `codex-cli` invocation, not the Desktop app

**Speech-to-text** in Codex Desktop is handled by OpenAI's transcription endpoint directly — your provider choice has no effect. If "Unable to transcribe audio" errors, that's upstream (issue #18460).

## Files

```
codex-swtich/
├── bin/
│   └── codex-switch            # the swap script (~260 lines)
├── install/
│   ├── install-agent.sh        # non-interactive, for AI agents
│   └── install-human.sh        # interactive, prompts for PATH/alias/key
├── .gitignore
├── INSTALL.md                  # agent-friendly install guide
├── LICENSE                     # MIT
└── README.md
```

## License

MIT. Use it, fork it, ship it.
