#!/bin/bash

# Array of Rails versions to test
RAILS_VERSIONS=("7.0" "7.1" "7.2" "8.0")

# Function to run tests for a specific Rails version
run_tests() {
    local rails_version="$1"
    echo "\n=== Testing with Rails $rails_version ==="
    export BUNDLE_GEMFILE="gemfiles/activerecord_${rails_version}.gemfile"
    bundle install --quiet
    bundle exec rspec
    echo "\n=== Done with Rails $rails_version ==="
    echo "===================================\n"
}

# Run tests for each Rails version
for rails_version in "${RAILS_VERSIONS[@]}"; do
    run_tests "$rails_version"
done
