# OpenClaw Music Studio

Make music with friends using AI. In Telegram.

```
You: "JR, make us a chill lo-fi beat for coding"

JR: Got it. Here's what I'm thinking:
    - Style: lo-fi hip hop, jazzy samples
    - Tempo: 85 BPM
    - Duration: 120s
    - Model: suno-v4 ($0.05)

    Ready to generate?

Friend: Add some rain sounds

JR: Updated. Lo-fi with rain ambience. Generating now...

JR: Done! Here's your track: [audio]
    Like it? I can make it longer or try a different vibe.
```

That's it. You and your friends chat with JR, an AI music producer that generates real tracks with Suno.

---

## 5-Minute Setup

### Prerequisites

- Docker installed
- Telegram account
- API keys (get these first):
  - [Anthropic API key](https://console.anthropic.com/)
  - [Telegram bot token](https://t.me/BotFather) (message @BotFather, type `/newbot`)
  - [EvoLink API key](https://evolink.ai) (for music generation)
  - [ATXP connection](https://atxp.ai) (for payments)

### Step 1: Clone and Build

```bash
git clone https://github.com/csmoove530/openclaw-music-studio.git
cd openclaw-music-studio

# Build OpenClaw (one-time)
mkdir -p ~/openclaw-sandbox && cd ~/openclaw-sandbox
git clone https://github.com/openclaw/openclaw.git
cd openclaw && docker build -t openclaw:local -f Dockerfile .
```

### Step 2: Configure

```bash
cd ~/openclaw-music-studio
./scripts/setup.sh
```

When prompted, enter:
- Your Anthropic API key
- Your Telegram bot token
- Your EvoLink API key
- Your ATXP connection string

### Step 3: Add Users

Edit `~/.openclaw-music/openclaw.json`:

```json
{
  "channels": {
    "telegram": {
      "allowFrom": ["YOUR_TELEGRAM_ID", "FRIEND_TELEGRAM_ID"],
      "groupAllowFrom": ["YOUR_TELEGRAM_ID", "FRIEND_TELEGRAM_ID"]
    }
  }
}
```

Get Telegram IDs: message [@userinfobot](https://t.me/userinfobot)

### Step 4: Start

```bash
cd ~/openclaw-sandbox/openclaw
docker compose -f docker-compose.yml -f docker-compose.hardened.yml up -d
```

### Step 5: Create Group

1. Open Telegram
2. Create a new group
3. Add your bot
4. Add your friend
5. Send: `@YourBot make a track`

---

## Music Generation

### Models

| Model | Quality | Duration | Cost | Use For |
|-------|---------|----------|------|---------|
| `suno-v4` | Good | 120s | ~$0.05 | Quick drafts, iteration |
| `suno-v4.5` | Better | 240s | ~$0.10 | Style control |
| `suno-v5` | Best | 240s | ~$0.15 | Final, polished tracks |

### Simple Mode

Just describe what you want:

```
You: Make an upbeat electronic track about summer nights
```

JR handles lyrics, arrangement, and style automatically.

### Custom Mode

Full control with lyrics and style tags:

```
You: Make this song:

[Verse]
Walking through the neon streets tonight
City lights reflecting in your eyes

[Chorus]
We're alive, we're on fire
Nothing's gonna stop us now

Style: synthwave, 80s, driving beat
Tempo: 128 BPM
Vocals: female
```

### Parameters

| Parameter | Options | Default |
|-----------|---------|---------|
| `model` | v4, v4.5, v5 | v4 |
| `duration` | 30-240s | Model decides |
| `instrumental` | true/false | false |
| `vocal_gender` | m/f | Auto |
| `style` | Any genre/mood tags | Auto |

---

## Multiplayer Features

### How It Works

```
You: I want something dark and moody

Friend: Yeah but make it danceable

JR: Combining those: dark, moody atmosphere but with
    a driving four-on-the-floor beat. Think dark
    techno meets trip-hop. Sound right?

You: Perfect

JR: Generating with suno-v4.5...
```

JR synthesizes input from everyone, asks for confirmation, then generates.

### Persistent Memory

JR remembers preferences across sessions:

```
You: Remember that we like heavy bass

JR: Noted. I'll prioritize bass-heavy production
    for future tracks.
```

**Trigger phrases:**
- "Remember that..."
- "Going forward..."
- "I prefer..."
- "We like..."
- "Always use..."
- "Never use..."

JR tracks who said what, so different collaborators can have different preferences.

---

## Commands Reference

### Docker

| Action | Command |
|--------|---------|
| Start | `docker compose -f docker-compose.yml -f docker-compose.hardened.yml up -d` |
| Stop | `docker compose down` |
| Logs | `docker compose logs -f openclaw-gateway` |
| Emergency stop | `./scripts/kill-agent.sh` |

### Telegram

| Action | Example |
|--------|---------|
| Generate track | `@JR make a chill beat` |
| Set model | `use v5 for this one` |
| Iterate | `make it faster` or `add more bass` |
| Save preference | `remember that I like 808s` |

---

## Troubleshooting

### Bot doesn't respond

```bash
# Check if running
docker compose ps

# Check logs for errors
docker compose logs -f openclaw-gateway
```

**Common fixes:**
- Verify bot token is correct in `.env`
- Confirm your Telegram ID is in `allowFrom`
- Make sure bot is added to the group

### Music generation fails

```bash
# Check EvoLink connection
docker compose logs -f | grep -i evolink
```

**Common fixes:**
- Verify `EVOLINK_API_KEY` is set
- Check ATXP account has funds
- Try a simpler prompt

### Friend can't interact

Ensure their Telegram ID is in **both** arrays:

```json
{
  "allowFrom": ["your_id", "friend_id"],
  "groupAllowFrom": ["your_id", "friend_id"]
}
```

Then restart:
```bash
docker compose down && docker compose up -d
```

### Error Messages

| Error | Cause | Fix |
|-------|-------|-----|
| `EVOLINK_API_KEY not set` | Missing env var | Add key to `.env` |
| `ATXP connection failed` | Invalid connection string | Check ATXP dashboard |
| `User not in allowlist` | Telegram ID not configured | Add to `allowFrom` |
| `Rate limit exceeded` | Too many requests | Wait 60 seconds |

---

## Security

Runs in hardened Docker with:

| Protection | Enforcement |
|------------|-------------|
| Container isolation | Kernel-enforced |
| Read-only filesystem | Immutable root |
| Telegram allowlist | Only whitelisted users |
| Loopback gateway | No external network access |
| Resource limits | CPU/memory capped |

See [Secure-OpenClaw-Research-Assistant](https://github.com/csmoove530/Secure-OpenClaw-Research-Assistant) for full security documentation.

---

## Project Structure

```
openclaw-music-studio/
├── config/
│   ├── openclaw.json       # User allowlists, gateway config
│   └── env.example         # Environment template
├── agents/jr-producer/
│   ├── IDENTITY.md         # Name, avatar, vibe
│   ├── SOUL.md             # Personality, how to operate
│   └── CLAUDE.md           # Agent instructions
├── skills/
│   ├── evolink-music/      # Suno music generation
│   └── remember-feedback/  # Persistent preferences
├── scripts/
│   ├── setup.sh            # Initial configuration
│   ├── kill-agent.sh       # Emergency stop
│   └── verify-security.sh  # Security audit
└── docker-compose.hardened.yml
```

---

## Configuration Reference

### openclaw.json

```json
{
  "agents": {
    "list": [{
      "id": "jr-producer",
      "name": "JR Music Producer",
      "agentDir": "agents/jr-producer"
    }]
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "dmPolicy": "allowlist",
      "allowFrom": ["telegram_user_id"],
      "groupPolicy": "allowlist",
      "groupAllowFrom": ["telegram_user_id"],
      "streamMode": "partial"
    }
  },
  "gateway": {
    "port": 18790,
    "mode": "local",
    "bind": "loopback"
  }
}
```

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `ANTHROPIC_API_KEY` | Yes | Claude API access |
| `TELEGRAM_BOT_TOKEN` | Yes | From @BotFather |
| `EVOLINK_API_KEY` | Yes | Music generation |
| `ATXP_CONNECTION` | Yes | Payment network |
| `OPENCLAW_GATEWAY_TOKEN` | Auto | Generated by setup |

---

## Contributing

Issues and PRs welcome at [github.com/csmoove530/openclaw-music-studio](https://github.com/csmoove530/openclaw-music-studio).

## License

MIT
