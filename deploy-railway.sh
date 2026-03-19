#!/bin/bash

# CyborX Railway Deployment Script
# Run this to prepare your project for Railway deployment

set -e

echo "🚂 CyborX Railway Deployment Prep"
echo "=================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "app.php" ]; then
    echo -e "${RED}Error: Please run this script from the CyborX root directory${NC}"
    exit 1
fi

# 1. Check PHP version
echo -e "${YELLOW}Checking PHP version...${NC}"
php_version=$(php -v | head -n 1 | cut -d " " -f 2 | cut -d "." -f 1,2)
if (( $(echo "$php_version >= 8.1" | bc -l) )); then
    echo -e "${GREEN}✓ PHP version: $php_version${NC}"
else
    echo -e "${RED}✗ PHP 8.1+ required. Current: $php_version${NC}"
    exit 1
fi

# 2. Check for required PHP extensions
echo -e "${YELLOW}Checking PHP extensions...${NC}"
required_extensions=("pdo_mysql" "mbstring" "curl" "json" "zip")
for ext in "${required_extensions[@]}"; do
    if php -m | grep -qi "$ext"; then
        echo -e "${GREEN}✓ $ext${NC}"
    else
        echo -e "${RED}✗ $ext is missing${NC}"
        echo "  Install: sudo apt-get install php-$ext"
    fi
done

# 3. Check if .env exists
echo -e "${YELLOW}Checking .env configuration...${NC}"
if [ -f ".env" ]; then
    echo -e "${GREEN}✓ .env file exists${NC}"
    
    # Check for required variables
    required_vars=("TELEGRAM_BOT_TOKEN" "TELEGRAM_BOT_USERNAME" "TELEGRAM_ANNOUNCE_CHAT_ID")
    for var in "${required_vars[@]}"; do
        if grep -q "^$var=" .env; then
            echo -e "${GREEN}✓ $var is set${NC}"
        else
            echo -e "${YELLOW}⚠ $var is not set in .env${NC}"
        fi
    done
else
    echo -e "${YELLOW}⚠ .env file not found. Copying from .env.example...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✓ Created .env from .env.example${NC}"
    echo -e "${YELLOW}  Please edit .env and fill in your configuration${NC}"
fi

# 4. Check if composer.json exists
echo -e "${YELLOW}Checking Composer configuration...${NC}"
if [ -f "composer.json" ]; then
    echo -e "${GREEN}✓ composer.json exists${NC}"
else
    echo -e "${RED}✗ composer.json not found${NC}"
    exit 1
fi

# 5. Install Composer dependencies
echo -e "${YELLOW}Installing Composer dependencies...${NC}"
if command -v composer &> /dev/null; then
    composer install --no-dev --optimize-autoloader
    echo -e "${GREEN}✓ Composer dependencies installed${NC}"
else
    echo -e "${YELLOW}⚠ Composer not found. Skipping...${NC}"
fi

# 6. Create necessary directories
echo -e "${YELLOW}Creating directories...${NC}"
mkdir -p _sessions
mkdir -p storage/logs
chmod -R 777 _sessions
chmod -R 777 storage/logs
echo -e "${GREEN}✓ Directories created${NC}"

# 7. Check Git status
echo -e "${YELLOW}Checking Git repository...${NC}"
if [ -d ".git" ]; then
    echo -e "${GREEN}✓ Git repository initialized${NC}"
    
    # Check if there are uncommitted changes
    if [ -n "$(git status --porcelain)" ]; then
        echo -e "${YELLOW}⚠ You have uncommitted changes${NC}"
        read -p "Do you want to commit them now? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git add .
            git commit -m "Prepare for Railway deployment"
            echo -e "${GREEN}✓ Changes committed${NC}"
        fi
    fi
else
    echo -e "${YELLOW}Git not initialized. Initializing...${NC}"
    git init
    git add .
    git commit -m "Initial commit - CyborX setup"
    echo -e "${GREEN}✓ Git repository initialized${NC}"
fi

# 8. Check for Railway files
echo -e "${YELLOW}Checking Railway configuration...${NC}"
railway_files=("railway.json" "Dockerfile" "nginx.conf" "schema.sql")
for file in "${railway_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓ $file exists${NC}"
    else
        echo -e "${RED}✗ $file is missing${NC}"
    fi
done

# 9. Summary
echo ""
echo "=================================="
echo -e "${GREEN}✓ Deployment prep complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Review and edit .env file with your configuration"
echo "2. Push to GitHub: git push origin main"
echo "3. Deploy on Railway: https://railway.app"
echo "4. Add MySQL database on Railway"
echo "5. Set environment variables on Railway"
echo "6. Run schema.sql on your Railway database"
echo ""
echo "For detailed instructions, see RAILWAY_DEPLOY.md"
echo "=================================="
