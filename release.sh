#!/bin/bash
# release.sh - Create a new release for the Tracks Apptainer project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if we're in a git repository
if [ ! -d .git ]; then
    print_error "This script must be run from the root of the git repository"
    exit 1
fi

# Get current version
if [ -f VERSION ]; then
    CURRENT_VERSION=$(cat VERSION)
    print_status "Current version: $CURRENT_VERSION"
else
    print_error "VERSION file not found"
    exit 1
fi

# Ask for new version
echo
print_status "Enter new version (current: $CURRENT_VERSION):"
read -p "New version: " NEW_VERSION

if [ -z "$NEW_VERSION" ]; then
    print_error "Version cannot be empty"
    exit 1
fi

# Validate version format (basic check)
if ! echo "$NEW_VERSION" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+' >/dev/null; then
    print_warning "Version doesn't follow semantic versioning (x.y.z)"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Update VERSION file
echo "$NEW_VERSION" > VERSION
print_success "Updated VERSION file to $NEW_VERSION"

# Check for uncommitted changes
if ! git diff --quiet; then
    print_status "Committing VERSION file update..."
    git add VERSION
    git commit -m "Bump version to $NEW_VERSION"
    print_success "Committed version update"
fi

# Create and push tag
TAG="$NEW_VERSION"
print_status "Creating git tag: $TAG"
git tag -a "$TAG" -m "Release version $NEW_VERSION"

print_status "Pushing tag to origin..."
git push origin "$TAG"

print_success "Release $TAG created successfully!"
echo
print_status "GitHub Actions will now:"
print_status "• Build Docker and Apptainer containers"
print_status "• Create a GitHub release"
print_status "• Attach both .sif and .tar files"
echo
print_status "Check the Actions tab to monitor the build:"
print_status "https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]\([^.]*\).*/\1/')/actions"
