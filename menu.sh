#!/bin/sh

LOGFILE="/var/www/html"

BACKUP_DIR="var/www/backups"
mkdir -p $BACKUP_DIR

while true 
do
echo "------ MAIN MENU ------"
echo "1. Show logged-in users"
echo "2. Add user to intranet group"
echo "3. Zip Backup intranet Directory"
echo "4. Restore intranet backup"
echo "5. View audit Reports"
echo "6. Transfer intranet to live"
echo "7. Schedule backup at 02:00"
echo "8. Exit"

read -p "Enter your choice [1-8]: " choice

case $choice in 
1) 
echo "Current user:"
whoami
echo "All users on system:"
cut -d: -f1 /etc/passwd

echo "Active session:"
w
;;

2) 
echo "Enter username to add to intranet group:"
read username

if id "$username" &>/dev/null; then
    if groups "$username" | grep -q intranet; then
        echo "User already in intranet group"
else        
    sudo usermod -aG intranet $username
    echo "User added successfully"
    groups $username
fi
else
    echo "Error: User does not exist"
fi    
;;

3)
echo "Backing up intranet ..."

mkdir -p ~/Documents/CA2/backups
cp -r /var/www/html ~/Documents/CA2/intranet_copy
zip -r ~/Documents/CA2/backups/intranet_backup_$(date +\%F).zip ~/Documents/CA2/intranet_copy > /dev/null
rm -r ~/Documents/CA2/intranet_copy

echo "Backup completed!"
ls -lh ~/Documents/CA2/backups
;;
      

4)
echo "Restoring intranet backup..."
ls ~/Documents/CA2/backups
read -p "Enter the backup filename to restore: " backfile
sudo cp -r ~/Documents/CA2/backups/$backupfile /var/www/html/intranet/
echo "Restore completed!"
read -p "Press Enter to continue..."
;;

5)
echo "Showing audit logs for intranet..."
sudo ausearch -k intranet_monitor
read -p "Press Enter to continue..."
;;

6)
echo "Transfering intranet to live..."
sudo mkdir -p /var/www/html/live
sudo cp -r /var/wwww/html/intranet/* /var/www/html/live/
echo "Tranfer completed!"
read -p "Press Enter to continue..."
;;

7) 
echo "Scheduling automatic 2AM zip backup & transfer..."
(crontab -1 2>/dev/null; echo "0 2 * * * mkdir -p /home/tudublin/Documents/CA2/backups && zip -r /home/tudublin/Documents/CA2/backups/intranet_backup_\$(data +\%F).zip /var/www/html/intranet") | crontab -
(crontab -1 2>/dev/null; echo "0 2 * * * sudo mkdir -p /var/www/html/live && sudo cp -r /var/www/html/intranet/* /var/www/html/live/") | crontab -
echo "Cron jobs scheduled successfully!"
read -p "Press Enter to continue..."
;;

8)
echo "Exiting..."
exit 0
;;

*)
echo "Invalid option!"
read -p "Press Enter to continue..."
;;

esac

done


