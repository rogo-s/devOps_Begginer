# devOps_Begginer
# Server Performance Stats 
# Compare between Linux & MacOS
# Bash Scripting
 
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
    ps aux | sort -rk 3 | head -n 5 | awk '{printf "%-10s %-10s %-6s %-6s %-10s\n", $1, $2, $3, $$
    echo "USER       PID       %CPU   %MEM   COMMAND"
}

# Function to get top 5 memory consuming processes
top_memory_processes() {
    echo "5. Top 5 Processes by Memory Usage:"
    ps aux | sort -rk 4 | head -n 5 | awk '{printf "%-10s %-10s %-6s %-6s %-10s\n", $1, $2, $3, $$
    echo "USER       PID       %CPU   %MEM   COMMAND"
}

# Execute functions
cpu_usage
memory_usage
disk_usage
top_cpu_processes
top_memory_processes

output :
Server Performance Stats
=========================
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

Notes : 
MacOS
buat file (nano server-stats.sh) && delete file (rm server-stats.sh)
simpan dan keluar (Ctrl+O – Enter / keluar (Ctrl+X)) && melihat skrip tidak memiliki karakter tak terlihat (cat -A server-stats.sh)
Izin File chmod +x server-stats.sh
Eksekusi File ./server-stats.sh
debugging untuk melihat langkah eksekusi (bash -x ./server-stats.sh)


###############################################################################################

# Display Server Performance Stats
Write-Host "Server Performance Stats"
Write-Host "========================="

# CPU Usage
Write-Host "`n1. Total CPU Usage:"
$cpuUsage = Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average | Select-Object -ExpandProperty Average
Write-Host "   $cpuUsage% Processor Time"

# Memory Usage
Write-Host "`n2. Total Memory Usage:"
$totalMemory = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1MB
$freeMemory = (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB
$usedMemory = $totalMemory - $freeMemory
Write-Host "   Used: $([math]::Round($usedMemory, 2)) MB / Free: $([math]::Round($freeMemory, 2)) MB / Total: $([math]::Round($totalMemory, 2)) MB"

# Disk Usage
Write-Host "`n3. Total Disk Usage:"
Get-PSDrive -PSProvider FileSystem | ForEach-Object {
    $usedSpace = $_.Used / 1GB
    $freeSpace = $_.Free / 1GB
    Write-Host "   Drive $($_.Name): Used: $([math]::Round($usedSpace, 2)) GB / Free: $([math]::Round($freeSpace, 2)) GB"
}

# Top 5 Processes by CPU Usage
Write-Host "`n4. Top 5 Processes by CPU Usage:"
Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 | Format-Table -Property Name, Id, CPU, PM

# Top 5 Processes by Memory Usage
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

Notes : 
Linux
Membuat file (notepad server-stats.ps1)
Memeriksa file didirektory aktif  (Get-ChildItem *.ps1)
Izin skrip untuk running (Set-ExecutionPolicy RemoteSigned -Scope CurrentUser)
Menjalankan skrip (.\server-stats.ps1)
