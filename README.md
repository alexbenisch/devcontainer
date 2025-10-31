# Dotfiles Testing DevContainer

A containerized environment for testing [alexbenisch/dotfiles](https://github.com/alexbenisch/dotfiles) in a clean, reproducible setup.

## Purpose

This devcontainer allows you to:
- Test dotfiles setup process in isolation
- Validate changes before deploying to production systems
- Ensure setup script works on fresh installations
- Catch configuration errors early
- Test on multiple Linux distributions

## Quick Start

### Using VS Code

1. Install the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
2. Open this directory in VS Code
3. Click "Reopen in Container" when prompted
4. The container will build and start automatically

### Using DevPod

```bash
# Create a new workspace
devpod up .

# SSH into the container
devpod ssh dotfiles-test
```

### Using Docker CLI

```bash
# Build the container
docker build -t dotfiles-test .

# Run interactively
docker run -it --rm dotfiles-test

# Or use docker-compose
docker-compose up -d
docker-compose exec devcontainer zsh
```

## Testing Your Dotfiles

Once inside the container:

### 1. Clone Dotfiles
```bash
git clone https://github.com/alexbenisch/dotfiles.git ~/.local/share/dotfiles
cd ~/.local/share/dotfiles
```

### 2. Run Setup Script
```bash
./setup
```

The setup script will:
- Install zsh and set it as default shell
- Install Antigen plugin manager
- Install Pure prompt theme
- Install chezmoi
- Install mise and development tools
- Install tmux and tpm
- Create necessary directories

### 3. Apply Dotfiles
```bash
# Review what will change
chezmoi diff

# Apply all dotfiles
chezmoi init --source=/home/testuser/.local/share/dotfiles
chezmoi apply
```

### 4. Start Zsh
```bash
exec zsh
```

On first launch, Antigen will install all plugins automatically.

### 5. Verify Everything Works
```bash
# Check installed tools
mise list
zsh --version
tmux -V

# Check zsh plugins
antigen list

# Test aliases
ls  # should use lsd if installed
cat ~/.zshrc  # should use bat if installed

# Test completions
kubectl <TAB>  # should show completions
```

## What Gets Tested

### ✅ Core Setup
- Zsh installation and default shell configuration
- Antigen plugin manager installation
- Pure prompt theme installation
- Chezmoi installation and initialization

### ✅ Tool Installations
- mise (language version manager)
- fzf (fuzzy finder)
- bat (better cat)
- lsd (better ls)
- kubectl, flux, k9s (Kubernetes tools)
- tmux and plugin manager

### ✅ Shell Configuration
- Antigen plugins load without errors
- Completions work (kubectl, flux, mise, k3d)
- Aliases function correctly
- History with fzf integration
- Vi mode keybindings

### ✅ Directory Structure
- `~/.config` created
- `~/.zfunc` for completions
- `~/.antigen` for plugin manager
- `~/.zsh/pure` for prompt theme
- `~/.local/bin` and `~/bin` in PATH

## Troubleshooting

### Container won't build
- Check Docker is running: `docker ps`
- Check Docker permissions: `docker run hello-world`
- Try rebuilding: `docker-compose build --no-cache`

### Setup script fails
- Check internet connectivity in container
- Verify GitHub is accessible
- Check logs: `./setup 2>&1 | tee setup.log`

### Zsh errors on startup
- Missing Antigen: `ls ~/.antigen/antigen.zsh`
- Missing completions dir: `ls ~/.zfunc`
- Check error message and refer to dotfiles README.md troubleshooting

### Plugins don't load
- Check Antigen installed: `test -f ~/.antigen/antigen.zsh && echo OK`
- Manually load: `source ~/.antigen/antigen.zsh && antigen reset`
- Check network access for plugin downloads

## Development Workflow

### Testing Changes

1. **Make changes to dotfiles** on host machine
2. **Rebuild container** to test from scratch:
   ```bash
   docker-compose down
   docker-compose up --build
   ```
3. **Run setup and apply** inside container
4. **Verify** everything works
5. **Commit changes** if tests pass

### Iterative Testing

To avoid rebuilding the entire container:
```bash
# Keep container running
docker-compose up -d

# Exec into container
docker-compose exec devcontainer bash

# Make changes and test
cd ~/.local/share/dotfiles
git pull
./setup
chezmoi apply
```

## CI/CD Integration

This devcontainer can be used in CI pipelines:

```yaml
# GitHub Actions example
name: Test Dotfiles

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    container:
      image: ubuntu:latest
    steps:
      - uses: actions/checkout@v3
      - name: Run setup
        run: ./setup
      - name: Test zsh loads
        run: zsh -c "echo 'Zsh loaded successfully'"
```

## Container Specifications

- **Base Image**: Ubuntu 22.04 LTS
- **User**: testuser (non-root, sudo access)
- **Working Directory**: /home/testuser
- **Pre-installed**: git, curl, sudo, locales

See [Spec.md](./Spec.md) for detailed specifications.

## File Structure

```
devcontainer/
├── .devcontainer/
│   ├── devcontainer.json    # VS Code devcontainer config
│   └── Dockerfile           # Container definition
├── docker-compose.yml       # Docker Compose config
├── Spec.md                  # Technical specification
└── README.md               # This file
```

## Tips

- Use volume mounts to persist data between container restarts
- The container is disposable - feel free to destroy and recreate
- Test setup script changes in container before running on real systems
- Keep container image updated: `docker pull ubuntu:latest`

## Common Test Scenarios

### Fresh Install Test
```bash
# Start container
docker run -it --rm dotfiles-test

# Run complete setup
git clone https://github.com/alexbenisch/dotfiles.git ~/.local/share/dotfiles
cd ~/.local/share/dotfiles
./setup
chezmoi apply
exec zsh
```

### Update Test
```bash
# Setup once
./setup && chezmoi apply

# Make changes to dotfiles
cd ~/.local/share/dotfiles
# ... edit files ...

# Test update
chezmoi diff
chezmoi apply
```

### Selective Apply Test
```bash
# Apply only specific configs
chezmoi apply ~/.config/mise
chezmoi apply ~/.config/tmux
chezmoi apply ~/.zshrc
```

## Resources

- [Dotfiles Repository](https://github.com/alexbenisch/dotfiles)
- [Chezmoi Documentation](https://chezmoi.io)
- [Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)
- [Docker Documentation](https://docs.docker.com)

## License

MIT License - Same as the dotfiles repository.
