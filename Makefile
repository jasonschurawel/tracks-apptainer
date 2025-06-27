# Minimal Makefile for Tracks Docker Management

# Default target shows available commands
.PHONY: help
help: ## Show available commands
	@echo "Available commands:"
	@echo "  make build          - Interactive build (choose Docker/Apptainer/Both)"
	@echo "  make docker-run     - Start the application"
	@echo "  make apptainer-run  - Run the Apptainer container"
	@echo "  make show-browser   - Open Tracks application in browser"
	@echo "  make docker-stop    - Stop the application"
	@echo "  make apptainer-clean - Clean up running Apptainer/Rails processes"
	@echo "  make clean-build    - Clean up previous builds (WARNING: deletes containers and data!)"

.PHONY: build
build: ## Build the application with interactive options
	@echo "Choose what to build:"
	@echo "  1) Docker only"
	@echo "  2) Apptainer only (requires existing Docker image)"
	@echo "  3) Both Docker and Apptainer successively"
	@echo "  4) Cancel"
	@read -p "Enter your choice (1-4): " choice; \
	case $$choice in \
		1) echo "Building Docker only..."; ./build.sh ;; \
		2) echo "Building Apptainer only..."; make apptainer ;; \
		3) echo "Building Docker first, then Apptainer..."; ./build.sh && make apptainer ;; \
		4) echo "Build cancelled."; exit 0 ;; \
		*) echo "Invalid choice. Please run 'make build' again."; exit 1 ;; \
	esac

.PHONY: build-docker
build-docker: ## Build Docker image only
	./build.sh

.PHONY: build-apptainer  
build-apptainer: ## Build Apptainer container only
	make apptainer

.PHONY: build-both
build-both: ## Build both Docker and Apptainer successively
	./build.sh && make apptainer

.PHONY: build-clean
build-clean: ## Clean up previous builds (WARNING: deletes containers and data!)
	@echo "Cleaning up previous builds..."
	@echo "WARNING: This will remove Docker containers, volumes, and build artifacts!"
	@read -p "Are you sure you want to continue? (y/N): " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		echo "Stopping and removing Docker containers..."; \
		docker-compose down -v 2>/dev/null || true; \
		echo "Removing Docker images..."; \
		docker image rm tracks_web:latest 2>/dev/null || true; \
		echo "Removing build artifacts..."; \
		rm -f tracks_docker.tar tracks_apptainer.sif 2>/dev/null || true; \
		echo "Removing temporary files..."; \
		rm -f /tmp/tracks.sqlite3 2>/dev/null || true; \
		rm -rf ./apptainer-data/ 2>/dev/null || true; \
		echo "Cleanup completed!"; \
	else \
		echo "Cleanup cancelled."; \
	fi

.PHONY: docker-run
docker-run: ## Start the application
	RAILS_ENV=production DATABASE_NAME=tracks docker-compose up -d

.PHONY: docker-stop
docker-stop: ## Stop the application
	docker-compose down

.PHONY: apptainer
apptainer: ## Build working Apptainer container (RECOMMENDED)
	@if ! docker image inspect tracks-apptainer_web:latest >/dev/null 2>&1; then \
		echo "Docker image tracks-apptainer_web:latest not found. Run 'make build' first."; \
		exit 1; \
	fi
	@echo "Building Apptainer container from Docker daemon..."
	apptainer build --force tracks_apptainer.sif tracks_apptainer.def
	@echo "Apptainer container built: tracks_apptainer.sif"

.PHONY: apptainer-daemon
apptainer-daemon: ## Build Apptainer container from Docker daemon (alternative)
	@if ! docker image inspect tracks_web:latest >/dev/null 2>&1; then \
		echo "Docker image tracks_web:latest not found. Run 'make build' first."; \
		exit 1; \
	fi
	@echo "Building Apptainer container from Docker daemon..."
	apptainer build --force tracks_apptainer.sif tracks_apptainer.def
	@echo "Apptainer container built: tracks_apptainer.sif"

.PHONY: apptainer-run
apptainer-run: ## Run the Apptainer container
	@if [ ! -f tracks_apptainer.sif ]; then echo "tracks_apptainer.sif not found. Run 'make apptainer' first."; exit 1; fi
	@echo "Starting Tracks GTD Application..."
	@echo "Application will be available at http://localhost:3000"
	@echo "Default login: admin/admin"
	@echo "Press Ctrl+C to stop the application"
	apptainer run --writable-tmpfs tracks_apptainer.sif

.PHONY: apptainer-clean
apptainer-clean: ## Clean up running Apptainer/Rails processes and temp files
	@echo "Stopping any running Rails/Puma processes..."
	@pkill -f "puma.*3000" || true
	@pkill -f "rails server" || true
	@pkill -f "ruby.*rails" || true
	@pkill -f "apptainer" || true
	@echo "Killing any processes using port 3000..."
	@lsof -ti:3000 | xargs -r kill -9 || true
	@echo "Removing database files..."
	@rm -f /tmp/tracks.sqlite3 || true
	@rm -f ./apptainer-data/db/* || true
	@echo "Removing PID files..."
	@rm -f ./apptainer-data/tmp/pids/server.pid || true
	@rm -f /tmp/server.pid || true
	@echo "Waiting for processes to stop..."
	@sleep 2
	@echo "Cleanup complete."

.PHONY: show-browser
show-browser: ## Open Tracks application in browser
	@echo "Opening Tracks GTD Application in browser..."
	@echo "URL: http://localhost:3000"
	@echo "Default login: admin/admin"
	@if command -v xdg-open >/dev/null 2>&1; then \
		xdg-open http://localhost:3000; \
	elif command -v open >/dev/null 2>&1; then \
		open http://localhost:3000; \
	elif command -v firefox >/dev/null 2>&1; then \
		firefox http://localhost:3000 & \
	elif command -v google-chrome >/dev/null 2>&1; then \
		google-chrome http://localhost:3000 & \
	elif command -v chromium-browser >/dev/null 2>&1; then \
		chromium-browser http://localhost:3000 & \
	else \
		echo "Could not detect browser. Please open http://localhost:3000 manually."; \
	fi

# Backward compatibility aliases
.PHONY: run clean-build stop
run: docker-run  ## Alias for docker-run (backward compatibility)
clean-build: build-clean  ## Alias for build-clean (backward compatibility)  
stop: docker-stop  ## Alias for docker-stop (backward compatibility)