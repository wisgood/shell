#!/bin/bash


for i in `cat $1`
do
ip=$(echo "$i"|cut -f1 -d":")
echo $ip
scp  $2 root@$ip:$3
done
