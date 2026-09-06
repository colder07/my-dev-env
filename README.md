# My Dev Environment

A reproducible, general-purpose development environment built on the official Dev Container ecosystem.

The goal is simple: clone this repository, reopen it in VS Code, and get the same core development workstation without polluting the host machine.

## What is included

Core runtimes and tools:

- Python 3.14
- Node.js 24
- Ruby 4.0
- Rails 8.1.3.1
- Git
- Zsh + Oh My Zsh
- Docker CLI + Buildx + Compose v2, using the host Docker daemon
- chezmoi for optional personal dotfile management

VS Code extensions:

- Vim
- Python
- Ruff
- Ruby LSP
- ESLint
- Prettier
- Docker

AWS CLI and Terraform are intentionally not installed by default. Add them as Dev Container Features in `.devcontainer/devcontainer.json` when a project needs them.

## Quick start

Requirements:

- Docker
- VS Code
- Dev Containers extension

Clone the repository:

```bash
git clone https://github.com/colder07/my-dev-env.git
cd my-dev-env
```

Open the folder in VS Code and run:

```text
Dev Containers: Reopen in Container
```

The container is rebuilt from the configuration in `.devcontainer/devcontainer.json`.

## Design

This environment follows the official Dev Container pattern of composing a small base image with reusable Features:

```text
Ubuntu / Dev Container base
        |
        +-- common-utils + Zsh
        +-- Python Feature
        +-- Node.js Feature
        +-- Ruby Feature
        +-- Docker outside-of-Docker Feature
        +-- chezmoi Feature
        |
        +-- user state in persistent $HOME volume
        +-- optional personal dotfiles from a separate Git repository
```

The Docker Feature exposes the host Docker socket rather than running a Docker daemon inside the development container.

The persisted home volume keeps developer state such as:

- shell history
- Git configuration
- CLI configuration
- package-manager caches
- VS Code Server state

Software required by the environment is installed by the image/Features or system-level setup, not by putting executables in `$HOME`.

## Personal dotfiles with chezmoi

The environment separates **development environment configuration** from **personal machine configuration**.

- `.devcontainer/devcontainer.json` defines the shared development environment.
- The persistent `$HOME` volume preserves state between container rebuilds.
- A separate chezmoi repository can define portable personal configuration such as `.zshrc`, `.gitconfig`, editor configuration, and CLI configuration.

This follows the same useful idea as a dedicated dotfiles workflow: the development environment can stay generic while personal preferences remain portable and version-controlled. chezmoi is designed to keep desired dotfile state in `~/.local/share/chezmoi` and apply it to `$HOME`; it also supports templates for machine-specific differences.

To enable your dotfiles repository, set this environment variable on the host before creating the container:

```bash
export DOTFILES_REPOSITORY=git@github.com:YOUR_USER/dotfiles.git
```

Then reopen/rebuild the container. The setup script will run:

```text
chezmoi init --apply <repository>
```

On subsequent container creations it uses:

```text
chezmoi update --apply
```

If `DOTFILES_REPOSITORY` is not set, the template still provides the default Zsh configuration and does not touch any external dotfiles repository.

For a private dotfiles repository, use an authentication method already available to Git/SSH rather than putting credentials in this repository. Do not commit secrets to the dotfiles repository; use chezmoi's supported secret-management/encryption mechanisms when sensitive configuration needs to be versioned.

A good rule is: **put portable preferences in chezmoi, ephemeral state in the persistent home volume, and project/environment requirements in `devcontainer.json`.**

## Customization

The main configuration is:

```text
.devcontainer/devcontainer.json
.devcontainer/zsh/install.sh
.vscode/settings.json
```

### Add an optional tool

For example, to add AWS CLI:

```json
"ghcr.io/devcontainers/features/aws-cli:1.1.4": {}
```

Terraform can be added in the same way:

```json
"ghcr.io/devcontainers/features/terraform:1.5.0": {}
```

Prefer official Dev Container Features and pin a version when reproducibility matters.

### Change language versions

Runtime versions are declared directly in `.devcontainer/devcontainer.json`. This keeps the environment definition visible and easy to customize.

### Customize Zsh

Without a dotfiles repository, `.devcontainer/zsh/install.sh` provides the default personal-looking Zsh setup and plugins. When `DOTFILES_REPOSITORY` is configured, the dotfiles repository owns personal shell configuration instead.

## Security model

Credentials are not copied into the image or repository.

SSH private keys should remain on the host and be exposed through SSH agent forwarding when needed. AWS credentials should likewise be supplied explicitly rather than baked into the image.

The dotfiles repository is also treated as user-controlled configuration. Only point `DOTFILES_REPOSITORY` at a repository you trust.

## Maintenance

The configuration follows the Dev Container Features and images maintained by the Dev Container ecosystem. Feature versions are explicitly pinned in `devcontainer.json`; the lockfile is intentionally regenerated by the Dev Container CLI when needed rather than committing a lockfile that no longer matches the declared Features.

This repository is a development environment template, not an application runtime image.
