#!/bin/bash

# Automated test script for dotfiles setup
# Run this inside the devcontainer to validate the complete setup

set -euo pipefail

echo "=========================================="
echo "  Dotfiles Setup Test Script"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

test_passed=0
test_failed=0

# Function to check if command exists
check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $1 is installed"
        ((test_passed++))
        return 0
    else
        echo -e "${RED}✗${NC} $1 is NOT installed"
        ((test_failed++))
        return 1
    fi
}

# Function to check if file/directory exists
check_path() {
    if [ -e "$1" ]; then
        echo -e "${GREEN}✓${NC} $1 exists"
        ((test_passed++))
        return 0
    else
        echo -e "${RED}✗${NC} $1 does NOT exist"
        ((test_failed++))
        return 1
    fi
}

echo "Step 1: Cloning dotfiles..."
if [ ! -d ~/.local/share/dotfiles ]; then
    git clone https://github.com/alexbenisch/dotfiles.git ~/.local/share/dotfiles
    echo -e "${GREEN}✓${NC} Dotfiles cloned"
else
    echo -e "${YELLOW}⚠${NC} Dotfiles already exist, skipping clone"
fi
echo ""

echo "Step 2: Running setup script..."
cd ~/.local/share/dotfiles
./setup
echo ""

echo "Step 3: Applying dotfiles with chezmoi..."
chezmoi init --source=/home/testuser/.local/share/dotfiles
chezmoi apply
echo ""

echo "=========================================="
echo "  Running Validation Tests"
echo "=========================================="
echo ""

echo "Testing required commands..."
check_command "git"
check_command "curl"
check_command "zsh"
check_command "chezmoi"
check_command "mise"
echo ""

echo "Testing optional tools..."
check_command "fzf" || true
check_command "bat" || true
check_command "lsd" || true
check_command "tmux" || true
echo ""

echo "Testing directory structure..."
check_path "$HOME/.antigen/antigen.zsh"
check_path "$HOME/.zsh/pure"
check_path "$HOME/.zfunc"
check_path "$HOME/.config"
check_path "$HOME/.local/bin"
check_path "$HOME/bin"
echo ""

echo "Testing dotfiles applied..."
check_path "$HOME/.zshrc"
check_path "$HOME/.zprofile"
check_path "$HOME/.bashrc"
echo ""

echo "Testing zsh configuration..."
if zsh -c "source ~/.zshrc && echo 'Zsh loaded successfully'" >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Zsh configuration loads without errors"
    ((test_passed++))
else
    echo -e "${RED}✗${NC} Zsh configuration has errors"
    ((test_failed++))
fi
echo ""

echo "=========================================="
echo "  Test Results"
echo "=========================================="
echo -e "Passed: ${GREEN}${test_passed}${NC}"
echo -e "Failed: ${RED}${test_failed}${NC}"
echo ""

if [ $test_failed -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo ""
    echo "You can now run: exec zsh"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
