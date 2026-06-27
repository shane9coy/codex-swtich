# codex-swtich

Swap the active model and provider in OpenAI Codex desktop from the command line.

`codex-switch` quits Codex desktop, patches `~/.codex/config.toml`, and relaunches the app pointing at a different provider. Designed for round-tripping between providers (e.g. `minimax` ↔ `gpt-5.5`) without manual edits.

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

GUI apps do not inherit `~/.zshenv`. This is the most common reason Codex desktop reports "not connecting to anything" after a swap.

## Files

```
codex-swtich/
├── bin/
│   └── codex-switch          # the swap script (250 lines)
├── install/
│   ├── install-agent.sh      # non-interactive install
│   └── install-human.sh      # interactive install
├── .gitignore
└── README.md
```

## License

MIT. Use it, fork it, ship it.