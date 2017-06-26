#!/bin/bash
clear
read -p "Enter the database password : " dp
read -p "Enter the username for whom you want to change the password : " u
read -p "Enter the password for $u : " p
a="$(sed -n '5p' /home/ubuntu/fedena/hash.sh)";
b="password= '$p'";
sed -i "5s|$a|$b|" /home/ubuntu/fedena/hash.sh;
bash /home/ubuntu/fedena/hash.sh >> /home/ubuntu/fedena/a.txt
c="$(sed -n '12p' /home/ubuntu/fedena/a.txt)";
d="$(sed -n '16p' /home/ubuntu/fedena/a.txt)";
mysql -u "root" -p"$dp" -D "fedena" -e "UPDATE users SET hashed_password=('$d') WHERE id = '1';UPDATE users SET salt=('$c') WHERE username = '$u';"
rm /home/ubuntu/fedena/a.txt;
echo "Password Changed!!!"
