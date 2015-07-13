#!/bin/sh

if (($# == 0)); then
	today=`date  -d "-1days" +%Y%m%d`
elif (( $# ==1 ));then
    today=$1
else
    echo "Parameter error." >&2
    echo "Usage:$0  beg_date " 1>&2
    exit 1
fi

totalsize_atypia=0
sizenum=0
function delete_log_size()
{	
	size=`hadoop fs -du -s -h $1 2>/dev/null|egrep ${1:((${#1} - 8))} | awk '{print $1$2}' `
    unit=${size:((${#size} - 1))}
    sizenum=${size%*$unit*}
    if [ "$unit" = "G" ]
    then
        sizenum=$(echo "scale=8;$sizenum/1024" | bc -l)
    elif [ "$unit" = "M" ]
    then
        sizenum=$(echo "scale=8;$sizenum/1024/1024" | bc -l)
    elif [ "$unit" = "K" ]
    then
        sizenum=$(echo "scale=8;$sizenum/1024/1024/1024" | bc -l)
    fi
}


function deletelog_atypia()
{
	logmeta=$1
	log=`echo $logmeta |awk -F, '{print $1}'`
	saveday=`echo $logmeta |awk -F, '{print $2}'`
	enddate=`date -d "$today -${saveday}day" +%s`
	line=`echo $log | egrep -o '/(.+)/'`
	echo "$line"
	filename=tmp
	hadoop fs -ls "$line" | egrep  '201[0-9]((-)?([0-9]{2})){2}' > $filename
	
	while read LINE
	do 
	day=`echo $LINE | awk '{print $8}'| egrep -o '201[0-9]((-)?([0-9]{2})){2}'`
	currentdate=`date -d "${day}" +%s`
	if [ $currentdate -ge $enddate ]
	then 
		deletedir=`echo $LINE | awk '{print $8}'`
		delete_log_size $deletedir
		sizenum_atypia=$sizenum
		sizenum=0
		totalsize_atypia=$(echo "$totalsize_atypia+$sizenum_atypia" |bc -l)
		#hadoop fs -rmr $deletedir.......		
		echo "[DELETE LOG]:$deletedir [LOG SIZE]:$sizenum_atypia [TOTAL SIZE]:$totalsize_atypia" 
	fi
	done < $filename
}

function deletelog_standard()
{
	sql="select  path,storeTime from LogMeta where state='RUN' and (path like '/logdata%' or path like '/storage%') and  jobQueueGroup like '%Distcp%' and StoreTime<360"
	mysql -h10.12.136.185 -uroot -p123456 DataTransfer -e "$sql" >>dirfile
	#data=`mysql -h10.12.136.185 -uroot -p123456 DataTransfer -e "$sql"`
	filename=dirfile
	totalsize_standard=0
	sed -i '1d' $filename
	while read line
  	do
    	#echo $line
    	dir=`echo $line|awk '{print $1}'`
    	num=`echo $line|awk '{print $2}'`
    	filecount=`hadoop fs -ls ${dir}/201* 2>/dev/null|wc -l`
    	if [ $filecount -ge $num ]
    	then
       	#echo $dir $filecount $[filecount-num]>>result2
       		enddate=`date -d -${num}days +%Y%m%d`
           	dateArray=`hadoop fs -ls ${dir}*/ 2>/dev/null|egrep -o '201[0-9]{5}' `
           	for datedir in ${dateArray[*]}
               do
                   if [ $datedir -le $enddate ]
                   then
                        deldir=${dir}/${datedir:0:6}/${datedir}
						delete_log_size $deldir
						sizenum_standard=$sizenum
						sizenum=0
						totalsize_standard=$(echo "$totalsize_standard+$sizenum_standard" |bc -l)
            			#hadoop fs -rmr -skipTrash $deldir 2>/dev/null 
            			echo "[DELETE LOG]:$deldir [LOG SIZE]:$sizenum_standard [TOTAL SIZE]:$totalsize_standard"
                   fi
                done
       	#echo $line
    	fi
  	done  < $filename
	echo $totalsize
	#rm -f $filename
}

#echo "[INFO] Begin to delete logs in atypia"
#cat logmeta |while read logmeta
#do
#deletelog_atypia $logmeta
#done
echo "[INFO] Begin to delete logs in standard"
deletelog_standard

