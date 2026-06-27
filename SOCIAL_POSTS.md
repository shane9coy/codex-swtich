POST 1 — X / Twitter (under 280 chars, single post)

I run Codex Desktop on MiniMax-M3, GPT-5.5, and Claude Opus 4.8 — all from one $40/mo MiniMax subscription.

One API key. One bill. Switch models from the terminal:

$ codex-switch minimax
$ codex-switch gpt-5.5

Open source: github.com/shane9coy/codex-swtich


POST 2 — X / Twitter (threaded, 4 posts)

1/ I was paying $200/mo for Claude Pro + $20/mo for ChatGPT Plus just to use Codex Desktop with frontier models.

Then I found MiniMax's $40/mo Token Plan. One API key unlocks MiniMax-M3, GPT-5.5, AND Claude Opus 4.8 behind one OpenAI-compatible endpoint.

2/ I wrote `codex-switch` — a 260-line bash script that swaps Codex Desktop's active model in 1 second. It patches config.toml, pushes the API key into launchd so the GUI sees it, and relaunches.

No more juggling subscriptions. No per-token API bills.

3/ The setup is 6 commands:
  - export MINIMAX_API_KEY="..."
  - git clone github.com/shane9coy/codex-swtich
  - ./install/install-human.sh
  - add 6 lines to ~/.codex/config.toml
  - codex-switch minimax
  - done

4/ Works for AI agents too — there's an autonomous installer at ./install/install-agent.sh. Paste the repo URL into your agent and it sets itself up.

github.com/shane9coy/codex-swtich


POST 3 — LinkedIn (longer form, professional)

I built a tool to run OpenAI's Codex Desktop on MiniMax's $40/mo subscription — unlocking MiniMax-M3, GPT-5.5, and Claude Opus 4.8 behind one API key.

The problem: Codex Desktop only ships with built-in support for OpenAI models. To use it with any other model, you have to:
1. Quit Codex Desktop
2. Manually edit `~/.codex/config.toml`
3. Hope your custom provider doesn't break
4. Relaunch Codex Desktop

Every. Single. Time.

The fix: `codex-switch` — a 260-line bash script that does all of the above in one command, and pushes your API key into the macOS launchd domain so the GUI app inherits it without needing it in your shell env.

The result: I now run Codex Desktop on three frontier models (MiniMax-M3 for daily work, GPT-5.5 for hard problems, Claude Opus 4.8 for vision/nuance) — all from one $40/mo subscription. No ChatGPT Plus. No Claude Pro. No API bills.

The repo: github.com/shane9coy/codex-swtich

It includes:
- The swap script
- An autonomous installer for AI agents (paste the URL, agent sets itself up)
- An interactive installer for humans
- A README that documents the known limitations (MCP plugins don't work with custom providers yet — upstream issue #30343)
- MIT license — fork it, ship it, use it

If you're paying for multiple AI coding subscriptions and want to consolidate, this is worth a look.


POST 4 — Threads (casual, Instagram-adjacent)

the AI coding subscription stack is broken

$20/mo ChatGPT Plus
$200/mo Claude Pro
$50-200/mo in API bills

all to run different frontier models in Codex Desktop

I just consolidated all of it into one $40/mo MiniMax subscription

one API key → MiniMax-M3 + GPT-5.5 + Opus 4.8 → Codex Desktop

wrote a 260-line bash script to swap between them

github.com/shane9coy/codex-swtich

MIT license, autonomous installer for agents included


POST 5 — Hacker News (show HN style, technical)

Title: Show HN: Run Codex Desktop on MiniMax's $40/mo subscription (MiniMax-M3 + GPT-5.5 + Opus 4.8)

Hi HN,

I built codex-switch — a 260-line bash script that swaps the active model/provider in OpenAI's Codex Desktop from the command line.

Background: Codex Desktop ships with built-in support for OpenAI models. To use it with any other model, you have to quit Codex, edit `~/.codex/config.toml`, and relaunch. Every single time you want to swap.

What codex-switch does:
1. `osascript -e 'quit app "Codex"'` (clean Apple quit)
2. Patches the `model` and `model_provider` keys in config.toml using Python (with word-boundary regex so `model` doesn't match `model_provider`)
3. Pushes the API key into the launchd domain via `launchctl setenv` (so the GUI app inherits it)
4. `open -a "/Applications/Codex.app"` to relaunch

The MiniMax angle: MiniMax's $40/mo Token Plan gives you a single API key that unlocks multiple frontier models behind one OpenAI-compatible endpoint. So `model_provider = "minimax"` + `base_url = "https://api.minimax.io/v1"` lets Codex route to MiniMax-M3, GPT-5.5, or Claude Opus 4.8 depending on what `model = "..."` you set.

Includes:
- The swap script
- Two installers: `install-agent.sh` (no prompts, for AI agents) and `install-human.sh` (interactive, for humans)
- INSTALL.md with explicit verification steps so an agent can confirm each stage worked
- MIT license

Known limitations (documented in README):
- Custom MCP plugins don't work in Codex Desktop with MiniMax-M3 today (upstream issue #30343)
- Speech-to-text is handled by OpenAI's endpoint directly, not your provider — so STT bugs are upstream

Repo: github.com/shane9coy/codex-swtich

Happy to answer questions or take PRs for the MiniMax-routed GPT-5.5 / Opus 4.8 profiles (currently `codex-switch` only knows two profiles: `minimax` and `gpt-5.5`).
