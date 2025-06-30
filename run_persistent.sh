#!/bin/bash
# Simple persistent Tracks runner

# Create data directory if it doesn't exist
mkdir -p ./tracks_data

echo "🚀 Starting Tracks with persistent data..."
echo "📂 Data directory: $(pwd)/tracks_data"
echo "🌐 Access at: http://localhost:3000"
echo "👤 Login: admin/admin"
echo "🛑 Press Ctrl+C to stop"
echo

# Run with persistent data bind mount
apptainer run \
  --bind ./tracks_data:/tmp \
  --writable-tmpfs \
  tracks_apptainer.sif
