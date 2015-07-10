#!/bin/sh

auto_ssh_copy_id() {
  local HOST=$1
  local PASSWD=$2
  expect -c "set timeout -1;
    spawn ssh-copy-id root@$HOST
    expect {
      *publickey* {exit 1;}
      *(yes/no)* {send yes\r; exp_continue;}
      *password* {send \"$PASSWD\r\"; exp_continue;}
      *ÃÜÂë* {send \"$PASSWD\r\"; exp_continue;}
    }";
}

      #eof {exit 0;}
passwd1='noSafeNoWork@2014'
passwd2='SafetyFirst@426'
passwd3='Sogou-RD@2008'
passwd4='123456'
passwd5='asdasd'
passwd6='12345'
while read line; do
  echo "$line" >&2
  isSucceed='FALSE'
  for pw in $passwd1 $passwd2 $passwd3 $passwd4 $passwd5 $passwd6
  do
    if auto_ssh_copy_id "$line" $pw
    then
	isSucceed='TRUE'
	break;
    fi
  done

  if [ $isSucceed != 'TRUE' ]; then
    echo 'NOTSUCC' $line
  fi
done 
