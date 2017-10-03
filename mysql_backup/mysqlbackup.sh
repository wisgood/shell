#!/bin/sh

USAGE="./mysqlbackup.sh <config_file>"

if [ $# -lt 1 ]
then
	echo $USAGE
	exit 1
fi

config_file=$1
today=`date +%Y%m%d`
std_today="${today:0:4}-${today:4:2}-${today:6:2} 00:00:00"
today_timestamp=`date -d "${std_today}" +%s`

function LOG() {
	echo "[`date +%Y%m%d-%H:%M:%S`] $@" >&2
}

function DIE() {
    LOG $@
    exit 1
}

cat $config_file | grep -v "^#" | while read ip port database username password local_days hdfs_days
do
	sql_gz_file=$database-$today.sql.gz

	# STEP 1: mysqldump to local
	local_dir_base=data/$ip/$database
	local_dir_today=$local_dir_base/$today
	LOG  "mysqldump to local start ($ip,$port,$database,$username,$password,$local_days,$hdfs_days)"
	mkdir -p $local_dir_today
	mysqldump -h$ip -P$port -u$username -p$password $database | gzip >$local_dir_today/$sql_gz_file
	[ ${PIPESTATUS[0]} -ne 0 ] && DIE "mysqldump to local failed"
	LOG "mysqldump to local succeed"

	# STEP 2: copy to hdfs
	hdfs_dir_base=/user/web_dp/mysqlbackup/$ip/$database
	hdfs_dir_today=$hdfs_dir_base/$today
	LOG  "copy to hdfs start ($hdfs_dir_today)"
	sudo -u web_dp hadoop fs -mkdir -p $hdfs_dir_today
	sudo -u web_dp hadoop fs -rm $hdfs_dir_today/$sql_gz_file
	sudo -u web_dp hadoop fs -copyFromLocal $local_dir_today/$sql_gz_file $hdfs_dir_today
	[ $? -ne 0 ] && DIE "copy to hdfs failed"
	LOG  "copy to hdfs succeed"

	# STEP3: clean local expired files
	for ymd in `ls $local_dir_base`
	do
		std_ymd="${ymd:0:4}-${ymd:4:2}-${ymd:6:2} 00:00:00"
		ymd_timestamp=`date -d "${std_ymd}" +%s`

		if [ $(($today_timestamp-$ymd_timestamp)) -ge $((3600*$local_days)) ]
		then
			LOG "delete local ($local_dir_base/$ymd)"
			rm -fr $local_dir_base/$ymd
			LOG "delete local succeed"
		fi
	done

	# STEP4: clean hdfs expired files
	hadoop fs -ls $hdfs_dir_base 2>/dev/null | grep -v Found | awk -F"/" '{print $NF}' | while read ymd
	do
		std_ymd="${ymd:0:4}-${ymd:4:2}-${ymd:6:2} 00:00:00"
		ymd_timestamp=`date -d "${std_ymd}" +%s`
		
		if [ $(($today_timestamp-$ymd_timestamp)) -ge $((3600*$hdfs_days)) ]
		then
			LOG "delete hdfs ($hdfs_dir_base/$ymd)"
			sudo -u web_dp hadoop fs -rm -f -r $hdfs_dir_base/$ymd
			[ $? -ne 0 ] && DIE "delete hdfs failed"
			LOG "delete hdfs succeed"
		fi
	done
done
