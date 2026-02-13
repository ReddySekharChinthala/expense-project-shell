#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo "Please enter DB password:"
read mysql_root_password

VALIDATE(){
   if [ $1 -ne 0 ]
   then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access."
    exit 1 # manually exit if error comes.
else
    echo "You are super user."
fi

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling default nodejs."

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabling nodejs"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing nodejs."

id expense &>>$LOGFILE
if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILE
    VALIDATE $? "Create Expense user"
else
    echo -e "Expense user already created. $Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGFILE
VALIDATE $? "Creating directory."

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading the code."

cd /app
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Extract the code"

npm install &>>$LOGFILE
VALIDATE $? "Installing nodejs dependencies"

cp /home/ec2-user/expense-project-shell /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "copy the backed configuration file"