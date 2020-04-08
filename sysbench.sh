#/bin/sh
echo " "
echo "seqwr:顺序写（创建）"
echo " "
echo "seqrewr:顺序重写"
echo " "
echo "seqrd:顺序读"
echo " "
echo "rndrd:随机读"
echo " "
echo "rndwr:随机写"
echo " "
echo "rndrw:随机读写"
echo " "
# set fileio test mode from cli
MODE=$1
MODE_ECHO=""
# set r/w line by mode
LINE_R=0
if [[ $MODE == 'seqwr' ]];then
	MODE_ECHO="顺序写（创建）"
	LINE_R=21
elif [[ $MODE == 'seqrewr' ]];then
	MODE_ECHO="顺序重写"
	LINE_R=21
elif [[ $MODE == 'seqrd' ]];then
	MODE_ECHO="顺序读"
	LINE_R=21
elif [[ $MODE == 'rndrd' ]];then
	MODE_ECHO="随机读"
	LINE_R=23
elif [[ $MODE == 'rndwr' ]];then
	MODE_ECHO="随机写"
	LINE_R=23
elif [[ $MODE == 'rndrw' ]];then
	MODE_ECHO="随机读写"
	LINE_R=23
fi
LINE_W=$(($LINE_R + 1))

# set test count
COUNT=$2
# set test flages
FLAGES="--file-num=1 --file-total-size=100M --file-io-mode=async --file-extra-flags=direct --file-fsync-freq=0 --file-rw-ratio=1 --file-test-mode=$MODE"
echo "Test mode:"$MODE_ECHO",Test count:"$COUNT
echo " "
# Record total time and MiB/sec for create file
TotalTime=0
TotalMiB=0
# Record total IOPS and MB/s for r(23 line)/w(24 line) in test
TotalIOPS_R=0
TotalIOPS_W=0
TotalMB_R=0
TotalMB_W=0

for n in $(seq 1 $COUNT)
do
    # result file
    rf='r'$n'.log'
    #gone time file for create test file 
    tf='t'$n'.log'
    
    echo "Create test file$n ......"
	sysbench fileio $FLAGES prepare > ./$tf
	# MiB need to ignore '(' char at 0 index	
	mib=$(cat $tf | awk 'NR==7 {print $7}')	
	TotalMiB=$(echo "$TotalMiB+${mib:1}"|bc)
	TotalTime=$(echo "$TotalTime+$(cat $tf | awk 'NR==7 {print $5}')"|bc)
	
	echo "Run test$n ......"
    sysbench fileio $FLAGES run > ./$rf
    # IOPS need to ignore "IOPS=" string until 5th index
    # Note: line="$LINE_R" is used to get LINE_R and set NR
    iopsR=$(cat $rf | awk 'NR==line {print $2}' line="$LINE_R")
	iopsW=$(cat $rf | awk 'NR==line {print $2}' line="$LINE_W")
	echo "iopsR:$iopsR"
	echo "iopsW:$iopsW"
	TotalIOPS_R=$(echo "$TotalIOPS_R+${iopsR:5}"|bc)
	TotalIOPS_W=$(echo "$TotalIOPS_W+${iopsW:5}"|bc)
	# MB need to ignore '(' char at 0 index
	mbR=$(cat $rf | awk 'NR==line {print $5}' line="$LINE_R")
	mbW=$(cat $rf | awk 'NR==line {print $5}' line="$LINE_W")
	echo "mbR:$mbR"
	echo "mbW:$mbW"
	TotalMB_R=$(echo "$TotalMB_R+${mbR:1}"|bc)
	TotalMB_W=$(echo "$TotalMB_W+${mbW:1}"|bc)
	
    sysbench fileio $FLAGES cleanup > ./clean.log
done
echo " "
echo "$MODE_ECHO tests results:"
echo "AVRTime for create $COUNT test files is:$(awk 'BEGIN{printf "%.3f\n",'$TotalTime'/'$COUNT'}') seconds."
echo "AVRMiB for create $COUNT test files is:$(awk 'BEGIN{printf "%.3f\n",'$TotalMiB'/'$COUNT'}') MiB/sec."

echo "AVRIOPS_R for $COUNT tests is:$(awk 'BEGIN{printf "%.3f\n",'$TotalIOPS_R'/'$COUNT'}')(Read IOPS)."
echo "AVRIOPS_W for $COUNT tests is:$(awk 'BEGIN{printf "%.3f\n",'$TotalIOPS_W'/'$COUNT'}')(Write IOPS)."
echo "AVRMB_R for $COUNT tests is:$(awk 'BEGIN{printf "%.3f\n",'$TotalMB_R'/'$COUNT'}') MB/s(Read)."
echo "AVRMB_W for $COUNT tests is:$(awk 'BEGIN{printf "%.3f\n",'$TotalMB_W'/'$COUNT'}') MB/s(Write)."

# clean files
# rm ./*.log
	
