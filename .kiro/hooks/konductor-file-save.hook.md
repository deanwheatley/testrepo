---
name: Konductor File Save
description: Automatically registers or updates a Konductor session when a file is saved, ensuring collision awareness for direct edits.
trigger:
  type: onFileSave
  filePattern: "**/*.{ts,tsx,js,jsx,py,java,go,rs,rb,c,cpp,h,hpp,cs,swift,kt,yaml,yml,json,md,html,css,scss,sql,sh}"
action:
  type: sendMessage
---

The user just saved a file: `{{filePath}}`

Use the Konductor MCP tools to ensure this file is tracked for collision awareness:

1. Get the git context (if not already cached):
   - userId from `git config user.name`
   - repo from `git remote get-url origin` (extract `owner/repo`)
   - branch from `git branch --show-current`

2. Call `register_session` with the userId, repo, branch, and include `{{filePath}}` in the files list. If there's an existing session for this user+repo, the Konductor will update it.

3. Check the returned `collisionState`:
   - Solo or Neighbors: No action needed.
   - Crossroads: Briefly mention others are in the same directories.
   - Collision Course: Warn the user about overlapping files and who else is working on them.
   - Merge Hell: Strongly warn about divergent changes.

Keep any notifications short and emoji-prefixed (e.g. `🟢`, `🟠`, `🔴`). If the Konductor server is unavailable, silently skip.
