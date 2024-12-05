# devOps_Begginer
## Project URL Server Performance Stats
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
Written for Unix/Linux-based systems or macOS.
Uses tools like top, vm_stat, df, and ps.
PowerShell Script
Written for Windows operating systems.
Utilizes modules like Get-WmiObject, Get-CimInstance, and Get-Process.
2. Information Displayed
Total CPU Usage
Uses top to display detailed metrics such as user, system, and idle CPU usage.
PowerShell Script
Provides only the average processor load percentage using Get-WmiObject.
Total Memory Usage
Calculates active, free, and total memory from vm_stat output and factors in page size.
PowerShell Script
Uses Get-CimInstance to fetch total and free memory information, then calculates used memory.
Disk Usage
Uses df to show disk usage for the root directory (/) only.
PowerShell Script
Leverages Get-PSDrive to check all drives on the system and displays usage for each drive.
Top Processes by CPU Usage
Uses ps and sort to list processes with the highest CPU usage and formats the output with awk.
PowerShell Script
Utilizes Get-Process to sort and display processes by CPU usage.
Top Processes by Memory Usage
Similar to CPU usage, ps is used to sort processes by memory usage.
PowerShell Script
Uses Get-Process to select processes with the highest memory usage.
3. Output Format
Produces simpler output formatted with awk.
Contains a bug where some table headers are repeated (e.g., "USER PID %CPU %MEM COMMAND").
PowerShell Script
Generates more structured and visually appealing output using Format-Table.
4. Compatibility and Tool Availability
Relies on standard Unix/Linux tools like vm_stat and ps, which may vary in syntax or availability across distributions.
PowerShell Script
Depends on built-in PowerShell modules available on most modern Windows systems.
5. Bugs or Limitations
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

## Project URL Log Archive Tool 
https://roadmap.sh/projects/log-archive-tool

Langkah 1: Persiapan Lingkungan
1.1. Pastikan Anda Buka Terminal
Buka aplikasi Terminal di Mac.
Anda dapat mencarinya melalui Spotlight Search (Command + Space, lalu ketik Terminal dan tekan Enter).
1.2. Pastikan Anda Memiliki Hak Akses
Pastikan Anda memiliki izin untuk membaca dan menulis di direktori yang akan Anda arsipkan, seperti /var/log. Coba perintah berikut:
ls /var/log
Jika berhasil melihat daftar file, Anda memiliki izin.
Jika muncul pesan Permission Denied, gunakan sudo untuk menjalankan perintah dengan hak admin:
sudo ls /var/log
Masukkan password Anda saat diminta.
1.3. Pastikan Perintah tar Sudah Tersedia
Ketik perintah berikut di Terminal untuk memastikan tar tersedia:
tar --version
Jika muncul versi (contoh: bsdtar 3.6.0), berarti tar tersedia.
Jika tidak ditemukan, instal tar melalui Homebrew:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install tar

Langkah 2: Buat File Script Bash
2.1. Buat File Script
Buat file bernama log-archive.sh di direktori kerja Anda:
touch log-archive.sh
chmod +x log-archive.sh
nano log-archive.sh
2.2. Salin Script ke File
Salin kode berikut ke dalam editor nano yang terbuka:
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
echo "[$(date)] Archived $LOG_DIR to $ARCHIVE_FILE" >> "$ARCHIVE_DIR/archive_log.txt"
echo "Logs berhasil diarsipkan ke: $ARCHIVE_FILE"

Simpan file dengan cara:
Tekan CTRL + O, lalu tekan Enter untuk menyimpan.
Tekan CTRL + X untuk keluar dari editor.

Langkah 3: Eksekusi Script
3.1. Jalankan Script
Pastikan Anda berada di direktori tempat log-archive.sh disimpan. Cek dengan:
ls
Jika file log-archive.sh terlihat, lanjutkan.
Jika tidak, pindah ke direktori tersebut dengan:
cd /path/to/your/script
Jalankan script dengan perintah:
./log-archive.sh <log-directory>
Contoh, jika direktori log adalah /var/log:
sudo ./log-archive.sh ~/var/log
Catatan: Jika muncul pesan Permission Denied, tambahkan sudo di depan perintah.

Langkah 4: Cek Hasil Eksekusi
4.1. Periksa File Arsip
Arsip log akan disimpan di direktori ~/log_archives. Untuk melihatnya:
ls ~/log_archives

4.2. Periksa File Log Operasi
File log aktivitas (log_archive.log) juga ada di ~/log_archives. Periksa isinya:

cat ~/log_archives/log_archive.log
Langkah 5: Troubleshooting
5.1. Jika Script Tidak Berjalan
Error: "Command not found"

Pastikan file memiliki izin eksekusi:
chmod +x log-archive.sh
Error: "Permission Denied"

Jalankan perintah dengan sudo:
sudo ./log-archive.sh /var/log
5.2. Jika Direktori Arsip Tidak Dibuat
Periksa apakah Anda memiliki ruang kosong di disk dengan:
df -h

#Notes_Log_Archive_Tool use CLI

Penjelasan Lebih Detail
Input Argumen:
Saat menjalankan skrip, Anda memberikan direktori target sebagai argumen, seperti berikut:
./log-archive.sh /var/log
Dalam contoh di atas, skrip akan hanya bekerja pada direktori /var/log dan semua isinya.

Pengarsipan Terfokus:
Skrip akan membaca semua file dan subdirektori dalam direktori yang diberikan (misalnya, /var/log), mengompresinya menjadi satu file .tar.gz, dan menyimpannya di direktori arsip (~/log_archives).

Jika Anda Menggunakan Direktori Downloads:
Jika Anda ingin mengarsipkan semua file di direktori Downloads, Anda harus menjalankan skrip seperti ini:
./log-archive.sh ~/Downloads
Dalam hal ini:
Semua file di dalam ~/Downloads (termasuk file skrip Anda sendiri) akan dimasukkan ke dalam arsip terkompresi.
File hasil arsip akan disimpan di ~/log_archives.
Skrip Tidak Auto-Scan:
Skrip tidak otomatis berjalan sendiri untuk mencari dan mengarsipkan file di semua direktori. Anda harus:

Menentukan direktori target (misalnya, ~/Downloads).
Menjalankan skrip secara manual untuk mengarsipkan data dari direktori tersebut.
Bagaimana Jika Anda Ingin Semua File di Downloads Terkompres Otomatis?
Untuk membuat proses otomatis:

Atur Cron Job (Scheduled Task):
Anda bisa menjadwalkan skrip ini agar berjalan otomatis setiap hari atau setiap minggu menggunakan cron di macOS.
Contoh:
Buka terminal dan jalankan:
crontab -e
Tambahkan baris berikut untuk menjalankan arsip setiap malam jam 2 pagi:
0 2 * * * /path/to/log-archive.sh ~/Downloads
Sesuaikan Skrip:
Jika ingin otomatis memproses file di ~/Downloads setiap kali skrip dijalankan tanpa perlu memberikan argumen, ubah skrip seperti ini:
LOG_DIR="$HOME/Downloads"
Apakah Semua Data di Downloads Sudah Terkompres?
Cek file arsip di ~/log_archives:

Jalankan:
ls ~/log_archives
Jika arsip yang dihasilkan ada, Anda dapat memverifikasi isinya dengan:
tar -tzf /path/to/your_archive.tar.gz
Ini akan menampilkan daftar semua file yang telah dikompresi.

Q&A
1. Bagaimana Jika Anda Mengubah Hak Kepemilikan?
Ketika Anda mengubah kepemilikan file atau direktori dengan perintah chown, hak akses file tersebut akan berpindah ke pengguna atau grup baru yang Anda tentukan. Jika file sebelumnya dimiliki oleh sistem (misalnya, oleh pengguna root), file tersebut tidak lagi menjadi milik root, yang mungkin memengaruhi aplikasi atau skrip tertentu yang membutuhkan akses khusus dari pengguna sistem.
2. Bagaimana Mengembalikan Hak Kepemilikan (Undo)?
a. Mengembalikan Kepemilikan ke Root
Jika file atau direktori sebelumnya dimiliki oleh root, Anda dapat mengembalikan hak kepemilikannya dengan:
sudo chown root:root <file/directory>
Contoh:
sudo chown root:root ~/log_archives/logs_archive.log
b. Mengembalikan Kepemilikan ke Pengguna Sebelumnya
Untuk mengembalikan kepemilikan ke pengguna atau grup lain (misalnya www-data atau pengguna lain), Anda bisa menentukan nama pengguna dan grup tersebut:
sudo chown previous_user:previous_group <file/directory>
Jika Anda tidak ingat siapa pemilik sebelumnya, gunakan log perintah:
history | grep chown
c. Mengembalikan Kepemilikan Rekursif
Jika Anda ingin mengembalikan kepemilikan seluruh direktori beserta isinya, gunakan opsi -R:
sudo chown -R root:root <directory>
3. Apa yang Terjadi Jika Anda Tidak Mengembalikan Kepemilikan?
Untuk File Sistem:
Jika Anda mengubah file sistem penting (misalnya, di /var/log), aplikasi yang memerlukan hak akses tertentu mungkin tidak dapat berjalan dengan benar. Oleh karena itu, selalu periksa izin file dan pemilik sebelum melakukan perubahan.

Untuk File Pribadi:
Jika file adalah milik Anda, tidak ada dampak berarti karena Anda masih bisa mengaksesnya. Namun, mengubah hak kepemilikan ke root dapat membuat Anda tidak bisa memodifikasinya tanpa sudo.

4. Bagaimana Menghindari Masalah?
Gunakan ls -l Sebelum Mengubah:
Selalu periksa pemilik file/direktori sebelum mengubahnya. Contoh:
ls -l ~/log_archives
Output:
-rw-r--r-- 1 root root 1234 Dec 4 10:00 logs_archive.log
Di sini, Anda bisa melihat bahwa pemiliknya adalah root.
Catat Perubahan:
Jika Anda membuat perubahan besar pada izin atau kepemilikan, simpan catatan untuk memudahkan pengembalian.

## Project URL Nginx Log Analyser
[https://roadmap.sh/projects/server-stats](https://roadmap.sh/projects/nginx-log-analyser)
1. Maksud Proyek
Tujuannya adalah untuk:
Membaca file log Nginx yang berisi informasi tentang setiap permintaan ke server.
Menyajikan ringkasan analisis seperti:
Top 5 IP address yang paling banyak melakukan permintaan.
Top 5 path (URL) yang paling sering diminta.
Top 5 kode status yang paling banyak muncul.
Top 5 user agents yang digunakan.
2. Langkah-Langkah Detail
Langkah 1: Persiapan File Log
Download file log sampel: Gunakan perintah berikut untuk mengunduh file log sampel ke sistem Anda:
curl -o nginx-access.log https://gist.githubusercontent.com/kamranahmedse/e66c3b9ea89a1a030d3b739eeeef22d0/raw/77fb3ac837a73c4f0206e78a236d885590b7ae35/nginx-access.log
Cek isi file log: Setelah file berhasil diunduh, gunakan perintah berikut untuk memverifikasi isinya:
cat nginx-access.log | less
Langkah 2: Analisis File Log
Berikut adalah komponen utama analisis:
2.1. Top 5 IP Addresses
Cari alamat IP yang paling sering muncul:
Langkah:
Ekstrak kolom pertama (IP address) dari file log menggunakan awk.
Gunakan sort untuk mengurutkan.
Gunakan uniq -c untuk menghitung jumlah permintaan per IP.
Urutkan berdasarkan jumlah permintaan menggunakan sort -nr.
Ambil 5 hasil teratas menggunakan head.
Perintah:
awk '{print $1}' nginx-access.log | sort | uniq -c | sort -nr | head -5
2.2. Top 5 Requested Paths
Cari path (URL) yang paling sering diminta:

Langkah:
Ekstrak path dari log menggunakan awk. Path biasanya ada di kolom ke-7.
Lakukan langkah serupa seperti untuk IP.
Perintah:
awk '{print $7}' nginx-access.log | sort | uniq -c | sort -nr | head -5
2.3. Top 5 Status Codes
Cari kode status HTTP yang paling sering muncul:

Langkah:
Ekstrak kode status (biasanya kolom ke-9).
Hitung jumlahnya seperti langkah sebelumnya.
Perintah:
awk '{print $9}' nginx-access.log | sort | uniq -c | sort -nr | head -5
2.4. Top 5 User Agents
Cari user agents (kolom terakhir dalam log):

Langkah:
Ekstrak kolom user agent.
Hitung jumlah kemunculannya.
Perintah:
awk -F'"' '{print $6}' nginx-access.log | sort | uniq -c | sort -nr | head -5
Langkah 3: Membuat Script Shell
Setelah semua perintah individu berhasil dijalankan, buat skrip untuk mengotomatisasi proses ini.

Buat file script: Buat file bernama nginx-log-analyser.sh:
nano nginx-log-analyser.sh
Isi file dengan kode berikut:
#!/bin/bash
# Pastikan file log diberikan sebagai argumen
if [ -z "$1" ]; then
    echo "Usage: $0 <log-file>"
    exit 1
fi
LOG_FILE="$1"
# Periksa apakah file log ada
if [ ! -f "$LOG_FILE" ]; then
    echo "Error: File $LOG_FILE tidak ditemukan!"
    exit 1
fi

# Top 5 IP addresses
echo "Top 5 IP addresses with the most requests:"
awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -n 5 | awk '{print $2, "-", $1, "requests"}'
echo

# Top 5 most requested paths
echo "Top 5 most requested paths:"
awk '{print $7}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -n 5 | awk '{print $2, "-", $1, "requests"}'
echo

# Top 5 response status codes
echo "Top 5 response status codes:"
awk '{print $9}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -n 5 | awk '{print $2, "-", $1, "requests"}'
echo

# Top 5 user agents
echo "Top 5 user agents:"
awk -F\" '{print $6}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -n 5 | awk '{print $2, "-", $1, "requests"}'
echo

Berikan hak eksekusi pada script:
chmod +x nginx-log-analyser.sh

Langkah 4: Jalankan Script
Jalankan script dengan memberikan file log sebagai argumen:
./nginx-log-analyser.sh nginx-access.log

output:
MacBooks-MacBook-Air:nginx macbookair$ nano nginx-log-analyser.sh 
MacBooks-MacBook-Air:nginx macbookair$ ./nginx-log-analyser.sh nginx-access.log 
Top 5 IP addresses with the most requests:
178.128.94.113 - 1087 requests
142.93.136.176 - 1087 requests
138.68.248.85 - 1087 requests
159.89.185.30 - 1086 requests
86.134.118.70 - 277 requests

Top 5 most requested paths:
/v1-health - 4560 requests
/ - 270 requests
/v1-me - 232 requests
/v1-list-workspaces - 127 requests
/v1-list-timezone-teams - 75 requests

Top 5 response status codes:
200 - 5740 requests
404 - 937 requests
304 - 621 requests
400 - 192 requests
"-" - 31 requests

Top 5 user agents:
DigitalOcean - 4347 requests
Mozilla/5.0 - 513 requests
Mozilla/5.0 - 332 requests
Custom-AsyncHttpClient - 294 requests
Mozilla/5.0 - 282 requests

