# devOps_Begginer
## Project URL
https://roadmap.sh/projects/server-stats

# Notes
Notes:
macOS
Create a file: nano server-stats.sh
Delete a file: rm server-stats.sh
Save and exit: Ctrl+O – Enter / Exit: Ctrl+X
Check the script for invisible characters: cat -A server-stats.sh
Set file permissions: chmod +x server-stats.sh
Execute the script: ./server-stats.sh
Debugging to see execution steps: bash -x ./server-stats.sh
Linux
Create a file: notepad server-stats.ps1
Check the file in the current directory: Get-ChildItem *.ps1
Set script permissions for execution: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
Run the script: .\server-stats.ps1
Comparison Between Linux & macOS
Both scripts are designed to display server performance statistics but differ significantly in their implementation, as they are written for different operating systems with distinct tools and syntax. Below is a comparison:

1. Target Platform
Bash Script

Written for Unix/Linux-based systems or macOS.
Uses tools like top, vm_stat, df, and ps.
PowerShell Script

Written for Windows operating systems.
Utilizes modules like Get-WmiObject, Get-CimInstance, and Get-Process.
2. Information Displayed
Total CPU Usage

Bash Script

Uses top to display detailed metrics such as user, system, and idle CPU usage.
PowerShell Script

Provides only the average processor load percentage using Get-WmiObject.
Total Memory Usage

Bash Script

Calculates active, free, and total memory from vm_stat output and factors in page size.
PowerShell Script

Uses Get-CimInstance to fetch total and free memory information, then calculates used memory.
Disk Usage

Bash Script

Uses df to show disk usage for the root directory (/) only.
PowerShell Script

Leverages Get-PSDrive to check all drives on the system and displays usage for each drive.
Top Processes by CPU Usage

Bash Script

Uses ps and sort to list processes with the highest CPU usage and formats the output with awk.
PowerShell Script

Utilizes Get-Process to sort and display processes by CPU usage.
Top Processes by Memory Usage

Bash Script

Similar to CPU usage, ps is used to sort processes by memory usage.
PowerShell Script

Uses Get-Process to select processes with the highest memory usage.
3. Output Format
Bash Script

Produces simpler output formatted with awk.
Contains a bug where some table headers are repeated (e.g., "USER PID %CPU %MEM COMMAND").
PowerShell Script

Generates more structured and visually appealing output using Format-Table.
4. Compatibility and Tool Availability
Bash Script

Relies on standard Unix/Linux tools like vm_stat and ps, which may vary in syntax or availability across distributions.
PowerShell Script

Depends on built-in PowerShell modules available on most modern Windows systems.
5. Bugs or Limitations
Bash Script

Table headers for processes are repeated unnecessarily.
Long process names are truncated due to inflexible column formatting in awk.
PowerShell Script
Decimal precision for memory usage (e.g., "7541.96 MB") could be rounded for clarity.
Does not provide detailed CPU usage breakdowns like user, system, or idle.

# Tutorial Bash Scripting
#!/bin/bash
# Bash Script: Server Performance Stats

echo "Server Performance Stats"
echo "========================="

# Function to display CPU usage
cpu_usage() {
    echo "1. Total CPU Usage:"
    top -l 1 | grep "CPU usage" | awk '{print $3, $4, $5, $6, $7, $8}'
}

# Function to display memory usage
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

# Function to display disk usage
disk_usage() {
    echo "3. Total Disk Usage:"
    df -h / | awk 'NR==2 {print "   Used: "$3 " / Free: "$4}'
}

# Function to display top 5 processes by CPU usage
top_cpu_processes() {
    echo "4. Top 5 Processes by CPU Usage:"
    echo "USER       PID       %CPU   %MEM   COMMAND"
    ps aux | sort -rk 3 | head -n 5 | awk '{printf "%-10s %-10s %-6s %-6s %-10s\n", $1, $2, $3, $4, $11}'
}

# Function to display top 5 processes by memory usage
top_memory_processes() {
    echo "5. Top 5 Processes by Memory Usage:"
    echo "USER       PID       %CPU   %MEM   COMMAND"
    ps aux | sort -rk 4 | head -n 5 | awk '{printf "%-10s %-10s %-6s %-6s %-10s\n", $1, $2, $3, $4, $11}'
}

# Call all functions
cpu_usage
memory_usage
disk_usage
top_cpu_processes
top_memory_processes

output :
Server Performance Stats
1. Total CPU Usage:
10.52% user, 20.27% sys, 69.20% idle
2. Total Memory Usage:
   Used: 702 MB / Free: 18 MB / Total: 720 MB
3. Total Disk Usage:
   Used: 92Gi / Free: 16Gi
4. Top 5 Processes by CPU Usage:
USER       PID        %CPU   %MEM   COMMAND   
macbookair 2943       4.8    5.5    /Applications/Google
macbookair 2677       2.4    1.9    /Applications/Google
macbookair 362        1.9    1.4    /Applications/Google
macbookair 525        1.8    0.3    /Applications/Utilities/Adobe
USER       PID       %CPU   %MEM   COMMAND
5. Top 5 Processes by Memory Usage:
USER       PID        %CPU   %MEM   COMMAND   
macbookair 2943       4.8    5.5    /Applications/Google
macbookair 255        0.7    4.2    /Applications/Google
macbookair 2958       0.0    2.6    /Applications/Google
macbookair 6007       0.0    2.0    /Applications/Google
USER       PID       %CPU   %MEM   COMMAND

###############################################################################################

Write-Host "Server Performance Stats"

Write-Host "`n1. Total CPU Usage:"
$cpuUsage = Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average | Select-Object -ExpandProperty Average
Write-Host "   $cpuUsage% Processor Time"

Write-Host "`n2. Total Memory Usage:"
$totalMemory = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1MB
$freeMemory = (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB
$usedMemory = $totalMemory - $freeMemory
Write-Host "   Used: $([math]::Round($usedMemory, 2)) MB / Free: $([math]::Round($freeMemory, 2)) MB / Total: $([math]::Round($totalMemory, 2)) MB"

Write-Host "`n3. Total Disk Usage:"
Get-PSDrive -PSProvider FileSystem | ForEach-Object {
    $usedSpace = $_.Used / 1GB
    $freeSpace = $_.Free / 1GB
    Write-Host "   Drive $($_.Name): Used: $([math]::Round($usedSpace, 2)) GB / Free: $([math]::Round($freeSpace, 2)) GB"
}

Write-Host "`n4. Top 5 Processes by CPU Usage:"
Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 | Format-Table -Property Name, Id, CPU, PM

Write-Host "`n5. Top 5 Processes by Memory Usage:"
Get-Process | Sort-Object PM -Descending | Select-Object -First 5 | Format-Table -Property Name, Id, CPU, PM

output :
Server Performance Stats
=========================

1. Total CPU Usage:
   4% Processor Time

2. Total Memory Usage:
   Used: 7541.96 MB / Free: 1.09 MB / Total: 7543.05 MB

3. Total Disk Usage:
   Drive C: Used: 263.13 GB / Free: 212.57 GB
   Drive G: Used: 12.54 GB / Free: 2.46 GB

4. Top 5 Processes by CPU Usage:

Name        Id        CPU        PM
----        --        ---        --
chrome   14944 101.078125 253669376
chrome   21928   33.15625 231526400
chrome    9040  29.578125 222257152
chrome   15576  28.109375 251150336
explorer  9524   25.71875 149823488



5. Top 5 Processes by Memory Usage:

Name              Id CPU               PM
----              -- ---               --
mongod          4612            372383744
steamwebhelper  2380 5.59375    304984064
chrome         15780 12.875     285716480
chrome         12256 23.8125    261443584
chrome         14944 101.078125 252682240


