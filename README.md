# Tracks: a GTD™ compatible web application built with Ruby on Rails

[![Build Status](https://github.com/TracksApp/tracks/workflows/Continuous%20Integration/badge.svg)](https://github.com/TracksApp/tracks/actions)
[![Code Climate](https://codeclimate.com/github/TracksApp/tracks/badges/gpa.svg)](https://codeclimate.com/github/TracksApp/tracks)
[![Translation status](https://hosted.weblate.org/widgets/tracks/-/tracks/svg-badge.svg)](https://hosted.weblate.org/engage/tracks/)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/6459/badge)](https://bestpractices.coreinfrastructure.org/projects/6459)

## 🐋 Fork Notice: Enhanced Containerization

This is a fork of the original [TracksApp/tracks](https://github.com/TracksApp/tracks) repository with **enhanced Docker and Apptainer containerization support**. 

### Key Enhancements in This Fork:

- **Complete Docker setup** with simplified Makefile commands
- **Standalone Apptainer/Singularity container** (`tracks_apptainer.sif`) - fully self-contained with embedded SQLite database
- **Pre-configured admin user** (admin/admin) for immediate use
- **One-command deployment** - no complex setup required
- **Production-ready containerization** suitable for HPC environments and portable deployments

### Why Apptainer Over Docker?

**Apptainer offers significant advantages for many use cases:**

- **🚀 Superior Portability**: Single SIF file contains everything - copy once, run anywhere with Apptainer/Singularity
- **🔒 Enhanced Security**: Runs without root privileges, making it ideal for multi-user and HPC environments
- **⚡ SLURM Integration**: Native support for SLURM workload managers - perfect for academic and research computing clusters
- **📦 True Immutability**: SIF files are read-only by design, ensuring reproducible deployments
- **🎯 HPC-Optimized**: Designed specifically for scientific computing and cluster environments
- **🔄 No Daemon Required**: Unlike Docker, no background services needed - just execute the container directly

### Quick Start with Containers:

```bash
# 🎯 FASTEST: Download pre-built container (recommended)
wget https://github.com/jasonschurawel/tracks-apptainer/releases/latest/download/tracks_apptainer.sif
apptainer run tracks_apptainer.sif

# 🐋 Docker approach (from release):
wget https://github.com/jasonschurawel/tracks-apptainer/releases/latest/download/tracks_docker.tar
docker load < tracks_docker.tar
docker run -p 3000:3000 tracks-apptainer_web:latest

# 🔧 Build locally (for development):
make build && make run

# ⚡ SLURM clusters:
sbatch --wrap="apptainer run tracks_apptainer.sif"
```

### 📦 Pre-built Containers

**GitHub automatically builds both Apptainer and Docker containers for every release!**

- **✅ Zero setup required** - download and run immediately
- **✅ Tested and verified** - built and tested in CI/CD pipeline  
- **✅ Always up-to-date** - automatically built from latest code
- **✅ Multiple formats** - Both Apptainer SIF and Docker TAR files available
- **✅ Version controlled** - Each release is properly tagged and versioned

Visit the [Releases page](https://github.com/jasonschurawel/tracks-apptainer/releases) to download the latest pre-built containers.

#### Available Downloads per Release:
- **`tracks_apptainer.sif`** - Apptainer/Singularity container (recommended for HPC)
- **`tracks_docker.tar`** - Docker image archive (for Docker environments)

The Apptainer container is completely standalone - you can copy `tracks_apptainer.sif` to any system with Apptainer/Singularity and run it immediately without any dependencies, root access, or complex setup. Perfect for shared computing environments and research clusters.

---

## About

* Project homepage: http://www.getontracks.org/
* Manual: http://www.getontracks.org/manual/
* Source at GitHub: https://github.com/TracksApp/tracks
* Hosted services: https://github.com/TracksApp/tracks/wiki/Hosted-Tracks
* Bug reports and feature requests: https://github.com/TracksApp/tracks/issues
* Mailing list: http://groups.google.com/group/TracksApp
* License: See COPYING

Full instructions for both new installations and upgrades from older installations
of Tracks can be found in the [wiki](https://github.com/TracksApp/tracks/wiki/Installation).

As always, make sure that you take sensible precautions and back up all your data frequently,
taking particular care when you are upgrading.

Enjoy being productive!

## Contributors and consulting

* Original developer: bsag (http://www.rousette.org.uk/)
* Principal maintainer: [Jyri-Petteri ”ZeiP” Paloposki](https://github.com/ZeiP)
  (sponsored by [Ardcoras oy](https://www.ardcoras.fi/), also available for paid consulting)
  * If you want to support the maintainer's work, subscribe to the
    [hosted version](https://www.taskitin.fi/).
* Contributors: https://github.com/TracksApp/tracks/wiki/Contributors

If you are thinking about contributing towards the development of Tracks,
please read /CONTRIBUTING.md for general information. Also you can find
some information on development, testing and contributing on the wiki.

## 🐋 Containerization Details

This fork includes comprehensive containerization support for easy deployment:

### 🤖 Automated Builds (GitHub Actions)
- **🔄 Continuous Integration**: Automatic testing on every push
- **📦 Release Automation**: Pre-built containers for every GitHub release
- **🏷️ Version Management**: Semantic versioning with automatic tagging
- **✅ Multi-format**: Both Apptainer SIF and Docker TAR files
- **🧪 Tested**: All containers are automatically tested before release
- **📋 Artifacts**: Development builds available as GitHub Actions artifacts

#### Creating Releases
```bash
# Easy release creation
./release.sh

# Manual release creation
echo "R1.1.0" > VERSION
git add VERSION
git commit -m "Bump version to R1.1.0"
git tag R1.1.0
git push origin R1.1.0
```

### Docker Setup
- **Simplified Makefile**: Use `make build`, `make run`, `make stop` for container management
- **Production-ready**: Uses multi-stage builds with optimized Ruby/Rails configuration
- **Database flexibility**: Supports PostgreSQL, MySQL, and SQLite

### Apptainer/Singularity Container
- **Standalone SIF file**: `tracks_apptainer.sif` contains the complete application.
- **Portable**: Copy the SIF file to any system with Apptainer/Singularity support. It just works.
- **No external dependencies**: Only Apptainer has to be installed. No other Libraries or Software needed. It will still work in 2055.
- **HPC-optimized**: Perfect for academic/research computing environments and shared clusters. No need to set up seperate Servers for Project Management.
- **SLURM-ready**: Seamless integration with SLURM workload manager - no special configuration needed.
- **Root-free execution**: Runs with user privileges, meeting strict HPC security requirements.
- **Cluster-friendly**: No network requirements or complex port management. Just open localhost:3000 or remap port if needed in your configuration.

### Available Commands
```bash
# Docker commands
sudo make build  # Interactive build (choose Docker/Apptainer/Both)"
make docker-run  # Start the application"
make apptainer-run  # Run the Apptainer container"
make show-browser # Open Tracks application in browser"
make docker-stop  # Stop the application"
make apptainer-clean # Clean up running Apptainer/Rails processes"
sudo make clean-build    # Clean up previous builds (WARNING: deletes containers and data!)"
```

### SLURM Cluster Usage Examples
```bash
# Basic SLURM job
sbatch --wrap="apptainer run tracks_apptainer.sif"

# Interactive SLURM session
srun --pty apptainer shell tracks_apptainer.sif

# SLURM batch script example
#!/bin/bash
#SBATCH --job-name=tracks-app
#SBATCH --time=4:00:00
#SBATCH --mem=2G
#SBATCH --cpus-per-task=2

apptainer run --bind /scratch:/data tracks_apptainer.sif
```

### Container Features
- **Immediate startup**: Pre-migrated database with admin user ready
- **Secure defaults**: Production Rails environment with proper security settings
- **Resource efficient**: Optimized for minimal memory and storage usage
- **Cross-platform**: Works on Linux, macOS (Docker), and HPC clusters (Apptainer)

### 💾 Persistent Data (Simple Method)

By default, the Apptainer container loses data on restart. For persistent data:

```bash
# Simple persistent setup (recommended)
make setup-persistent           # Create data directory
make apptainer-run-persistent   # Run with persistence

# Or directly:
mkdir -p tracks_data
chmod +x run_persistent.sh
./run_persistent.sh
```

This creates a `tracks_data/` directory that preserves your database and files between runs.

**Why this works:**
- Binds local `./tracks_data/` to container's `/tmp/` where the SQLite database lives
- Simple, no complex configuration needed
- Data persists automatically between container restarts
- Just copy `tracks_data/` to backup/move your data
