# multitimer-plasmoid

KDE Plasma plasmoid (timer widget).

## Git workflow

`main` is a protected branch on GitHub (`kido5217/multitimer-plasmoid`): changes reach it only through a pull request with one approving review. Force pushes and deletion are blocked.

The cycle for every change, in order:

1. **Branch** from an up-to-date `main`.
2. **Commit** on the branch — one logical change per branch/PR.
3. **Push** the branch: `git push -u origin <branch>`.
4. **PR**: `gh pr create`.
5. **Squash-merge**: `gh pr merge --squash`.
6. **Pull + rebase**: `git checkout main && git pull --rebase`, then delete the merged branch.
