# Ticket worktrees

`ticket-worktree` creates isolated Git worktrees for a Jira ticket without copying repositories or sharing a working directory between tickets.

## Layout

Canonical clones live in one place:

```text
~/codes/work/repos/
├── ritase-frontend/
└── ritase-api/
```

Each ticket receives repository worktrees beneath its ticket workspace:

```text
~/codes/work/tickets/FREIG-1184/
├── ritase-frontend/
└── ritase-api/
```

The ticket directory groups related work. Each repository can use a different branch.

## Requirements

- The canonical repository must already exist at `~/codes/work/repos/<repository>`.
- Run `sys-switch` after updating this system configuration so the `ticket-worktree` alias uses the latest script.
- The script fetches `origin`; be connected to the network before starting a new worktree.

## Basic use

Create frontend and API worktrees for a ticket:

```sh
ticket-worktree FREIG-1184
```

Create only one repository worktree:

```sh
ticket-worktree FREIG-1184 ritase-api
```

## Automatic branch selection

When a repository is supplied without `=BRANCH`, the script checks branch names in this order after fetching `origin`:

1. `feature/FREIG-1184`
2. `feat(FREIG-1184)`
3. If neither exists locally or on `origin`, create `feature/FREIG-1184` from `origin/master`.

This lets the same command work with both repository conventions:

```text
feature/FREIG-1184
feat(FREIG-1184)
```

If a matching remote branch exists, the script creates a local branch that tracks `origin/<branch>` rather than branching from `origin/master`.

## Choose a branch explicitly

Use `repository=branch` when the workspace ticket and implementation branch differ, or when you want an exact branch choice.

```sh
ticket-worktree FREIG-1184 \
  ritase-frontend='feat(FREIG-1182)' \
  ritase-api=FREIG-1183
```

In this example:

```text
~/codes/work/tickets/FREIG-1184/ritase-frontend  -> feat(FREIG-1182)
~/codes/work/tickets/FREIG-1184/ritase-api       -> FREIG-1183
```

Quote branch names containing shell-special characters such as parentheses:

```sh
ritase-frontend='feat(FREIG-1182)'
```

For an explicit branch, the script uses this order:

1. Existing local branch.
2. Existing `origin/<branch>` branch, checked out as a local tracking branch.
3. A new branch from `origin/master`.

## Safe repeat runs

It is safe to repeat the same command. If the expected destination already exists on an appropriate branch, the script reports it and leaves it unchanged:

```text
Already exists: /home/yoran/codes/work/tickets/FREIG-1184/ritase-api (FREIG-1183)
```

The script refuses to overwrite an existing unrelated path. It also refuses to check out a branch that is already in another worktree of the same repository.

## Finish and remove a ticket workspace

First ensure work is committed, pushed, or no longer needed. The short form removes all worktrees for the ticket through their canonical clones:

```sh
ticket-worktree --remove FREIG-1184
```

To remove only one repository worktree:

```sh
ticket-worktree --remove FREIG-1184 ritase-api
```

The command refuses to remove a worktree with uncommitted changes. If the worktree was removed outside Git, use `git worktree prune` as described below.

The equivalent manual commands are:

```sh
git -C ~/codes/work/repos/ritase-frontend worktree remove \
  ~/codes/work/tickets/FREIG-1184/ritase-frontend

git -C ~/codes/work/repos/ritase-api worktree remove \
  ~/codes/work/tickets/FREIG-1184/ritase-api
```

Remove the empty ticket directory afterward (the `--remove` command does this automatically when possible):

```sh
rmdir ~/codes/work/tickets/FREIG-1184
```

If a worktree directory was removed outside Git, clear stale metadata with:

```sh
git -C ~/codes/work/repos/ritase-frontend worktree prune
```
