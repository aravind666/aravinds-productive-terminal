# Contributing to aravinds-productive-terminal

Thanks for your interest in contributing! This guide covers how to propose changes, test them, and how releases work.

## Getting Started

1. Fork the repository and clone your fork.
2. Create a feature branch off `main`:
   ```bash
   git checkout -b feat/my-change
   ```
3. Make your changes to `install.sh`, `zshrc_template`, `starship.toml`, or the packaging files (`nfpm.yaml`, `scripts/postinstall.sh`).

## Testing Your Changes

Since this project configures a live shell environment, test locally before opening a PR:

```bash
# Run the installer directly
bash install.sh

# Check shell script syntax
bash -n install.sh
bash -n scripts/postinstall.sh
```

If you have [ShellCheck](https://www.shellcheck.net/) installed, please run it against modified scripts:
```bash
shellcheck install.sh scripts/postinstall.sh
```

### Testing package builds

If you change `nfpm.yaml` or `scripts/postinstall.sh`, verify both package formats still build with [nfpm](https://nfpm.goreleaser.com/):

```bash
mkdir -p dist
VERSION=0.0.0-test nfpm pkg --config nfpm.yaml --packager deb --target dist/
VERSION=0.0.0-test nfpm pkg --config nfpm.yaml --packager rpm --target dist/
```

## Commit Message Format (Required)

This repository uses [release-please](https://github.com/googleapis/release-please), which automates versioning and changelog generation based on **[Conventional Commits](https://www.conventionalcommits.org/)**. All commits on `main` (including squashed PRs) **must** follow this format:

```
<type>(<optional scope>): <short description>

<optional body>

<optional footer(s)>
```

Common types:

| Type       | Purpose                                              | Version bump |
|------------|-------------------------------------------------------|--------------|
| `feat`     | A new feature                                          | minor        |
| `fix`      | A bug fix                                               | patch        |
| `docs`     | Documentation only changes                              | none         |
| `chore`    | Tooling, CI, or maintenance changes                     | none         |
| `refactor` | Code change that neither fixes a bug nor adds a feature | none         |
| `test`     | Adding or correcting tests                              | none         |

Add `!` after the type (e.g. `feat!:`) or a `BREAKING CHANGE:` footer to trigger a major version bump.

Examples:
```
feat: add ripgrep to the modern CLI tool suite
fix(install): correct asdf plugin detection on Oracle Linux
docs: clarify apt/dnf installation steps in README
```

## Pull Request Process

1. Ensure your commits follow the Conventional Commits format above — release-please parses PR titles/commits to generate the changelog.
2. Open a PR against `main` describing the change and testing performed.
3. A maintainer will review and merge. Once merged, release-please automatically opens (or updates) a release PR; merging *that* PR cuts a new GitHub Release and, via CI, publishes updated `.deb`/`.rpm` packages.

## Code Style

* Keep `install.sh` POSIX-friendly bash with `set -euo pipefail`, idempotent checks (`if [ ! -d ... ]`) before installing tools.
* Keep configuration (`zshrc_template`, `starship.toml`) commented where non-obvious.
* Avoid adding new hard dependencies unless necessary; prefer tools with static binary releases.
