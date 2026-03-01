# OpenClaw Music Studio

Multiplayer AI music creation with JR, your collaborative music producer. Built on secure OpenClaw with EvoLink/Suno integration and ATXP payment support.

## What This Is

A Telegram-based music creation experience where you and friends can make music together with AI:

- **JR Producer** - AI music producer that generates tracks with Suno v4/v4.5/v5
- **Multiplayer Mode** - Group chat support with user allowlisting
- **ATXP Payments** - Pay for music generation through the ATXP network
- **Persistent Memory** - JR remembers your preferences across sessions

## Quick Start

### 1. Clone and Build

```bash
# Clone this repo
git clone https://github.com/csmoove530/openclaw-music-studio.git
cd openclaw-music-studio

# Clone and build OpenClaw
mkdir -p ~/openclaw-sandbox && cd ~/openclaw-sandbox
git clone https://github.com/openclaw/openclaw.git
cd openclaw && docker build -t openclaw:local -f Dockerfile .
```

### 2. Configure Environment

```bash
# Copy and edit env file
cp config/env.example ~/.openclaw-music/.env
chmod 600 ~/.openclaw-music/.env

# Edit with your values:
# - ANTHROPIC_API_KEY
# - TELEGRAM_BOT_TOKEN (from @BotFather)
# - EVOLINK_API_KEY (from evolink.ai)
# - ATXP_CONNECTION (your ATXP connection string)
```

### 3. Add Your Friend's Telegram ID

Edit `config/openclaw.json` and add your friend's user ID:

```json
"channels": {
  "telegram": {
    "allowFrom": [
      "455323659",
      "YOUR_FRIENDS_USER_ID"
    ],
    "groupAllowFrom": [
      "455323659",
      "YOUR_FRIENDS_USER_ID"
    ]
  }
}
```

**How to get a Telegram user ID:**
- Have them message [@userinfobot](https://t.me/userinfobot)
- Or forward any of their messages to @userinfobot

### 4. Run Setup

```bash
./scripts/setup.sh
```

### 5. Start JR

```bash
cd ~/openclaw-sandbox/openclaw
docker compose -f docker-compose.yml -f docker-compose.hardened.yml up -d
```

### 6. Create a Group Chat

1. Create a Telegram group
2. Add your bot (@YourBotName)
3. Add your friend
4. Start making music together

## How It Works

### Music Generation

JR uses EvoLink to access Suno's music generation models:

| Model | Quality | Max Duration | Best For |
|-------|---------|--------------|----------|
| suno-v4 | Good | 120s | Quick drafts |
| suno-v4.5 | Better | 240s | Style control |
| suno-v5 | Best | 240s | Final tracks |

### Generation Modes

**Simple Mode:** Describe what you want
```
"Make an upbeat electronic track about summer nights"
```

**Custom Mode:** Full control
```
Write lyrics with [Verse], [Chorus], [Bridge] tags
Specify style, tempo, vocal gender
```

### ATXP Payments

Music generation costs money via ATXP. JR will:
1. Confirm with the group before generating
2. Pay using your ATXP account
3. Share results with everyone

### Multiplayer Flow

1. Someone suggests an idea
2. Group discusses direction
3. JR synthesizes input into generation parameters
4. Confirm cost and generate
5. Listen together, iterate

## Skills

| Skill | Purpose |
|-------|---------|
| **evolink-music** | AI music generation with Suno |
| **remember-feedback** | Save preferences across sessions |

### Teaching JR Your Preferences

Use trigger phrases:
- "Remember that we like heavy bass"
- "Going forward, use v5 for final tracks"
- "I prefer instrumental over vocals"

JR tracks who said what for multiplayer context.

## Security

This runs on secure OpenClaw with:

| Protection | What It Does |
|------------|--------------|
| Container isolation | HARD boundary |
| Telegram allowlist | Only whitelisted users |
| Loopback gateway | No external access |
| Workspace isolation | Agent stays in sandbox |

See the [parent repo](https://github.com/csmoove530/Secure-OpenClaw-Research-Assistant) for full security docs.

## File Structure

```
openclaw-music-studio/
├── config/
│   ├── openclaw.json      # Main config with user allowlists
│   ├── env.example        # Secrets template
│   └── seccomp-profile.json
├── agents/
│   └── jr-producer/
│       ├── IDENTITY.md    # JR's identity
│       ├── SOUL.md        # Core personality
│       └── CLAUDE.md      # Agent instructions
├── skills/
│   ├── evolink-music/     # Music generation
│   │   └── skill.md
│   └── remember-feedback/ # Persistent memory
│       └── skill.md
├── scripts/
│   ├── setup.sh
│   ├── kill-agent.sh
│   └── verify-security.sh
├── docker-compose.hardened.yml
└── README.md
```

## Troubleshooting

### Bot doesn't respond in group

1. Check both users are in `groupAllowFrom`
2. Make sure the bot is added to the group
3. Try mentioning the bot: `@YourBot make a track`

### Music generation fails

1. Check `EVOLINK_API_KEY` is set
2. Verify ATXP connection has funds
3. Check logs: `docker compose logs -f`

### Friend can't see bot responses

Ensure their user ID is in both:
- `allowFrom` (for DMs)
- `groupAllowFrom` (for group chats)

## Common Commands

```bash
# Start JR
docker compose -f docker-compose.yml -f docker-compose.hardened.yml up -d

# View logs
docker compose logs -f openclaw-gateway

# Stop JR
docker compose down

# Emergency kill
./scripts/kill-agent.sh
```

## License

MIT
