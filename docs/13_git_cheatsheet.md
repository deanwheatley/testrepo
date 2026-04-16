# Git Cheat Sheet

Everyday commands you'll actuddally use.

## Setup

```bash
git config --global user.name "[name]"
git config --global user.email "[email]"
```

## Starting a Repo

```bash
git init
git clone <url>
```

## Day-to-Day

```bash
git status
git add .
git commit -m "message"
git push origin main
git pull origin main
```

## Branching

```bash
git branch                  # list branches
git branch feature-x        # create branch
git checkout feature-x      # switch branch
git checkout -b feature-y   # create + switch
git merge feature-x         # merge into current
git branch -d feature-x     # delete branch
```

## Inspecting

```bash
git log --oneline --graph
git diff
git diff --staged
git show <commit>
```

## Undoing Things

```bash
git restore <file>          # discard changes
git restore --staged <file> # unstage
git reset --soft HEAD~1     # undo last commit, keep changes
git reset --hard HEAD~1     # undo last commit, discard changes
git revert <commit>         # create inverse commit
```

## Stashing

```bash
git stash
git stash list
git stash pop
git stash drop
```

## Tags

```bash
git tag v1.0.0
git tag -a v1.0.0 -m "Release 1.0"
git push origin --tags
```

Keep it simple. Commit often. Push daily.
