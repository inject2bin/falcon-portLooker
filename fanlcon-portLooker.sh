#!/bin/bash
# only support ip address now

step=60
falcon_transfer="http://192.168.xx.xxx:1988/v1/push"

WORKSPACE=$(cd $(dirname $0)/; pwd)
itemList=`cat $WORKSPACE/item.list`
items=(
		$itemList
	)




function detect_port_stat()
{
	# receive 1 host ip and 1 port
	# return state:
	# 		0: closed
	# 		1: open
	#		2: port invalid
	if [ $2 -lt 0 -o $2 -gt 65535 ];then
		return 2
	fi
	state=`nmap -n -sS $1 -p $2 |grep open | wc -l`
	return $state
}


function push2_falcon()
{
	# tags example: "portNum=80,portlooker=stateCode"
	local metric='port_status'
	local endpoint=$hostip
	local tags="portNum="$port",portlooker=stateCode"

	detect_port_stat $hostip $port
	local value=$?
	local ts=`date +%s`


	curl -X POST -d "[{\"metric\": \"$metric\" , \"endpoint\": \"$endpoint\", \"timestamp\": $ts,\"step\": $step,\"value\": $value,\"counterType\": \"GAUGE\",\"tags\": \"$tags\"}]" $falcon_transfer
}


main()
{
	for item in ${items[*]}
	do
		hostip=`echo $item | cut -d: -f1`
		port=`echo $item | cut -d: -f2`

		push2_falcon
	done
}

main
