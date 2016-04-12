#!/bin/env bash
#Function:根据传递参数的熟练来进行判断获取值得层级
 
#echo "db.serverStatus().uptime"|mongo 192.168.5.23:30002/admin
#echo "db.serverStatus().mem.mapped"|mongo 192.168.5.23:30002/admin
#echo "db.serverStatus().globalLock.activeClients.total"|mongo 192.168.5.23:30002/admin
port=27017 
 
case $# in
  1)
    output=$(/bin/echo "db.serverStatus().$1" |/data/app_platform/mongodb/bin/mongo admin --port $port|sed -n '3p')
    ;;
  2)
    output=$(/bin/echo "db.serverStatus().$1.$2" |/data/app_platform/mongodb/bin/mongo admin --port $port|sed -n '3p')
    ;;
  3)
    output=$(/bin/echo "db.serverStatus().$1.$2.$3" |/data/app_platform/mongodb/bin/mongo admin --port $port|sed -n '3p')
    ;;
esac
 
#check if the output contains "NumberLong"
if [[ "$output" =~ "NumberLong"   ]];then
  echo $output|sed -n 's/NumberLong(//p'|sed -n 's/)//p'
else 
  echo $output
fi
