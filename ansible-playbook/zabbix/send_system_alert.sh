#!/bin/env sh

to=$1
subject=$2
body=$3

/usr/local/bin/sendEmail -f fate1028@163.com -t "$to" -u "$subject" -s smtp.163.com -o message-content-type=html -o message-charset=utf-8 -xu fate1028@163.com -xp PASSWD -m "$body" >> /tmp/send_mail.log 2>&1

~
