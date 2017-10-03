#/bin/bash

if (($# ==0 )) ;then 
    today=`date  -d "-1days" +%Y%m%d`
elif (( $# ==1 ));then
    today=$1
else
    echo "Parameter error." >&2
    echo "Usage:$0  beg_date " 1>&2
    exit 1
fi

function deletelog()
{
logmeta=$1
log=`echo $logmeta |awk -F, '{print $1}'`
saveday=`echo $logmeta |awk -F, '{print $2}'`
deletedate=`date -d "$today -${saveday}day" +%d`
deletemonth=`date -d "$today -${saveday}day" +%m`
deleteyear=`date -d "$today -${saveday}day" +%Y`
deletepath=`echo $log|sed -s "s/yyyy/${deleteyear}/g" |sed -s "s/MM/${deletemonth}/g" |sed -s "s/dd/${deletedate}/g"`
logsize=`hadoop fs -dus $deletepath  2>/dev/null |awk '{a+=$1}END{print a/1024/1024/1024}'  `
echo "Need Delete File Size is $logsize G "
if((logsize>0)) ; then 
echo "hadoop fs -rmr  $deletepath "
sudo -uwang hadoop fs -rmr  $deletepath
fi


}

cat logmeta |while read logmeta
do
deletelog $logmeta
done
