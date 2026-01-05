@echo off

:: ====== CHANGE THESE 3 THINGS ======
set MYSQLDUMP="C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqldump.exe"
set MYSQL_USER=root
set MYSQL_PASSWORD=Radi2005!
set DATABASE_NAME=hotel_management_db1
set BACKUP_PATH="G:\My Drive\sql"
:: ===================================

:: Create date YYYY-MM-DD
set DATE=%DATE:~10,4%-%DATE:~4,2%-%DATE:~7,2%

:: Create backup file
%MYSQLDUMP% -u %MYSQL_USER% -p%MYSQL_PASSWORD% --databases %DATABASE_NAME% > %BACKUP_PATH%\backup-%DATE%.sql

echo Backup created at: %BACKUP_PATH%\backup-%DATE%.sql
