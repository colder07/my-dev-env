# My Dev Environment

A general-purpose development environment based on VS Code Dev Containers.

## Includes

* Python
* Node.js
* Ruby
* Java
* Go
* Rust
* C / C++
* C# / .NET
* PHP
* Git
* Docker-in-Docker
* AWS CLI
* Terraform
* Zsh + Oh My Zsh

## VS Code Extensions

* Vim
* Python
* Ruff
* Ruby LSP
* ESLint
* Prettier
* Docker

## Usage

### Requirements

* Docker
* VS Code
* Dev Containers extension

Clone the repository:

```bash
git clone https://github.com/colder07/my-dev-env.git
cd my-dev-env
```

Then open the project in VS Code and run:

```text
Dev Containers: Reopen in Container
```

VS Code will create the development container automatically.

## Customization

Main configuration files:

```text
.devcontainer/devcontainer.json
.devcontainer/zsh/install.sh
.vscode/settings.json
```

Modify these files to customize the development environment.
