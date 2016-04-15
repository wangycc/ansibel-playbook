#!/bin/env sh

to=$1
subject=$2
body=$3

content=${subject}
from="robot@octinn.com"

apiurl="http://api.sendcloud.net/apiv2/mail/sendtemplate"
mailcmd="apiUser=birthday_account&apiKey=Ze9No4DGun7atgOv&from=${from}&replyTo=${to}&templateInvokeName=zabbix_alert"
xsmtpapi="xsmtpapi={\"to\":[\"${to}\"],\"sub\":{\"%title%\":[\"${subject}\"],\"%content%\":[\"${body}\"]}}"

#echo curl -d \'${mailcmd}\' --data-urlencode \'${xsmtpapi}\' \"${apiurl}\"
curl -d "${mailcmd}" --data-urlencode "${xsmtpapi}" "${apiurl}"

