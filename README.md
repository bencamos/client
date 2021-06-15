tut for client

MAKE SURE YOU CONFIGURE IP ADDRESS IN ALL FILES
SET LOGIN INFORMATION INSIDE crypto.php

--------------------------------------------
Setting up FTP Server for HackerViewer (Remote Screenshare)
--------------------------------------------
You will need to install and change vsftpd config to this.
You can find the config in /etc/vsftpd.cnf
```
listen=NO
listen_port=34812
listen_ipv6=YES
anonymous_enable=YES
local_enable=no
write_enable=YES
local_umask=022
file_open_mode=0777
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
anon_root=/var/ftp/
no_anon_password=YES
hide_ids=YES
pasv_min_port=40000
pasv_max_port=50000
anon_mkdir_write_enable=YES
anon_upload_enable=YES
anon_other_write_enable=YES
anon_umask=022
```
Make sure you restart after setting the config
----------------------------------------------
Known Bugs
----------------------------------------------
Backspace glitchy i have no idea how to fix this without completely changing the program
screen freezes untill user interaction on file receive

###Notes

This was made on kali so prolly works on any deb machine

The "api" to send the messages thru probably could of been done in c with sockets but you can just use ssl for extra encryption

Emojis are broken as hell but kinda work the system wont detect it as the same message and keep spamming it needs a new message to override

File transfers arent encrypted needs to be worked on
