$URL = "https://name.sharepoint.com/sites/name/"
$EMAILADD = "Me@Agency.ca.gov"
$DMZUser = dmzuser

m365 spo listitem list --title "Server List" --webUrl $URL  -f Title,* > tmp

jq ".[] | .Id, .Title, .DMZ, .Retired" tmp | paste -s -d "   \n" - > tmp2

file="tmp2"


IFS=$'\n'

for Server in `cat $file`
do
   IFS=' '
   read -a info <<< $Server
   #echo ${info[0]}
   ServerIndex=${info[0]}
   DMZ=${info[2]}
   ServerName=`sed -e 's/^"//' -e 's/"$//' <<<${info[1]}   `
   Retired=${info[3]}

   if [ $Retired != "true" ]; then

     echo $ServerName


     if [ $DMZ == "true" ]; then
        CMD1="ssh $DMZUser@$ServerName "
     else
        CMD1="ssh $ServerName "
     fi

     CMD="$CMD1  yum list --installed > tmp3"

     #echo $CMD
     eval $CMD
     value=$(<tmp3)
     rm tmp3

     m365 spo listitem set --id $ServerIndex  --listTitle "Server List" --webUrl $URL  --YumLis$value"


     CMD="$CMD1 df -h > tmp3"
     eval $CMD
     value=$(<tmp3)
     rm tmp3

     m365 spo listitem set --id $ServerIndex  --listTitle "Server List" --webUrl $URL  --diskfiystems "$value"




     m365 spo listitem get --id $ServerIndex  --listTitle "Server List" --webUrl $URL  -p "*" >pPasswd1

     jq -r '.Users' tmpPasswd1 | sed 's/\\//g'  > tmpPasswdO
     tmpValue=$(<tmpPasswdO)
     echo -e $tmpValue > tmpPasswd10


     CMD="$CMD1 cat /etc/passwd > tmpPasswdC"
     eval $CMD
     value=$(<tmpPasswdC)


     m365 spo listitem set --id $ServerIndex  --listTitle "Server List" --webUrl $URL  --Users alue"


     m365 spo listitem get --id $ServerIndex  --listTitle "Server List" --webUrl $URL  -p "*" >pPasswd1

     jq -r '.Users' tmpPasswd1 | sed 's/\\//g'  > tmpPasswdO
     tmpValue=$(<tmpPasswdO)
     echo -e $tmpValue > tmpPasswd20

     diff tmpPasswd10 tmpPasswd20 > tmpPasswdDiff
     if [ $? -ne 0 ]; then
        if ! [ -s tmpPasswdDiff ]; then
           tmpValue=$(<tmpPasswdDiff)
           m365 outlook mail send --to $EMAILADD --subject "Passwd Change" --bodyContents "The passwd file has changed on $ServerName. \n  tmpswdDiff"
        fi
     fi

     CMD="$CMD1  sudo \"docker ps  --format 'table {{.Names}}\t{{.Image}}\\t{{.RunningFor}}\t{{.Ports}}'\" > tmp3"
#     CMD="$CMD1 sudo \"docker ps  --format 'table {{.Names}}\t{{.Image}}\\t{{.Status}}\t{{.Networks}}'\" > tmp3"
#     echo $CMD
     eval $CMD
     value=$(<tmp3)
     rm tmp3

     m365 spo listitem set --id $ServerIndex  --listTitle "Server List" --webUrl $URL  --Docker$value"


     CMD="$CMD1 sudo \"cat /etc/sudoers \" > tmp3"
#     echo $CMD
     eval $CMD
     value=$(<tmp3)
     rm tmp3

     m365 spo listitem set --id $ServerIndex  --listTitle "Server List" --webUrl $URL  --SUDOER$value"



     CMD="$CMD1  lscpu | grep ^CPU\(s\): | cut -d ':' -f 2 > tmp3"
#     echo $CMD
     eval $CMD
     value=$(<tmp3)
     rm tmp3
     #echo $value
     CMD="m365 spo listitem set --id $ServerIndex  --listTitle \"Server List\" --webUrl $URL  -u \" $value\"  "
     #echo $CMD
     eval $CMD



     CMD="$CMD1   lshw -c memory | grep size |  cut -d ':' -f 2 > tmp3"
#     echo $CMD
     eval $CMD
     value=$(<tmp3)
     rm tmp3
     #echo $value
     CMD="m365 spo listitem set --id $ServerIndex  --listTitle \"Server List\" --webUrl $URL  -gsofRam \" $value\"  "
     #echo $CMD
     eval $CMD

     value=`date -u`
     CMD="m365 spo listitem set --id $ServerIndex  --listTitle \"Server List\" --webUrl $URL  -anTime \" $value\"  "
     #echo $CMD
     eval $CMD


     CMD="$CMD1 hostname -I | sed 's/\s\+/\n/g'  > tmp3"
#     echo $CMD
     eval $CMD
     value=$(<tmp3)
     rm tmp3
     #echo $value
     CMD="m365 spo listitem set --id $ServerIndex  --listTitle \"Server List\" --webUrl $URL  -address \" $value\"  "
     #echo $CMD
     eval $CMD


     CMDT="[ -f /etc/systemd/system/oracle.service ] && echo \"Oracle\" || echo \"Not Oracle\" "
     CMD="$CMD1 \" $CMDT \"  > tmp3"
#     echo $CMD
     eval $CMD
     value=$(<tmp3)
     rm tmp3
     #echo $value
     CMD="m365 spo listitem set --id $ServerIndex  --listTitle \"Server List\" --webUrl $URL  -acle \" $value\"  "
     #echo $CMD
     eval $CMD



     CMDT="[ -f /etc/systemd/system/multi-user.target.wants/sophos-spl.service ] && echo \"Sophos\" || echo \"No Sophos\" "
     CMD="$CMD1 \" $CMDT \"  > tmp3"
#     echo $CMD
     eval $CMD
     value=$(<tmp3)
     rm tmp3
     #echo $value
     CMD="m365 spo listitem set --id $ServerIndex  --listTitle \"Server List\" --webUrl $URL  -phos \" $value\"  "
     #echo $CMD
     eval $CMD





#     echo "List Cronfiles:" > tmp3
#     CMD='$CMD1 "sudo ls /var/spool/cron/"  >> tmp3'
#     eval $CMD
#     echo "Root Crons:" >> tmp3
#     CMD='$CMD1 "sudo cat /var/spool/cron/root"  >> tmp3'
#     eval $CMD
#     echo "Oracle Crons" >> tmp3
#     CMD='$CMD1 "sudo cat /var/spool/cron/oracle"  >> tmp3'
#     eval $CMD

#     echo $CMD
#     value=$(<tmp3)
#     rm tmp3
     #echo $value
#     CMD="m365 spo listitem set --id $ServerIndex  --listTitle \"Server List\" --webUrl $URL  crontab \" $value\"  "
#     echo $CMD
#     eval $CMD



fi


done
