# Dotfiles Testing DevContainer Specification

## Purpose

This devcontainer is designed to test Alex's personal dotfiles in an isolated, reproducible environment. It simulates a fresh system installation to validate the setup process and ensure all configurations work correctly.

## Requirements

### Base Image
- **Image**: `ubuntu:latest` or `debian:latest`
- **Rationale**: Match common Linux environments where dotfiles will be deployed

### Pre-installed Tools
The container should have minimal base tools to simulate a fresh system:
- `git` - Required to clone dotfiles repository
- `curl` - Required for installing chezmoi and other tools
- `sudo` - Required by setup script for package installation
- `locales` - Required for locale configuration

### User Configuration
- Non-root user: `testuser`
- Home directory: `/home/testuser`
- Sudo access: Yes (passwordless for testing convenience)

## Testing Workflow

### 1. Clone Dotfiles
```bash
git clone https://github.com/alexbenisch/dotfiles.git ~/.local/share/dotfiles
```

### 2. Run Setup Script
```bash
cd ~/.local/share/dotfiles
./setup
```

### 3. Apply Dotfiles
```bash
chezmoi init --source=/home/testuser/.local/share/dotfiles
chezmoi apply
```

### 4. Test Shell Configuration
```bash
exec zsh
# Verify:
# - Antigen loads without errors
# - Pure prompt appears
# - All plugins load successfully
# - Aliases work correctly
```

### 5. Verify Installations
```bash
# Check required tools
mise --version
zsh --version
tmux -V
fzf --version

# Check mise-managed tools
mise list

# Check zsh plugins loaded
antigen list
```

## Expected Outcomes

### Successful Setup Indicators
1. ✅ Zsh set as default shell
2. ✅ Antigen installed at `~/.antigen/antigen.zsh`
3. ✅ Pure prompt theme installed at `~/.zsh/pure`
4. ✅ Chezmoi installed and configured
5. ✅ Mise installed with tools from config
6. ✅ Tmux with TPM and plugins
7. ✅ All completions directories created (`~/.zfunc`)
8. ✅ All dotfiles applied without conflicts

### Shell Launch Success
- No error messages when starting zsh
- Pure prompt displays correctly
- All antigen plugins load (git, docker, kubectl, syntax-highlighting, autosuggestions, completions, fzf)
- Command completions work (kubectl, flux, k3d, mise)

### Common Issues to Test For
1. ❌ Missing `~/.antigen/antigen.zsh` error
2. ❌ Missing `~/.zfunc` completion directory
3. ❌ Locale not configured (LANG errors)
4. ❌ Chezmoi source path mismatch
5. ❌ Mise activation not in PATH
6. ❌ Tmux plugin manager not installed

## Performance Metrics

### Setup Time
- Target: < 5 minutes for complete setup
- Includes: All downloads, installations, and configurations

### Resource Usage
- Memory: < 2GB during setup
- Disk: < 5GB after full installation

## Testing Scenarios

### Scenario 1: Fresh Install (Primary)
- Clean Ubuntu container
- No existing configurations
- Run complete setup process
- Verify all features work

### Scenario 2: Partial Setup
- Pre-install some tools (zsh, git)
- Run setup script
- Verify it detects existing tools and doesn't reinstall

### Scenario 3: Update Existing
- Run setup once
- Modify dotfiles
- Run `chezmoi apply`
- Verify updates apply correctly

### Scenario 4: Minimal Tools
- Container with only git and curl
- Run setup script
- Verify all dependencies get installed

## Validation Checklist

After running setup, validate:

- [ ] Zsh is default shell (`echo $SHELL`)
- [ ] Antigen directory exists and has plugins
- [ ] Pure prompt theme installed
- [ ] Chezmoi configured with correct source
- [ ] Mise installed and activated
- [ ] Tmux configuration applied
- [ ] All completion directories exist
- [ ] No error messages in zsh startup
- [ ] All aliases work (ls, cat, git shortcuts)
- [ ] History search with fzf works (Ctrl+R)
- [ ] Kubectl completions work (if kubectl installed)
- [ ] GPG agent configured (if gpg available)

## Automation Goals

### CI/CD Integration
- Run devcontainer tests on dotfiles repo changes
- Automated validation of setup script
- Catch breaking changes before deployment

### Test Matrix
Test on multiple base images:
- Ubuntu 22.04 LTS
- Ubuntu 24.04 LTS
- Debian 12 (Bookworm)
- Arch Linux (optional)

## Environment Variables for Testing

```bash
# Skip interactive prompts
export DOTFILES_NONINTERACTIVE=1

# Use test GitHub token if needed
export GITHUB_TOKEN=${GITHUB_TOKEN}

# Set locale for testing
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
```

## Cleanup Commands

After testing, cleanup with:
```bash
# Remove all installed tools
mise uninstall --all

# Remove dotfiles
rm -rf ~/.local/share/dotfiles
rm -rf ~/.local/share/chezmoi

# Remove configuration directories
rm -rf ~/.config/mise ~/.config/tmux ~/.config/nvim
rm -rf ~/.antigen ~/.zsh ~/.zfunc

# Remove dotfiles from home
rm -f ~/.zshrc ~/.zprofile ~/.bashrc
```

## Notes

- The devcontainer should be disposable and recreatable
- Each test run should start from a clean state
- Setup script should be idempotent (safe to run multiple times)
- Document any system-specific quirks or requirements
