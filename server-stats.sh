#!/bin/bash

# Header
echo "Server Performance Stats"
echo "========================="

# Function to get total CPU usage
cpu_usage() {
    echo "1. Total CPU Usage:"
    top -l 1 | grep "CPU usage" | awk '{print $3, $4, $5, $6, $7, $8}'
}

# Function to get memory usage
memory_usage() {
    echo "2. Total Memory Usage:"
    mem_used=$(vm_stat | grep 'Pages active' | awk '{print $3}' | sed 's/\.//')
    mem_free=$(vm_stat | grep 'Pages free' | awk '{print $3}' | sed 's/\.//')
    page_size=$(sysctl -n hw.pagesize)
    mem_used_mb=$((mem_used * page_size / 1024 / 1024))
    mem_free_mb=$((mem_free * page_size / 1024 / 1024))
    mem_total_mb=$((mem_used_mb + mem_free_mb))
    echo "   Used: ${mem_used_mb} MB / Free: ${mem_free_mb} MB / Total: ${mem_total_mb} MB"
}

# Function to get disk usage
disk_usage() {
    echo "3. Total Disk Usage:"
    df -h / | awk 'NR==2 {print "   Used: "$3 " / Free: "$4}'
}

# Function to get top 5 CPU consuming processes
top_cpu_processes() {
    echo "4. Top 5 Processes by CPU Usage:"
    ps aux | sort -rk 3 | head -n 5 | awk '{printf "%-10s %-10s %-6s %-6s %-10s\n", $1, $2, $3, $4, $11}'
    echo "USER       PID       %CPU   %MEM   COMMAND"
}

# Function to get top 5 memory consuming processes
top_memory_processes() {
    echo "5. Top 5 Processes by Memory Usage:"
    ps aux | sort -rk 4 | head -n 5 | awk '{printf "%-10s %-10s %-6s %-6s %-10s\n", $1, $2, $3, $4, $11}'
    echo "USER       PID       %CPU   %MEM   COMMAND"
}

# Execute functions
cpu_usage
memory_usage
disk_usage
top_cpu_processes
top_memory_processes

