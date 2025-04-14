#!/bin/bash

# One-line installer:
# curl -fsSL https://gist.githubusercontent.com/matthewshammond/GIST_ID/raw | bash
#
# Usage examples:
# Default (1 hour): curl -fsSL https://gist.githubusercontent.com/matthewshammond/GIST_ID/raw | bash
# 30 minutes:      curl -fsSL https://gist.githubusercontent.com/matthewshammond/GIST_ID/raw | bash -s 0.5
# 2 hours:         curl -fsSL https://gist.githubusercontent.com/matthewshammond/GIST_ID/raw | bash -s 2
# 4 hours:         curl -fsSL https://gist.githubusercontent.com/matthewshammond/GIST_ID/raw | bash -s 4
#
# The script will:
# 1. Wait for your USB drive (mounted as /Volumes/Keys)
# 2. Load your SSH key with the specified timeout
# 3. Safely eject the USB drive
# 4. The key will be automatically removed when the timeout expires

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Print functions
print_info() {
  printf "${YELLOW}ℹ️  %s${NC}\n" "$1"
}

print_success() {
  printf "${GREEN}✓ %s${NC}\n" "$1"
}

print_error() {
  printf "${RED}✗ %s${NC}\n" "$1"
  exit 1
}

# Set timeout (default to 1 hour if no argument provided)
TIMEOUT=${1:-1}
TIMEOUT_SECONDS=$((TIMEOUT * 3600))

print_info "Waiting for USB drive with SSH key..."
print_info "Please insert your USB drive now..."

# Wait for USB drive
while [ ! -d "/Volumes/Keys" ]; do
  sleep 1
done

print_success "USB drive detected!"

# Add key to ssh-agent with timeout
print_info "Adding key to ssh-agent..."
ssh-add -D # Clear any existing keys
ssh-add -t $TIMEOUT_SECONDS "/Volumes/Keys/id_ed25519"
print_success "SSH key loaded successfully"
print_info "Key will be automatically removed in $TIMEOUT hour(s)"

# Eject USB drive
print_info "Ejecting USB drive..."
diskutil eject "/Volumes/Keys"
print_success "USB drive ejected safely"
print_success "Cleanup complete"
