#!/bin/bash
if [ "$EUID" -ne 0 ]
then echo "Please run as root"
    exit
fi
echo "Greetings..." > /tmp/log1.dat
name="Offline";
detectStatus () {
  stat=`screen -ls | grep user | cut -d. -f1 | awk '{print $1}'`
  re='^[0-9]+$'
  if [[ $stat =~ $re ]] ; then
    name="Online"
  fi
}
banner() {
echo ".▄▄ · ▄▄▄ . ▄▄· ▄• ▄▌▄▄▄  ▄▄▄ .     ▄▄· ▄▄▌  ▪  ▄▄▄ . ▐ ▄ ▄▄▄▄▄"
echo "▐█ ▀. ▀▄.▀·▐█ ▌▪█▪██▌▀▄ █·▀▄.▀·    ▐█ ▌▪██•  ██ ▀▄.▀·•█▌▐█•██  "
echo "▄▀▀▀█▄▐▀▀▪▄██ ▄▄█▌▐█▌▐▀▀▄ ▐▀▀▪▄    ██ ▄▄██▪  ▐█·▐▀▀▪▄▐█▐▐▌ ▐█.▪"
echo "▐█▄▪▐█▐█▄▄▌▐███▌▐█▄█▌▐█•█▌▐█▄▄▌    ▐███▌▐█▌▐▌▐█▌▐█▄▄▌██▐█▌ ▐█▌·"
echo " ▀▀▀▀  ▀▀▀ ·▀▀▀  ▀▀▀ .▀  ▀ ▀▀▀     ·▀▀▀ .▀▀▀ ▀▀▀ ▀▀▀ ▀▀ █▪ ▀▀▀ "
  echo "Exit: !quit    Clear Screen: !clear    Start Services: !start    Stop Services: !stop     Exec Sys CMD: !exec command"
}
banner
run () {
  service httpd start 2> /dev/null
  service apache2 start 2> /dev/null
  screen -dmS user1
  screen -dmS user2
  screen -S user1 -p 0 -X stuff 'while true; do nc -lv 5555; done\n'
  echo "Now Listening on 0.0.0.0:5555" >> /tmp/log1.dat
  screen -S user2 -p 0 -X stuff 'while true; do nc -lv 5556; done\n'
  echo "Now Listening on 0.0.0.0:5556" >> /tmp/log1.dat
  service vsftpd start
  echo "Now Listening on 0.0.0.0:34812" >> /tmp/log1.dat
}
stop () {
  screen -ls | grep user2 | cut -d. -f1 | awk '{print $1}' | xargs kill 2> /dev/null
  screen -ls | grep user1 | cut -d. -f1 | awk '{print $1}' | xargs kill 2> /dev/null
  service vsftpd stop
  name="Offline"
}
getMSG() {
    msgs=`tail -$size1 /tmp/log1.dat`
    printf "$msgs"
}
commandProc () {
    if [ "$msg" == "!quit" ]; then
        echo "Quitting"
        stty echo
        tput cnorm
        clear
        exit 1
    elif [ "$msg" == "!clear" ]; then
        sudo rm /tmp/log1.dat
        sudo touch /tmp/log1.dat
        clear
    elif [ "$msg" == "!banner" ]; then
        banner
        clear
    elif [ "$msg" == "!start" ]; then
        echo "Starting Services..." >> /tmp/log1.dat
        run
    elif [ "$msg" == "!stop" ]; then
        echo "Stopping Services..." >> /tmp/log1.dat
        stop
    elif [ "$msg" == "\n" ]; then
        banner
    elif [ "$msg" == " " ]; then
        banner
    elif [ "$msg" == "" ]; then
        banner
    elif [[ $msg = !exec* ]]; then
	echo "\033[0;32mExecuting...\033[1;31m" >> /tmp/log1.dat
        (cmd=${msg#?};
        res=`$cmd`;
        echo "\033[1;34m$res\033[1;31m" >> /tmp/log1.dat) &
    else
        echo "Error: Command Not Found: $msg" >> /tmp/log1.dat
    fi
}
math() {
  i="0"
  calc=""
  calcside=""
  msgboxcharbefore=${#msg}-4
  msgboxcharafter=$columns-$msgboxcharbefore
  while [[ $i -lt $columns ]]
  do
    calc2="═"
    calc="$calc$calc2"
    i=$[$i+1]
  done
  i="1"
  while [[ $i -lt $msgboxcharafter ]]
  do
    calcside2=" "
    calcside="$calcside$calcside2"
    i=$[$i+1]
  done
  fixchat=""
  cnt1=`grep -c '' /tmp/log1.dat`
  cnt=`expr $cnt1 + 1`
  if [[ $size1 -gt $cnt ]]; then
    i=`expr $cnt + 1`
    j=$i
    while [[ $i -lt $size1 ]]
    do
      fixchat2="\n"
      fixchat="$fixchat$fixchat2"
      i=$[$i+1]
    done
  fi
}
doMSG () {
  output3=$(getMSG)
  l=`expr 0 + 21 + ${#name}`
  printf "\033[1;31mServices: $name\033[0m"; while [[ $columns -gt l ]]; do printf " "; l=$[$l+1]; done; printf "\033[1;34m" ;date +"%r"
  printf "\033[1;31m$calc══"
  echo "$output3"
  printf "\033[1;31m"
  printf "$fixchat"
  printf "\n\n"
  stty echo
  printf "╔$calc"
  printf "╗"
  #printf %"$COLUMNS"s |tr " " "═"
  printf "\n"
}
view () {
    while true
    do
        detectStatus
        tput civis
        stty -echo
        size=`tput lines`
        columns=`tput cols`
        columns=$[$columns-2]
        size1="$(($size-11))"
        math
        output1=$(banner)
        output2=$(doMSG)
        clear
        echo "$output1"
        echo "$output2"
        read -t 0.03 -s -N 1 -p "║ ->> $msg$calcside║
╚$calc╝" msg1
        stty -echo
        msg2=`printf '%q\n' "$msg1"`
        if [[ $msg2 == *"\n"* ]]; then
            commandProc
            msg=""
        elif [[ $msg2 == *"\177"* ]]; then
            msg=`echo ${msg:0:$((${#msg}-1))}`
        else
            msg="$msg$msg1"
        fi
    done
}
if [ "$1" == "info" ]; then
    echo "This is the greatest and safest communication we have to offer."
    echo "Warnings: DO NOT LEAK API KEY!"
elif [ "$1" == "start" ]; then
    echo "Starting Services..."
    run
elif [ "$1" == "stop" ]; then
    echo "Stopping Services..."
    stop
elif [ "$1" == "view" ]; then
    view
elif [ "$1" == "install" ]; then
    sudo apt update -y && sudo apt upgrade -y
    sudo mv clientbanner /usr/bin/clientbanner
    sudo apt install netcat-openbsd -y
    sudo apt install apache2 -y
    sudo apt install php -y
    sudo apt install vsftpd -y
    mv crypto.php /var/www/html
    echo "set ssl:verify-certificate no" >> ~/.lftprc
    echo "MAKE SURE YOU HAVE DONE EVERYTHING IN THE TUT BEFORE CONTINUING!!"
    exit 1
else
    echo "Please specify 'install', 'start', 'stop', 'view' or 'info' example: $0 run"
fi
