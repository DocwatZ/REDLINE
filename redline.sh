#!/usr/bin/env bash
# ─── REDLINE One-Command Installer ──────────────────────────────────────────
# Usage: curl -sSL https://raw.githubusercontent.com/YOUR_ORG/REDLINE/main/redline.sh | bash
# Or: bash redline.sh
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

REPO_URL="${REDLINE_REPO_URL:-https://github.com/YOUR_ORG/REDLINE.git}"
INSTALL_DIR="${REDLINE_INSTALL_DIR:-$HOME/redline}"

echo -e "${RED}╔══════════════════════════════════════════╗${NC}"
echo -e "${RED}║          REDLINE Installer               ║${NC}"
echo -e "${RED}║   Privacy-first communication platform   ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════╝${NC}"
echo ""

# ─── Check Docker ────────────────────────────────────────────────────────────
check_docker() {
  if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed.${NC}"
    echo "Install Docker: https://docs.docker.com/get-docker/"
    exit 1
  fi

  if ! command -v docker compose &> /dev/null && ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Error: Docker Compose is not installed.${NC}"
    echo "Install Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
  fi

  echo -e "${GREEN}✓ Docker found${NC}"
}

# ─── Clone Repository ────────────────────────────────────────────────────────
clone_repo() {
  if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Directory $INSTALL_DIR already exists.${NC}"
    read -rp "Update existing installation? [y/N] " choice
    case "$choice" in
      y|Y)
        cd "$INSTALL_DIR"
        git pull --ff-only || true
        ;;
      *)
        echo "Using existing installation."
        ;;
    esac
  else
    echo "Cloning REDLINE to $INSTALL_DIR..."
    git clone "$REPO_URL" "$INSTALL_DIR"
  fi
  cd "$INSTALL_DIR"
  echo -e "${GREEN}✓ Repository ready${NC}"
}

# ─── Generate .env ───────────────────────────────────────────────────────────
generate_env() {
  if [ -f .env ]; then
    echo -e "${YELLOW}Existing .env found. Keeping current configuration.${NC}"
    return
  fi

  echo "Generating .env configuration..."
  cp .env.example .env

  # Generate secrets
  SECRET_KEY_BASE=$(openssl rand -hex 64)
  POSTGRES_PASSWORD=$(openssl rand -hex 24)
  REDIS_PASSWORD=$(openssl rand -hex 24)
  LIVEKIT_API_KEY=$(openssl rand -hex 16)
  LIVEKIT_API_SECRET=$(openssl rand -hex 24)

  # Platform-compatible sed
  sed_replace() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "$@"
    else
      sed -i "$@"
    fi
  }

  sed_replace "s|SECRET_KEY_BASE=.*|SECRET_KEY_BASE=${SECRET_KEY_BASE}|" .env
  sed_replace "s|POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=${POSTGRES_PASSWORD}|" .env
  sed_replace "s|REDIS_PASSWORD=.*|REDIS_PASSWORD=${REDIS_PASSWORD}|" .env
  sed_replace "s|REDIS_URL=.*|REDIS_URL=redis://:${REDIS_PASSWORD}@redis:6379/0|" .env
  sed_replace "s|LIVEKIT_API_KEY=.*|LIVEKIT_API_KEY=${LIVEKIT_API_KEY}|" .env
  sed_replace "s|LIVEKIT_API_SECRET=.*|LIVEKIT_API_SECRET=${LIVEKIT_API_SECRET}|" .env

  echo -e "${GREEN}✓ Environment configured with generated secrets${NC}"
}

# ─── Start Services ──────────────────────────────────────────────────────────
start_services() {
  echo ""
  echo "Starting REDLINE services..."
  echo "This may take a few minutes on first run (building containers)."
  echo ""

  if command -v docker compose &> /dev/null; then
    docker compose up -d --build
  else
    docker-compose up -d --build
  fi

  echo ""
  echo -e "${GREEN}✓ Services started${NC}"
}

# ─── Output Access URL ───────────────────────────────────────────────────────
show_info() {
  PORT=$(grep "^PORT=" .env 2>/dev/null | cut -d= -f2 || echo "3000")
  PORT="${PORT:-3000}"

  echo ""
  echo -e "${GREEN}═══════════════════════════════════════════${NC}"
  echo -e "${GREEN}  REDLINE is ready!${NC}"
  echo -e "${GREEN}═══════════════════════════════════════════${NC}"
  echo ""
  echo -e "  Access URL:  ${GREEN}http://localhost:${PORT}${NC}"
  echo -e "  Health:      http://localhost:${PORT}/health"
  echo -e "  Install dir: ${INSTALL_DIR}"
  echo ""
  echo "  Commands:"
  echo "    cd ${INSTALL_DIR}"
  echo "    docker compose logs -f        # View logs"
  echo "    docker compose down            # Stop services"
  echo "    docker compose up -d           # Start services"
  echo ""
  echo -e "${YELLOW}  ⚠ Create your first account and promote to admin:${NC}"
  echo "    docker compose exec web bundle exec rails console"
  echo "    > User.first.update(role: 'admin')"
  echo ""
}

# ─── Main ────────────────────────────────────────────────────────────────────
main() {
  check_docker
  clone_repo
  generate_env
  start_services
  show_info
}

main "$@"
