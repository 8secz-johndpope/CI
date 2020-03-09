#!/bin/sh

IFS=$'\n'

function func_codesign() {
	echo "开始签名......"
	local var_app_path=$1
	local var_sign_indentify=$2

	echo $1, $2
	if [ ! -d $var_app_path ]
		then
		echo "app文件不存在！"
		exit -1
	fi

	local var_framework_path=$var_app_path/Frameworks
	if [ -e $var_framework_path ]
	then
	  	list=`find $var_framework_path -maxdepth 1 -name "*.framework"`
		for i in $list
	    do
	    	codesign -f -s ${var_sign_indentify} $i
	    done
	fi

	local var_watch_plugin_path=$var_app_path/Watch/$WATCH/PlugIns
	if [ -e $var_watch_plugin_path ]
	then
		list=`find $var_watch_plugin_path -maxdepth 1 -name "*.appex"`
		for i in $list
		do
			codesign -f -s ${var_sign_indentify} $i
		done
	fi

	local var_watch_path=$var_app_path/Watch
	if [ -e $var_watch_path ]
	then
	  	list=`find $var_watch_path -maxdepth 1 -name "*.app"`
		for i in $list
		do
			codesign -f -s ${var_sign_indentify} $i
		done
	fi

	local var_app_plugin_path=$var_app_path/PlugIns
	if [ -e $var_app_plugin_path ]
	then
	    list=`find $var_app_plugin_path -maxdepth 1 -name "*.appex"`
		for i in $list
		do
			codesign -f -s ${var_sign_indentify} $i
		done
	fi

	if [ -e $var_app_path ]
	then
	    list=`find $var_app_path -maxdepth 1 -name "*.app"`
		for i in $list
		do
			codesign -f -s ${var_sign_indentify} --entitlements $global_var_temp_output_path/Entitlements.plist $i
		done
	fi
}

function verify() {
	name=$(basename $1)
	name=$1

	#spctl --ignore-cache --no-cache --assess --type execute --verbose=4 Payload/*.app
	# codesign --verify --deep --display --verbose=4 "$app"
	CSVINFO=`codesign --verify --deep $1`
	# echo $CSVINFO
	if  [ `echo $CSVINFO|wc -c` -gt 0 ]
	then
		echo "$name: resign successfully"
	else
	   	echo "$name: resign failed"
	    exit -1;
	fi

	spctl --ignore-cache --no-cache --assess --type execute --verbose=4 "$1"
}

function func_verify() {

	echo "开始验签......"
	local var_app_path=$1

	if [ -e $var_app_path/Frameworks ]
	then
	  	list=`find $var_app_path/Frameworks -maxdepth 1 -name "*.framework"`
		for i in $list
	    do
	    	verify $i
	    done
	fi

	if [ -e $var_app_path/Watch/$WATCH/PlugIns ]
	then
		## 解决读取文件名含有空格时无法正确识别问题
		# OIFS="$IFS"
		# IFS=$'\n'
	    list=`find $var_app_path/Watch/$WATCH/PlugIns -name '*.appex'`
		for i in $list
	    do
	    	verify $i
	    done
	fi

	if [ -e $var_app_path/Watch ]
	then
	    list=`find $var_app_path/Watch -maxdepth 1 -name "*.app"`
		for i in $list
	    do
	    	verify $i
	    done
	fi

	if [ -e $var_app_path/PlugIns ]
	then
	    list=`find $var_app_path/PlugIns -maxdepth 1 -name "*.appex"`
		for i in $list
	    do
	    	verify $i
	    done
	fi

	if [ -e $var_app_path ]
	then
	    list=`find $var_app_path -maxdepth 1 -name "*.app"`
		for i in $list
	    do
	    	verify $i
	    done
	fi
}

