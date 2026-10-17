# Git — Interview Questions

## 1. Resolving a Merge Conflict

### Question

> You're on a feature branch. A teammate committed and pushed directly to
> main/develop. When you merge, you get a merge conflict. What do you do?

### Answer

1. Bring the latest base branch into **your** branch, so conflicts are resolved there,
   not on main:
   ```bash
   git fetch origin
   git merge origin/develop    # or: git rebase origin/develop
   ```
2. Git marks each conflict in the file:
   ```text
   <<<<<<< HEAD
   your version
   =======
   their version
   >>>>>>> origin/develop
   ```
   **Understand both changes**, then keep yours, theirs, or a combination. Talk to the
   teammate if their change isn't clear. VS Code and Android Studio have a three-way
   merge view for this.
3. `git add` the resolved files, then `git commit` (or `git rebase --continue`).
4. Run `flutter analyze` and the tests. A conflict-free merge can still break the
   build. Then push and open or update the PR.

Prevention: small PRs, merge the base branch into yours often, and protect `main` so
nobody pushes to it directly.

### Mental model

A conflict means Git can't decide which change is right. You decide, by understanding
both.

### Common mistake

The candidate said "resolve them one by one in the editor", which is correct but thin.
Add: update from the base branch first, understand the other change, run the tests
after.

### Quick revision

Fetch, merge or rebase the base into your branch, resolve by understanding both sides,
add + commit, run analyze and tests, push.

## 2. Rebase

### Question

> Have you heard of `git rebase`?

### Answer

`git rebase` **replays your commits on top of another branch's latest commit**. Your
branch then looks as if it started from the current `develop`, and the history stays
**linear** (no merge commit). The interviewer's summary: it "unifies the base" of two
branches that diverged.

| Command | What it does |
|---|---|
| `git merge` | Joins histories with a **merge commit**. Doesn't rewrite anything. |
| `git rebase` | **Rewrites** your commits (new hashes) on top of the new base. Linear history. |
| `git rebase -i` | Interactive: **squash**, reorder, reword or drop commits before a PR. |
| `git revert` | Creates a new commit that **undoes** an earlier one. Safe on shared branches. |
| `git reset` | Moves the branch pointer back. Rewrites local history. |

```bash
git switch feature/cart
git fetch origin
git rebase origin/develop       # replay my commits on top of develop
# fix conflicts → git add . → git rebase --continue
git push --force-with-lease     # history changed, so a normal push is rejected
```

**Golden rule:** never rebase a branch that others work on (`main`, `develop`), because
it rewrites history they already have. Rebasing your own feature branch is fine. Use
`--force-with-lease`, not `--force`.

### Mental model

Merge says "these two histories met here". Rebase says "pretend I started from the
latest version".

### Common mistake

The candidate thought rebase means "remove the last push" or "roll back". That's
`git revert` or `git reset`. Know all three by name.

### Quick revision

Rebase replays your commits onto a new base for a linear history. `-i` to squash. Never
on shared branches. Push with `--force-with-lease`.

## 3. Urgent Production Fix While Mid-Feature (`git worktree`)

### Question

> You're on a branch with a lot of uncommitted work. There's a critical bug in
> production. What do you do? Can you have two branches open at the same time?

### Answer

Options:

- **`git stash`**: save the changes, switch branches, fix, come back, `git stash pop`.
  It works, but it's easy to lose track of stashes, and switching branches can force a
  rebuild.
- **WIP commit**: commit the work as "WIP" on your branch and amend it later.
- **`git worktree`** (the interviewer's hint): check out **another branch in a second
  folder** from the same repository. Your current folder stays exactly as it is,
  uncommitted changes included. No stash, no switching.

```bash
git worktree add ../app-hotfix production   # new folder on the production branch
cd ../app-hotfix
flutter pub get                             # each worktree has its own build files
git switch -c hotfix/payment-crash
# fix, commit, push, open PR → production
cd ../app
git worktree remove ../app-hotfix
```

After releasing the hotfix, bring it back into `develop` (merge, or `git cherry-pick`
the fix), so the bug doesn't come back in the next release.

### Mental model

Stash = put your work in a drawer. Worktree = a second desk.

### Common mistake

The candidate knew `git stash` (good) but not worktrees. Also mention merging the
hotfix back into `develop`.

### Quick revision

Stash or a WIP commit works. `git worktree add ../dir branch` opens a second folder,
so your work stays untouched. Run `pub get` there, and merge the hotfix back.
