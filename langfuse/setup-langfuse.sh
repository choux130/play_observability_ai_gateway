#!/bin/bash
# Langfuse Setup with Pre-configured Default User
# This script sets up Langfuse with automatic admin user creation

set -e

echo "=========================================="
echo "Langfuse Setup - With Default User"
echo "=========================================="
echo ""

# Check if Docker is running
echo "Step 1: Checking Docker..."
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running"
    echo "Please start Docker Desktop or Docker daemon"
    exit 1
fi
echo "✅ Docker is running"
echo ""

# Check if Docker Compose is available
echo "Step 2: Checking Docker Compose..."
if ! docker compose version > /dev/null 2>&1; then
    if ! docker-compose version > /dev/null 2>&1; then
        echo "❌ Docker Compose is not installed"
        echo "Install from: https://docs.docker.com/compose/install/"
        exit 1
    fi
    COMPOSE_CMD="docker-compose"
else
    COMPOSE_CMD="docker compose"
fi
echo "✅ Docker Compose is available"
echo ""

# Ask if user wants to customize credentials
echo "Step 3: Default credentials configuration"
echo ""
echo "⚠️  Current default credentials:"
echo "   Email:    admin@localhost.com"
echo "   Password: admin123"
echo ""
read -p "Do you want to customize these credentials? (y/n): " customize

if [[ $customize == "y" ]]; then
    echo ""
    read -p "Enter email [admin@localhost.com]: " user_email
    user_email=${user_email:-admin@localhost.com}
    
    read -s -p "Enter password [admin123]: " user_password
    user_password=${user_password:-admin123}
    echo ""
    
    read -p "Enter name [Admin User]: " user_name
    user_name=${user_name:-Admin User}
    
    read -p "Enter organization name [Local Organization]: " org_name
    org_name=${org_name:-Local Organization}
    
    read -p "Enter project name [Local Project]: " project_name
    project_name=${project_name:-Local Project}
    
    # Update docker-compose file with custom values
    echo ""
    echo "Updating configuration with your credentials..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s|LANGFUSE_INIT_USER_EMAIL: \"admin@localhost.com\"|LANGFUSE_INIT_USER_EMAIL: \"${user_email}\"|g" docker-compose.yml
        sed -i '' "s|LANGFUSE_INIT_USER_PASSWORD: \"admin123\"|LANGFUSE_INIT_USER_PASSWORD: \"${user_password}\"|g" docker-compose.yml
        sed -i '' "s|LANGFUSE_INIT_USER_NAME: \"Admin User\"|LANGFUSE_INIT_USER_NAME: \"${user_name}\"|g" docker-compose.yml
        sed -i '' "s|LANGFUSE_INIT_ORG_NAME: \"Local Organization\"|LANGFUSE_INIT_ORG_NAME: \"${org_name}\"|g" docker-compose.yml
        sed -i '' "s|LANGFUSE_INIT_PROJECT_NAME: \"Local Project\"|LANGFUSE_INIT_PROJECT_NAME: \"${project_name}\"|g" docker-compose.yml
    else
        # Linux
        sed -i "s|LANGFUSE_INIT_USER_EMAIL: \"admin@localhost.com\"|LANGFUSE_INIT_USER_EMAIL: \"${user_email}\"|g" docker-compose.yml
        sed -i "s|LANGFUSE_INIT_USER_PASSWORD: \"admin123\"|LANGFUSE_INIT_USER_PASSWORD: \"${user_password}\"|g" docker-compose.yml
        sed -i "s|LANGFUSE_INIT_USER_NAME: \"Admin User\"|LANGFUSE_INIT_USER_NAME: \"${user_name}\"|g" docker-compose.yml
        sed -i "s|LANGFUSE_INIT_ORG_NAME: \"Local Organization\"|LANGFUSE_INIT_ORG_NAME: \"${org_name}\"|g" docker-compose.yml
        sed -i "s|LANGFUSE_INIT_PROJECT_NAME: \"Local Project\"|LANGFUSE_INIT_PROJECT_NAME: \"${project_name}\"|g" docker-compose.yml
    fi
    
    echo "✅ Credentials updated"
    
    # Save to credentials file
    cat > .langfuse-credentials << EOF
# Your Langfuse Credentials
# Keep this file secure!

Email:    ${user_email}
Password: ${user_password}
Name:     ${user_name}
Org:      ${org_name}
Project:  ${project_name}

Login at: http://localhost:3000
EOF
    
    echo "✅ Credentials saved to .langfuse-credentials"
else
    echo "Using default credentials"
fi

echo ""

# Generate secrets if needed
echo "Step 4: Checking secrets configuration..."
if grep -q "change-this-to-a-random-secret" docker-compose.yml; then
    echo "⚠️  WARNING: You're using default secrets!"
    echo ""
    read -p "Do you want to generate secure random secrets? (recommended) (y/n): " gen_secrets
    
    if [[ $gen_secrets == "y" ]]; then
        echo "Generating secrets..."
        
        NEXTAUTH_SECRET=$(openssl rand -base64 32)
        SALT=$(openssl rand -base64 32)
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s|NEXTAUTH_SECRET: change-this-to-a-random-secret-min-32-chars|NEXTAUTH_SECRET: ${NEXTAUTH_SECRET}|g" docker-compose.yml
            sed -i '' "s|SALT: change-this-salt-to-something-random|SALT: ${SALT}|g" docker-compose.yml
        else
            sed -i "s|NEXTAUTH_SECRET: change-this-to-a-random-secret-min-32-chars|NEXTAUTH_SECRET: ${NEXTAUTH_SECRET}|g" docker-compose.yml
            sed -i "s|SALT: change-this-salt-to-something-random|SALT: ${SALT}|g" docker-compose.yml
        fi
        
        echo "✅ Secrets generated"
    fi
fi
echo ""

# Stop any existing containers
echo "Step 5: Cleaning up any existing Langfuse containers..."
$COMPOSE_CMD -f docker-compose.yml down -v 2>/dev/null || true
echo "✅ Cleanup complete"
echo ""

# Pull images
echo "Step 6: Pulling Docker images..."
$COMPOSE_CMD -f docker-compose.yml pull
echo "✅ Images pulled"
echo ""

# Start services
echo "Step 7: Starting Langfuse with seed user..."
$COMPOSE_CMD -f docker-compose.yml up -d
echo "✅ Services started"
echo ""

# Wait for services to be healthy
echo "Step 8: Waiting for services to initialize..."
echo "This includes creating your default user (30-60 seconds)..."

max_attempts=40
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if docker exec langfuse-server wget --quiet --tries=1 --spider http://localhost:3000/api/public/health 2>/dev/null; then
        echo "✅ Langfuse is ready!"
        break
    fi
    
    attempt=$((attempt + 1))
    echo "  Waiting... ($attempt/$max_attempts)"
    sleep 2
done

if [ $attempt -eq $max_attempts ]; then
    echo "❌ Langfuse failed to start within expected time"
    echo "Check logs with: $COMPOSE_CMD -f docker-compose.yml logs langfuse-server"
    exit 1
fi

echo ""
echo "=========================================="
echo "✅ Langfuse is running with default user!"
echo "=========================================="
echo ""
echo "🌐 Web UI:       http://localhost:3000"
echo ""
echo "🔑 Login credentials:"
if [[ $customize == "y" ]]; then
    echo "   Email:    ${user_email}"
    echo "   Password: ${user_password}"
    echo ""
    echo "   (Saved in .langfuse-credentials file)"
else
    echo "   Email:    admin@localhost.com"
    echo "   Password: admin123"
    echo ""
    echo "   ⚠️  CHANGE THESE BEFORE PRODUCTION USE!"
fi
echo ""
echo "📝 Next steps:"
echo "   1. Open http://localhost:3000"
echo "   2. Click 'Sign in'"
echo "   3. Enter your credentials above"
echo "   4. Go to Settings → API Keys"
echo "   5. Copy your keys and add to .env file:"
echo "      LANGFUSE_PUBLIC_KEY=pk-lf-..."
echo "      LANGFUSE_SECRET_KEY=sk-lf-..."
echo "      LANGFUSE_HOST=http://localhost:3000"
echo ""
echo "🛠️  Useful commands:"
echo "   View logs:       $COMPOSE_CMD -f docker-compose.yml logs -f"
echo "   Stop Langfuse:   $COMPOSE_CMD -f docker-compose.yml down"
echo "   Restart:         $COMPOSE_CMD -f docker-compose.yml restart"
echo ""
echo "🔒 Features:"
echo "   ✅ Default user pre-created"
echo "   ✅ Public signup disabled"
echo "   ✅ Organization and project ready"
echo "   ✅ No external connections"
echo "   ✅ All data stored locally"
echo ""
