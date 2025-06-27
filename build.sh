#!/bin/bash

# build.sh: Automated build script for Tracks GTD application
# This script sets up and builds the Tracks application using Docker

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command_exists docker; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command_exists docker-compose; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    # Check if Docker daemon is running
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker daemon is not running. Please start Docker first."
        exit 1
    fi
    
    print_success "All prerequisites met"
}

# Function to clean up previous builds (optional)
cleanup_previous() {
    if [ "$1" = "--clean" ]; then
        print_status "Cleaning up previous builds..."
        
        # Stop and remove containers
        docker-compose down >/dev/null 2>&1 || true
        
        # Remove volumes (this will delete database data!)
        print_warning "This will delete all database data!"
        read -p "Are you sure you want to remove all data? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker-compose down -v >/dev/null 2>&1 || true
            print_success "Previous builds cleaned up"
        else
            print_status "Skipping data cleanup"
        fi
        
        # Remove dangling images
        docker image prune -f >/dev/null 2>&1 || true
    fi
}

# Function to create .use-docker file
enable_docker() {
    if [ ! -f .use-docker ]; then
        print_status "Enabling Docker support..."
        touch .use-docker
        print_success "Docker support enabled"
    else
        print_success "Docker support already enabled"
    fi
}

# Function to build the application
build_app() {
    print_status "Building Tracks application..."
    
    # Set environment variables for proper asset compilation
    export RAILS_ENV=production
    export DATABASE_NAME=tracks
    
    # Run the bootstrap script to build Docker images and assets
    print_status "Running bootstrap script..."
    ./script/bootstrap
    
    # Save Docker image as tar file for Apptainer use
    print_status "Saving Docker image for Apptainer..."
    docker save tracks-apptainer_web:latest > tracks_docker.tar
    print_success "Docker image saved as tracks_docker.tar"
    
    print_success "Application built successfully"
}

# Function to set up the database
setup_database() {
    print_status "Setting up database..."
    
    # Start database container first
    print_status "Starting database container..."
    docker-compose up -d db
    
    # Wait for database to be ready
    print_status "Waiting for database to be ready..."
    ./script/poll-for-db mysql
    
    # Set up the database schema and seed data using Docker container
    print_status "Setting up database schema..."
    docker-compose run --rm web bin/rake db:reset
    
    print_success "Database setup completed"
}

# Function to start the application
start_app() {
    if [ "$1" = "--start" ]; then
        print_status "Starting Tracks application..."
        ./script/server &
        SERVER_PID=$!
        
        print_success "Tracks is starting up..."
        print_status "Application will be available at: http://localhost:3000"
        print_status "Press Ctrl+C to stop the server"
        
        # Wait for the server process
        wait $SERVER_PID
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --clean    Clean up previous builds and data (WARNING: destroys database)"
    echo "  --start    Start the application after building"
    echo "  --help     Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Build the application"
    echo "  $0 --start            # Build and start the application"
    echo "  $0 --clean --start    # Clean, build, and start the application"
}

# Main build function
main() {
    echo ""
    print_status "Tracks GTD Application Build Script"
    echo ""
    
    # Parse command line arguments
    START_SERVER=false
    CLEAN_BUILD=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --clean)
                CLEAN_BUILD=true
                shift
                ;;
            --start)
                START_SERVER=true
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Execute build steps
    check_prerequisites
    
    if [ "$CLEAN_BUILD" = true ]; then
        cleanup_previous --clean
    fi
    
    enable_docker
    build_app
    setup_database
    
    print_success "Build completed successfully!"
    echo ""
    print_status "You can now:"
    print_status "• Start the server with: ./script/server"
    print_status "• Access the application at: http://localhost:3000"
    print_status "• Stop containers with: docker-compose down"
    echo ""
    
    if [ "$START_SERVER" = true ]; then
        start_app --start
    fi
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
