#!/bin/bash

# Memastikan direktori log diberikan sebagai argumen
if [ -z "$1" ]; then
    echo "Error: Anda harus memberikan direktori log sebagai argumen!"
    echo "Usage: ./log-archive.sh <log-directory>"
    exit 1
fi

# Direktori log yang diberikan sebagai argumen
LOG_DIR="$1"

# Direktori tujuan arsip
ARCHIVE_DIR="$HOME/log_archives"

# Membuat direktori tujuan jika belum ada
mkdir -p "$ARCHIVE_DIR"

# Nama file arsip dengan timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ARCHIVE_FILE="$ARCHIVE_DIR/logs_archive_$TIMESTAMP.tar.gz"

# Kompresi file log
tar -czf "$ARCHIVE_FILE" -C "$LOG_DIR" .

# Mencatat waktu arsip
echo "[$(date)] Archived $LOG_DIR to $ARCHIVE_FILE" >> "$ARCHIVE_DIR/logs_archive.log"

echo "Logs berhasil diarsipkan ke: $ARCHIVE_FILE"
