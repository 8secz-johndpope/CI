#!/bin/sh
# echo "===============s=================="
# python ./python/replaceEncResource.py "/Users/linguoqiang/Documents/work/iOS/CI"  "/Users/linguoqiang/Documents/work/iOS/hundsun_health"
# python ./python/recoverResource.py  "/Users/linguoqiang/Documents/work/iOS/hundsun_health"
# echo "===============e=================="

DIR="cd $( cd "$( dirname "$0"  )" && pwd  )"

$DIR

echo ${PWD}

declare local path=123

sed -i '' "s/pod 'hundsun_resouce', *:path =>'hundsun_resouce'/pod 'hundsun_resouce', :path =>'$path'/" $1

awk -F ':' '{print $0}' $1


