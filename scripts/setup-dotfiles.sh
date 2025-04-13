#!/bin/zsh

# Check if we're using the private URL
if [[ "$(git config --get remote.origin.url)" == *"git@github.com"* ]]; then
    echo "Private URL detected, initializing private repository..."
    
    # Initialize the private repository in the current directory
    git submodule init
    git submodule update
    
    echo "Private files initialized successfully!"
else
    echo "Public URL detected, skipping private repository initialization."
fi

# Run stow to create symlinks
echo "Creating symlinks with stow..."
stow . 