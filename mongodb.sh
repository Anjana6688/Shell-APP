#!/bin/bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGFOLDER="/var/log/shell-roboshop"
SCRIPTNAME=$( echo $0| cut -d "." -f1 )
LOG_FILE="$LOGFOLDER/$SCRIPTNAME.log" # /var/log/shell-roboshop/16-logs.log

mkdir -p $LOGFOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE



if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run this script with root privelege" | tee -a $LOG_FILE
    exit 1 # failure is other than 0
fi

VALIDATE(){ # functions receive inputs through args just like shell script args
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N"  | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
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

#Update listen address from 127.0.0.1 to 0.0.0.0 in /etc/mongod.conf
 sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Updating MongoDB listen address"

systemctl restart mongod
VALIDATE $? "Restarted MongoDB"