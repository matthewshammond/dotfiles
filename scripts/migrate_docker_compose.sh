#!/bin/bash
#
# ============================================================================
# Docker Compose Migration Script
# ============================================================================
#
# DESCRIPTION:
#   This script migrates any Docker Compose application from one server to
#   another. It backs up Docker volumes, copies application files, and creates
#   a restore script on the destination server.
#
# USAGE:
#   1. Copy this script to your Docker Compose project directory:
#      cp ~/.dotfiles/scripts/migrate_docker_compose.sh /mnt/Docker/myapp/
#
#   2. Navigate to your project directory:
#      cd /mnt/Docker/myapp
#
#   3. Run the script:
#      ./migrate_docker_compose.sh [vps_alias] [vps_path]
#
#   Examples:
#      ./migrate_docker_compose.sh aeropoint ~/myapp
#      ./migrate_docker_compose.sh matthammond ~/calcom
#      ./migrate_docker_compose.sh  # Uses defaults: aeropoint and ~/$(basename $(pwd))
#
# PARAMETERS:
#   vps_alias  - SSH alias/hostname for destination server (default: aeropoint)
#   vps_path   - Destination directory on VPS (default: ~/$(basename $(pwd)))
#
# REQUIREMENTS:
#   - Source server:
#     * Docker and Docker Compose installed
#     * SSH access to destination server configured
#     * Sufficient disk space for backups
#
#   - Destination server (VPS):
#     * Docker and Docker Compose installed
#     * SSH access configured with SSH keys
#     * Sufficient disk space (at least 2x your data size)
#
# WHAT IT DOES:
#   1. Detects all Docker volumes for the current project
#   2. Backs up volumes to temporary directory
#   3. Copies application files via rsync (excludes .git, __pycache__, etc.)
#   4. Copies .env file separately
#   5. Copies volume backups to VPS
#   6. Creates restore_on_vps.sh script on destination
#
# VOLUME NAMING:
#   Docker Compose automatically prefixes volumes with the project name.
#   The project name defaults to the directory name.
#
#   Example:
#     Directory: /mnt/Docker/calcom
#     Project name: calcom
#     Volumes: calcom_postgres-data, calcom_redis-data, etc.
#
#   On VPS:
#     Directory: ~/calcom
#     Project name: calcom
#     Volumes: calcom_postgres-data, calcom_redis-data, etc.
#
# POST-MIGRATION STEPS (on VPS):
#   1. SSH to VPS: ssh <vps_alias>
#   2. Navigate to project: cd <vps_path>
#   3. Run restore script: ./restore_on_vps.sh
#   4. Verify .env file: cat .env
#   5. Start application: docker compose up -d
#   6. Check logs: docker compose logs -f
#
# TROUBLESHOOTING:
#   - If volumes aren't found: Check that Docker Compose is using default naming
#   - If rsync fails: Verify SSH access and disk space
#   - If restore fails: Check Docker is installed on VPS
#   - Volume name mismatch: Ensure directory names match expected project names
#
# NOTES:
#   - The script will prompt to stop running containers (recommended)
#   - Backups are stored in /tmp/docker_migration_YYYYMMDD_HHMMSS/
#   - You can delete backups after verifying migration
#   - The script preserves file permissions via rsync
#
# ============================================================================

set -e

# ============================================================================
# Configuration
# ============================================================================

VPS_ALIAS="${1:-aeropoint}"
VPS_PATH="${2:-~/$(basename $(pwd))}"

# Get the current directory (where script is run from)
SOURCE_DIR="$(pwd)"

# Auto-detect project name from current directory name
# Docker Compose uses directory name as project name by default
CURRENT_DIR=$(basename "$SOURCE_DIR")
PROJECT_NAME="${CURRENT_DIR}"
VOLUME_PREFIX="${PROJECT_NAME}_"

# Extract VPS project name from VPS_PATH
VPS_PROJECT_NAME=$(basename "${VPS_PATH/#~\//}")

# ============================================================================
# Display Information
# ============================================================================

echo "=========================================="
echo "Docker Compose Migration Script"
echo "=========================================="
echo "Source Directory: $SOURCE_DIR"
echo "Source Project Name: $PROJECT_NAME"
echo "Source Volume Prefix: $VOLUME_PREFIX"
echo "VPS Alias: $VPS_ALIAS"
echo "VPS Path: $VPS_PATH"
echo "VPS Project Name: $VPS_PROJECT_NAME"
echo ""

# ============================================================================
# Pre-flight Checks
# ============================================================================

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
  echo "ERROR: Docker is not running. Please start Docker and try again."
  exit 1
fi

# Check if docker-compose.yml or compose.yaml exists
if [ ! -f "docker-compose.yml" ] && [ ! -f "compose.yaml" ] && [ ! -f "docker-compose.yaml" ]; then
  echo "ERROR: No docker-compose.yml or compose.yaml found in current directory."
  echo "This script is for Docker Compose applications only."
  echo ""
  echo "Current directory: $SOURCE_DIR"
  exit 1
fi

# Check if containers are running (any containers with project name prefix)
if docker ps --format '{{.Names}}' | grep -q "^${PROJECT_NAME}_"; then
  echo "WARNING: Containers are currently running."
  echo "It's recommended to stop them before migration for data consistency."
  read -p "Stop containers now? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Stopping containers..."
    docker compose down
  fi
fi

# ============================================================================
# Backup Volumes
# ============================================================================

# Create backup directory
BACKUP_DIR="/tmp/docker_migration_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo "Backup directory: $BACKUP_DIR"
echo ""

echo "Step 1: Detecting and backing up Docker volumes..."
echo "----------------------------------------"

# Get all volumes for this project
VOLUMES=$(docker volume ls --format "{{.Name}}" | grep "^${VOLUME_PREFIX}" || true)

if [ -z "$VOLUMES" ]; then
  echo "  ⚠ No volumes found with prefix '${VOLUME_PREFIX}'"
  echo "  This might be a new deployment or volumes use different naming."
  echo "  The script will continue, but no volumes will be backed up."
  HAS_VOLUMES=false
else
  echo "Found volumes:"
  echo "$VOLUMES" | while read volume; do
    echo "  - $volume"
  done
  echo ""
  
  echo "Backing up volumes..."
  echo "$VOLUMES" | while read volume; do
    VOLUME_SHORT_NAME="${volume#${VOLUME_PREFIX}}"
    echo "Backing up volume: $volume"
    docker run --rm \
      -v "$volume":/source:ro \
      -v "$BACKUP_DIR":/backup \
      alpine tar czf "/backup/${VOLUME_SHORT_NAME}.tar.gz" -C /source .
    echo "  ✓ $volume backed up"
  done
  HAS_VOLUMES=true
fi

# ============================================================================
# Copy Application Files
# ============================================================================

echo ""
echo "Step 2: Copying application files..."
echo "----------------------------------------"
echo "This will copy the entire directory to the VPS."
echo "Excluding: .git, __pycache__, *.pyc, node_modules, volume_backups, *.log"
echo "Source directory: $SOURCE_DIR"
echo ""
echo "Note: Using sudo to ensure all files (including root-owned) are copied."

# Use sudo for rsync to copy all files including root-owned ones
# Exclude only build artifacts and temporary files, NOT data/config files
sudo rsync -av --progress \
  --exclude='.git' \
  --exclude='__pycache__' \
  --exclude='*.pyc' \
  --exclude='node_modules' \
  --exclude='volume_backups' \
  --exclude='*.log' \
  --exclude='.DS_Store' \
  --exclude='.docker' \
  "${SOURCE_DIR}/" "${VPS_ALIAS}:${VPS_PATH}/"

# ============================================================================
# Copy .env File
# ============================================================================

echo ""
echo "Step 3: Copying .env file..."
echo "----------------------------------------"
if [ -f "${SOURCE_DIR}/.env" ]; then
  echo "Copying .env file..."
  sudo rsync -av "${SOURCE_DIR}/.env" "${VPS_ALIAS}:${VPS_PATH}/.env"
  echo "  ✓ .env copied"
else
  echo "  ⚠ .env file not found in root directory."
  echo "  Checking for .env files in subdirectories..."
  # Look for .env files in common locations
  find "${SOURCE_DIR}" -name ".env" -type f ! -path "*/.git/*" ! -path "*/node_modules/*" 2>/dev/null | while read env_file; do
    REL_PATH="${env_file#${SOURCE_DIR}/}"
    echo "  Found: $REL_PATH"
    sudo rsync -av "$env_file" "${VPS_ALIAS}:${VPS_PATH}/${REL_PATH}"
  done
fi

# ============================================================================
# Copy Volume Backups
# ============================================================================

if [ "$HAS_VOLUMES" = true ]; then
  echo ""
  echo "Step 4: Copying volume backups to VPS..."
  echo "----------------------------------------"
  sudo rsync -av --progress "$BACKUP_DIR/" "${VPS_ALIAS}:${VPS_PATH}/volume_backups/"
fi

# ============================================================================
# Create Restore Script on VPS
# ============================================================================

echo ""
echo "Step 5: Creating restore script on VPS..."
echo "----------------------------------------"

cat >/tmp/restore_on_vps.sh <<'RESTORE_SCRIPT'
#!/bin/bash
#
# Docker Compose Restore Script
# Run this script on the VPS after migration
# Usage: ./restore_on_vps.sh

set -e

# Auto-detect project name from current directory name
CURRENT_DIR=$(basename "$(pwd)")
PROJECT_NAME="${CURRENT_DIR}"
VOLUME_PREFIX="${PROJECT_NAME}_"

echo "Detected project name: $PROJECT_NAME"
echo "Volume prefix: $VOLUME_PREFIX"
echo ""

echo "=========================================="
echo "Docker Compose Restore Script (VPS)"
echo "=========================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
  echo "ERROR: Docker is not installed. Please install Docker first."
  echo "Installation: curl -fsSL https://get.docker.com | sh"
  exit 1
fi

# Check if Docker Compose is available
if ! docker compose version &> /dev/null && ! command -v docker-compose &> /dev/null; then
  echo "ERROR: Docker Compose is not installed."
  exit 1
fi

# Check if volume_backups directory exists
if [ -d "./volume_backups" ]; then
  echo "Restoring Docker volumes..."
  echo "----------------------------------------"
  
  # Restore each backup file
  for backup_file in ./volume_backups/*.tar.gz; do
    if [ -f "$backup_file" ]; then
      VOLUME_SHORT_NAME=$(basename "$backup_file" .tar.gz)
      VOLUME_NAME="${VOLUME_PREFIX}${VOLUME_SHORT_NAME}"
      
      echo "Restoring volume: $VOLUME_NAME"
      # Create volume if it doesn't exist
      docker volume create "$VOLUME_NAME" 2>/dev/null || true
      
      # Restore data
      docker run --rm \
        -v "$VOLUME_NAME":/target \
        -v "$(pwd)/volume_backups":/backup:ro \
        alpine sh -c "cd /target && tar xzf /backup/${VOLUME_SHORT_NAME}.tar.gz"
      echo "  ✓ $VOLUME_SHORT_NAME restored"
    fi
  done
else
  echo "⚠ No volume_backups directory found."
  echo "  Volumes will be created on first run."
fi

# Create external networks if needed (check compose file for external networks)
if [ -f "compose.yaml" ] || [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ]; then
  echo ""
  echo "Checking for external networks..."
  EXTERNAL_NETWORKS=$(grep -E "external:\s*true" compose.yaml docker-compose.yml docker-compose.yaml 2>/dev/null | grep -A 1 "networks:" -A 10 | grep -E "^\s+[a-zA-Z]" | awk '{print $1}' | tr -d ':' || true)
  
  if [ -n "$EXTERNAL_NETWORKS" ]; then
    echo "$EXTERNAL_NETWORKS" | while read network; do
      if [ -n "$network" ]; then
        echo "Creating external network: $network"
        docker network create "$network" 2>/dev/null || echo "  Network '$network' already exists"
      fi
    done
  fi
fi

echo ""
echo "=========================================="
echo "Restore complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Verify .env file is configured correctly"
echo "2. Review docker-compose.yml/compose.yaml if needed"
echo "3. Start the application: docker compose up -d"
echo "4. Check logs: docker compose logs -f"
echo ""
RESTORE_SCRIPT

chmod +x /tmp/restore_on_vps.sh
sudo rsync -av /tmp/restore_on_vps.sh "${VPS_ALIAS}:${VPS_PATH}/restore_on_vps.sh"

# Cleanup
rm -f /tmp/restore_on_vps.sh

# ============================================================================
# Summary
# ============================================================================

echo ""
echo "=========================================="
echo "Migration Complete!"
echo "=========================================="
echo ""
echo "Files copied to: ${VPS_ALIAS}:${VPS_PATH}"
echo ""
echo "Next steps on VPS:"
echo "1. SSH to VPS: ssh ${VPS_ALIAS}"
echo "2. Navigate to: cd ${VPS_PATH}"
echo "3. Run restore script: ./restore_on_vps.sh"
echo "4. Verify .env file: cat .env"
echo "5. Start application: docker compose up -d"
echo "6. Check logs: docker compose logs -f"
echo ""
if [ "$HAS_VOLUMES" = true ]; then
  echo "Backup files are in: $BACKUP_DIR"
  echo "You can delete this after verifying the migration."
fi
echo ""
