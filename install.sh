#!/bin/bash

# Quantum Randomness Skill - Installer
# Installs the quantum-randomness skill for Claude Code / Codex

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/skill"
SKILLS_DIR="$HOME/.claude/skills"
SKILL_PATH="$SKILLS_DIR/quantum-randomness"

print_banner() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                                                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${WHITE}⚛  QUANTUM RANDOMNESS SKILL${NC}                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${MAGENTA}Physics-certified randomness for Solana${NC}                  ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${GREEN}Trust the laws of physics, not the oracle operator.${NC}      ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                              ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Parse args
SKIP_CONFIRM=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes) SKIP_CONFIRM=true; shift ;;
        -h|--help)
            echo "Usage: ./install.sh [-y]"
            echo "Installs quantum-randomness skill to ~/.claude/skills/"
            exit 0 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

print_banner

echo -e "${WHITE}This will install:${NC}"
echo -e "  ${BLUE}•${NC} quantum-randomness skill → ${CYAN}$SKILL_PATH${NC}"
echo ""

if [ "$SKIP_CONFIRM" = false ]; then
    read -p "Proceed? [Y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo -e "${YELLOW}Cancelled${NC}"
        exit 0
    fi
fi

# Install
mkdir -p "$SKILLS_DIR"

if [ -d "$SKILL_PATH" ]; then
    echo -e "${YELLOW}→ Removing existing installation${NC}"
    rm -rf "$SKILL_PATH"
fi

cp -r "$SOURCE_DIR" "$SKILL_PATH"
echo -e "${GREEN}✓ Installed to $SKILL_PATH${NC}"

# Done
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Installation Complete!                                      ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Try asking Claude:${NC}"
echo -e "  ${BLUE}•${NC} \"Set up a quantum randomness oracle for my Solana program\""
echo -e "  ${BLUE}•${NC} \"Replace my ZK trusted setup with quantum randomness\""
echo -e "  ${BLUE}•${NC} \"Compare Switchboard VRF vs quantum source for my DAO vote\""
echo -e "  ${BLUE}•${NC} \"Generate certified nullifiers for my privacy protocol\""
echo ""
