#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Please enter DB password"
read -s mysql_root_password

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 is..$R FAILURE $N"
        exit 1
    else
        echo -e "$2 is..$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run script with root access"
    exit 1
else
    echo "You are super user"
fi

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing MySQL_Server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling MySQL_Server"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting MySQL_Server"

#mysql_secure_installation --set-root-pass ExpenseApp@1
#VALIDATE $? "Setting up root password"

#Below code will use for idempotent in nature

mysql -h db.rsdevops17.online -uroot -p${mysql_root_password} -e 'showdatabases;' &>>$LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
    VALIDATE $? "Setting up root password"
else
    echo -e "MySQL root password already set $Y SKIPPING $N"
fi

