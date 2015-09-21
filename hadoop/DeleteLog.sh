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

TOTALSIZE=0

totalsize_atypia=0
sizenum=0
function delete_log_size()
{	
	size=`hadoop fs -du -s $1 2>/dev/null|egrep ${1:((${#1} - 8))} | awk '{print $1}' `
	sizenum=0
	if [ ! -n "$size" ]; 
	then 
	     echo "[WARNNING] GET NULL IN $1"
	     exit 1
	else 
		 sizenum=$size
	fi 
	#unit=${size:((${#size} - 1))}
    #sizenum=${size%*$unit*}
    #if [ "$unit" = "G" ]
    #then
    #    sizenum=$(echo "scale=8;$sizenum/1024" | bc -l)
    #elif [ "$unit" = "M" ]
    #then
    #    sizenum=$(echo "scale=8;$sizenum/1024/1024" | bc -l)
    #elif [ "$unit" = "K" ]
    #then
    #    sizenum=$(echo "scale=8;$sizenum/1024/1024/1024" | bc -l)
    #fi
}


function deletelog_atypia()
{
	logmeta=$1
	log=`echo $logmeta |awk -F, '{print $1}'`
	saveday=`echo $logmeta |awk -F, '{print $2}'`
	enddate=`date -d "$today -${saveday}day" +%s`
	line=`echo $log | egrep -o '/(.+)/'`
	echo "[INFO] DELETE DIR=${log} SAVE DAYS=${saveday} "
	filename_atypia="tmp${today}"
	hadoop fs -ls "$line" | egrep  '201[0-9]((-)?([0-9]{2})){2}' > $filename_atypia
	
	while read LINE
	do 
	day=`echo $LINE | awk '{print $8}'| egrep -o '201[0-9](-)?[0-1][0-9](-)?[0-3][0-9]' | uniq`
	currentdate=`date -d "${day}" +%s`
	if [ $currentdate -le $enddate ]
	then 
		deletedir=`echo "$LINE" | awk '{print $8}'` 
		delete_log_size $deletedir
		sizenum_atypia=$sizenum
		sizenum=0
		totalsize_atypia=$(echo "$totalsize_atypia+$sizenum_atypia" |bc -l)
		sudo -u han hadoop fs -rmr  $deletedir 2>/dev/null		
		echo "[DELETE LOG]:${deletedir} [LOG SIZE]:${sizenum_atypia} B [TOTAL SIZE]:${totalsize_atypia} B" 
	fi
	done < $filename_atypia
	totalsize_atypia=$(echo "scale=8;$totalsize_atypia/1024/1024/1024/1024" | bc -l)
	echo "[INFO] Delete logdir:$log completed! [TOTAL SIZE]:$totalsize_atypia TB"
	rm -rf $filename_atypia
}

function deletelog_standard()
{
	filename="dirfile${today}"
	sql="select  path,storeTime from LogMeta where state='RUN' and (path like '/logdata%' or path like '/storage%') and (jobQueueGroup like '%Distcp%' or jobQueueGroup like '%DTE-UploadLog%' ) and StoreTime<360"
	mysql -h10.12.136.185 -uroot -p123456 DataTransfer -e "$sql" >> $filename
	#data=`mysql -h10.12.136.185 -uroot -p123456 DataTransfer -e "$sql"`
	totalsize_standard=0
	sed -i '1d' $filename
	while read line
  	do
    	dir=`echo $line|awk '{print $1}'`
    	num=`echo $line|awk '{print $2}'`
	echo "[INFO] DELETE LOG=${dir} SAVEDAYS=${num}"
    	filecount=`hadoop fs -ls ${dir}/201* 2>/dev/null|wc -l`
    	if [ $filecount -ge $num ]
    	then
       	#echo $dir $filecount $[filecount-num]>>result2
       		enddate=`date -d "$today -${num}days" +%Y%m%d`
           	dateArray=`hadoop fs -ls ${dir}/*/ 2>/dev/null|egrep -o '201[0-9]{5}' `
           	for datedir in ${dateArray[*]}
               do
                   if [ $datedir -le $enddate ]
                   then
                        deldir=${dir}/${datedir:0:6}/${datedir}
			delete_log_size $deldir
			sizenum_standard=$sizenum
			sizenum=0
			totalsize_standard=$(echo "$totalsize_standard+$sizenum_standard" |bc -l)
            		sudo -u han hadoop fs -rmr  $deldir 2>/dev/null 
            		echo "[DELETE LOG]:$deldir [LOG SIZE]:${sizenum_standard} B [TOTAL SIZE]:${totalsize_standard} B"
                   fi
                done
       		#echo $line
			totalsize_standard=$(echo "scale=8;$totalsize_standard/1024/1024/1024/1024" | bc -l)
			echo "[INFO] Delete logdir:$dir completed! [TOTAL SIZE]:$totalsize_standard TB "
			TOTALSIZE=$(echo "$totalsize_standard+$TOTALSIZE" |bc -l)
			totalsize_standard=0
    	fi
  	done  < $filename
	rm -rf $filename
}

echo "*********************************************************************[INFO] Begin to delete logs in atypia*********************************************************************"
cat logmeta |while read logmeta
do
deletelog_atypia $logmeta
TOTALSIZE=$(echo "$totalsize_atypia+$TOTALSIZE" |bc -l)
totalsize_atypia=0
echo ""
done
echo "*********************************************************************[INFO] Begin to delete logs in standard*********************************************************************"
deletelog_standard
echo ""
echo ""
echo "*********************************************************************Deleted $TOTALSIZE TB in total in $today*********************************************************************"
