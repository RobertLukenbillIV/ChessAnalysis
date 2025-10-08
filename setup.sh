#!/bin/bash

echo "Setting up Chess Analysis Ruby project..."

# Check if Ruby is installed
if ! command -v ruby &> /dev/null; then
    echo "Error: Ruby is not installed. Please install Ruby 3.2.0 or later."
    exit 1
fi

# Check Ruby version
ruby_version=$(ruby -v | cut -d' ' -f2)
echo "Ruby version: $ruby_version"

# Install bundler if not present
if ! command -v bundle &> /dev/null; then
    echo "Installing bundler..."
    gem install bundler
fi

# Install dependencies
echo "Installing Ruby gems..."
bundle install

# Set up database
echo "Setting up database..."
ruby db/migrate.rb

# Run tests to verify setup
echo "Running tests to verify setup..."
bundle exec rspec

# Check code style
echo "Checking code style with RuboCop..."
bundle exec rubocop

echo ""
echo "Setup complete! You can now:"
echo "  1. Start the application: ruby app.rb"
echo "  2. Run tests: bundle exec rspec"
echo "  3. Check code style: bundle exec rubocop"
echo "  4. Start development server with auto-reload: bundle exec rerun ruby app.rb"
echo ""
echo "The application will be available at http://localhost:4567"