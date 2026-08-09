#!/bin/bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGFOLDER="/var/log/Install"
SCRIPTNAME=$( echo $0| cut -d "." -f1 )
LOGFILE="$LOGFOLDER/$SCRIPTNAME.log" # /var/log/Install/16-logs.log

mkdir -p $LOGFOLDER
echo "Script started executed at: $(date)" | tee -a $LOGFILE



if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run this script with root privelege" | tee -a $LOGFILE
    exit 1 # failure is other than 0
fi

VALIDATE(){ # functions receive inputs through args just like shell script args
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N"  | tee -a $LOGFILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGFILE
    fi
}
cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding Mongo repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing MongoDB"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enable MongoDB"

systemctl start mongod 
VALIDATE $? "Start MongoDB"

