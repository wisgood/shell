#!/bin/sh

auto_ssh_copy_id() {
  local HOST=$1
  expect -c "set timeout -1;
    spawn ssh-copy-id -i /root/.ssh/id_rsa.pub root@$HOST
    expect {
      *(yes/no)* {send yes\r; exp_continue;}
      *password* {send \"noSafeNoWork@2014\r\"; exp_continue;}
      *√‹¬Î* {send \"sunshineNM!Dog\r\"; exp_continue;}
      eof {exit 0;}
    }";
}

rsyn_hosts() {
  local HOST=$1
  expect -c "set timeout -1;
    spawn rsync -rl /etc/hosts $HOST:/etc/
    expect {
      *(yes/no)* {send yes\r; exp_continue;}
      *password* {send \"noSafeNoWork@2014\r\"; exp_continue;}
      *√‹¬Î* {send \"sunshineNM!Dog\r\"; exp_continue;}
      eof {exit 0;}
    }";
}
rsync_ssh() {
  local HOST=$1
  expect -c "set timeout -1;
    spawn rsync -rl /root/.ssh $HOST:/root/
    expect {
      *(yes/no)* {send yes\r; exp_continue;}
      *password* {send \"noSafeNoWork@2014\r\"; exp_continue;}
      *√‹¬Î* {send \"sunshineNM!Dog\r\"; exp_continue;}
      eof {exit 0;}
    }";
}

query_hadoop() {
  local HOST=$1
  expect -c "set timeout -1;
    spawn ssh $HOST rpm -qa hadoop
    expect {
      *(yes/no)* {send yes\r; exp_continue;}
      *password* {send \"noSafeNoWork@2014\r\"; exp_continue;}
      *√‹¬Î* {send \"sunshineNM!Dog\r\"; exp_continue;}
      eof {exit 0;}
    }";
}

set_hostname() {
  local HOST=$1
  expect -c "set timeout -1;
    spawn ssh $HOST hostname $HOST
    expect {
      *(yes/no)* {send yes\r; exp_continue;}
      *password* {send \"noSafeNoWork@2014\r\"; exp_continue;}
      *√‹¬Î* {send \"sunshineNM!Dog\r\"; exp_continue;}
      eof {exit 0;}
    }";
}
copy_repo1() {
  local HOST=$1
  expect -c "set timeout -1;
    spawn rsync -rl /etc/yum.repos.d/sogou-ws-gym.repo root@$HOST:/etc/yum.repos.d/
    expect {
      *(yes/no)* {send yes\r; exp_continue;}
      *password* {send \"noSafeNoWork@2014\r\"; exp_continue;}
      *√‹¬Î* {send \"sunshineNM!Dog\r\"; exp_continue;}
      eof {exit 0;}
    }";
}
copy_repo2() {
  local HOST=$1
  expect -c "set timeout -1;
    spawn rsync -rl /etc/yum.repos.d/sogou-ws-cdh5.3.2.repo root@$HOST:/etc/yum.repos.d/
    expect {
      *(yes/no)* {send yes\r; exp_continue;}
      *password* {send \"noSafeNoWork@2014\r\"; exp_continue;}
      *√‹¬Î* {send \"sunshineNM!Dog\r\"; exp_continue;}
      eof {exit 0;}
    }";
}

while read line; do
  echo "$line"
  auto_ssh_copy_id $line
  rsyn_hosts $line
  rsync_ssh $line
  query_hadoop $line
  set_hostname $line
  copy_repo1 $line
  copy_repo2 $line
done 
