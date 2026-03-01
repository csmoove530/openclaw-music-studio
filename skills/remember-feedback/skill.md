---
name: remember-feedback
description: Save music preferences, creative direction, and production feedback to persistent memory. Triggers on "remember", "going forward", "I like when", "from now on", "always", "never", "for future tracks".
metadata: { "openclaw": { "emoji": "🧠", "autoTrigger": true } }
---

# Remember Feedback Skill

When team members provide feedback on music production preferences, save it to persistent memory for future sessions.

## Trigger Phrases
Activate this skill when anyone's message contains:
- "remember that..."
- "going forward..."
- "I like when..."
- "from now on..."
- "always..."
- "never..."
- "for future tracks..."
- "here's some feedback"
- "note for future"
- "my style is..."
- "we prefer..."

## Action

1. **Extract the feedback** from the message
2. **Note who said it** (for multiplayer context)
3. **Categorize it** into one of these sections:
   - `Sound Preferences` - genres, moods, vibes the team likes
   - `Production Style` - tempo, instrumentation, vocal preferences
   - `Creative Direction` - conceptual themes, aesthetic choices
   - `Things to Avoid` - sounds, genres, approaches to skip
   - `Team Member Preferences` - individual preferences (note who)

4. **Append to soul.md** using this exact command:

```bash
# First, read current content to avoid duplicates
cat /home/node/.openclaw/agents/jr-producer/agent/soul.md

# Then append the new feedback with timestamp and attribution
cat >> /home/node/.openclaw/agents/jr-producer/agent/soul.md << 'FEEDBACK'

### [CATEGORY] - Added [DATE]
- [EXTRACTED FEEDBACK] (from [USERNAME])
FEEDBACK
```

5. **Confirm to the group** what was saved

## Example

User: "Going forward, I prefer more bass-heavy tracks with minimal vocals"

Action:
```bash
cat >> /home/node/.openclaw/agents/jr-producer/agent/soul.md << 'FEEDBACK'

### Sound Preferences - Added 2026-03-01
- Prefer bass-heavy tracks with minimal vocals (from Cuy)
FEEDBACK
```

Response: "Noted! I've saved this preference: bass-heavy tracks with minimal vocals. I'll keep this in mind for future generations."

## Important Notes
- The soul.md file is at `/home/node/.openclaw/agents/jr-producer/agent/soul.md` inside the container
- Track who gave each piece of feedback for multiplayer context
- Different team members may have different preferences, save both
- Always read the file first to check for duplicate feedback
- Use clear, actionable language when saving
