#!/bin/bash
#
# This script builds your application containers and bootstraps the database
# Updated for Rails 7.1 / Ruby 3.2
#

set -e

# ensure .env.dev exists
if [ ! -f .env.dev ]; then
    echo "⚠️  .env.dev not found! Copying from env_example.txt..."
    cp env_example.txt .env.dev
fi

DCD='docker compose'

echo "🧹 Cleaning up old containers..."
$DCD down --remove-orphans 2>/dev/null || true

echo "🔨 Building the containers..."
$DCD build

echo "📦 Installing dependencies..."
$DCD run --rm web bash -c "bundle config set --local frozen false && bundle install"

echo "🗄️ Creating database..."
$DCD run --rm web bundle exec rails db:create

echo "🔄 Running migrations..."
$DCD run --rm web bundle exec rails db:migrate

echo "🌱 Seeding database..."
$DCD run --rm web bundle exec rails db:seed

echo "🎨 Compiling assets..."
$DCD run --rm web bundle exec rails dartsass:build

echo "✅ Build complete! Starting application..."
$DCD up