# Konductor Collision Awareness

This rule is always active. The agent handles all Konductor interactions automatically. The user never needs to call Konductor tools directly.

## Identity

Determine the user identity and repository context automatically:
- `userId`: Run `git config user.name` to get the username
- `repo`: Run `git remote get-url origin` and extract the `owner/repo` portion (strip any `.git` suffix and hosting prefix)
- `branch`: Run `git branch --show-current`

Cache these values for the duration of the session. Do not ask the user for them.

## Automatic Registration

Whenever you are about to create or modify files as part of a task:

1. Silently call `register_session` with the userId, repo, branch, and the full list of files you plan to touch.
2. Print a short one-line confirmation to the user: `🟢 Konductor: Registered session on <repo>#<branch> (<N> files)`
3. Store the returned `sessionId` so you can deregister later.

Do not ask the user for permission to register. Just do it.

## Automatic Collision Check

After registering (or re-registering), check the returned `collisionState` and notify the user based on severity:

- **Solo**: No notification needed beyond the registration confirmation.
- **Neighbors**: `🟢 Konductor: Others are active in this repo but working on different files. Proceeding.`
- **Crossroads**: `🟡 Konductor: Heads up — others are working in the same directories. Proceeding with caution.`
- **Collision Course**: `🟠 Konductor: Warning — <overlapping users> are modifying the same files: <shared files>. Proceed?` — Wait for the user to confirm before making changes.
- **Merge Hell**: `🔴 Konductor: Critical overlap — <overlapping users> have divergent changes on <shared files> across branches <branches>. Strongly recommend coordinating before continuing.` — Wait for the user to confirm.

Only pause and ask for confirmation at Collision Course or Merge Hell. All other states proceed automatically.

## Automatic Session Updates

If the set of files you are modifying changes during a task (you start editing files not in the original list), silently call `register_session` again with the updated file list. Print: `🔄 Konductor: Updated session — now tracking <N> files`

Re-check the collision state and notify as above.

## Automatic Deregistration

When a task is fully complete and you are done modifying files, silently call `deregister_session` with the stored sessionId. Print: `✅ Konductor: Session closed.`

If the user ends the conversation or moves on without completing the task, still deregister.

## Rules

- Never ask the user to call Konductor tools themselves.
- Never skip registration because it seems unnecessary — always register when modifying files.
- Keep Konductor notifications short and emoji-prefixed so they are easy to scan.
- If Konductor tools are unavailable (server down, not configured), silently skip and do not block the user's work.
