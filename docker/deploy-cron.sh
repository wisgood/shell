#/bin/bash


cd /search/sogou-code/jobqueueservice  

#mvn clean package 

ssh  root@earthnn0101.clouddev.sjs.nop.vm.sogou-op.org  ' cd /search && sh -x kill.sh  && exit  '
scp  /search/sogou-code/jobqueueservice/JobCenter/target/JobCenter-0.0.2.jar root@earthnn0101.clouddev.sjs.nop.vm.sogou-op.org:/search/sogou/crontask-jobcenter/lib/JobCenter-0.0.2.jar
scp  /search/sogou-code/jobqueueservice/TaskCenter/target/TaskCenter-1.1.5.jar root@earthnn0101.clouddev.sjs.nop.vm.sogou-op.org:/search/sogou/crontask-jobcenter/lib/TaskCenter-1.1.5.jar
scp  /search/sogou-code/jobqueueservice/common/target/common-0.0.2.jar  root@earthnn0101.clouddev.sjs.nop.vm.sogou-op.org:/search/sogou/crontask-jobcenter/lib/common-0.0.2.jar
scp  /search/sogou-code/jobqueueservice/JqsMaster/target/JobQueueMaster-0.0.2-bin/JobQueueMaster-0.0.2/lib/commons-cli-1.2.jar  root@earthnn0101.clouddev.sjs.nop.vm.sogou-op.org:/search/sogou/crontask-jobcenter/lib/commons-cli-1.2.jar 


scp /search/sogou-code/distributed-docker-submit-project/distributed-docker-submit-server/target/lib/distributed-docker-submit-client-0.0.1-SNAPSHOT.jar root@earthnn0101.clouddev.sjs.nop.vm.sogou-op.org:/search/sogou/crontask-jobcenter/lib/
scp /search/repository/distributed-docker-submit-server/distributed-docker-submit-server/0.0.1-SNAPSHOT/distributed-docker-submit-server-0.0.1-SNAPSHOT.jar root@earthnn0101.clouddev.sjs.nop.vm.sogou-op.org:/search/sogou/crontask-jobcenter/lib/
scp /search/sogou-code/distributed-docker-submit-project/distributed-docker-appmaster/target/distributed-docker-appmaster-0.0.1-SNAPSHOT-jar-with-dependencies.jar root@earthnn0101.clouddev.sjs.nop.vm.sogou-op.org:/search/sogou/crontask-jobcenter/lib/
#scp /search/sogou-code/distributed-docker-submit-project/distributed-docker-appmaster/target/distributed-docker-appmaster-0.0.1-SNAPSHOT.jar root@earthnn0101.clouddev.sjs.nop.vm.sogou-op.org:/search/sogou/crontask-jobcenter/lib/
scp /usr/lib/hadoop-yarn/hadoop-yarn-client-2.5.0-cdh5.3.2.jar root@earthnn0101.clouddev.sjs.nop.vm.sogou-op.org:/search/sogou/crontask-jobcenter/lib/
scp /usr/lib/hadoop-yarn/hadoop-yarn-common-2.5.0-cdh5.3.2.jar root@earthnn0101.clouddev.sjs.nop.vm.sogou-op.org:/search/sogou/crontask-jobcenter/lib/
scp /usr/lib/hadoop-yarn/hadoop-yarn-api.jar root@earthnn0101.clouddev.sjs.nop.vm.sogou-op.org:/search/sogou/crontask-jobcenter/lib/
scp /usr/lib/hadoop/hadoop-common-2.5.0-cdh5.3.2.jar root@earthnn0101.clouddev.sjs.nop.vm.sogou-op.org:/search/sogou/crontask-jobcenter/lib/
scp /usr/lib/hadoop/lib/commons-collections-3.2.1.jar root@earthnn0101.clouddev.sjs.nop.vm.sogou-op.org:/search/sogou/crontask-jobcenter/lib/
scp /usr/lib/hadoop/hadoop-auth-2.5.0-cdh5.3.2.jar root@earthnn0101.clouddev.sjs.nop.vm.sogou-op.org:/search/sogou/crontask-jobcenter/lib/
scp /usr/lib/hadoop/lib/protobuf-java-2.5.0.jar  root@earthnn0101.clouddev.sjs.nop.vm.sogou-op.org:/search/sogou/crontask-jobcenter/lib/
scp /search/sogou-code/jobqueueservice/TaskCenter/conf/jobcenter.properties   root@earthnn0101.clouddev.sjs.nop.vm.sogou-op.org:/search/sogou/crontask-jobcenter/conf/jobcenter.properties 

ssh  root@earthnn0101.clouddev.sjs.nop.vm.sogou-op.org  service jobcenter start && exit 
