#!/bin/sh
declare global_var_temp="tmp"
declare global_var_payload="Payload"
declare global_var_output="Build"
declare global_var_resource="Resource"
declare global_var_provision="ProvisionProfile"

declare global_var_configration_path
declare global_var_provision_output_path
declare global_var_temp_output_path
declare global_var_output_path
declare global_var_resources_path

declare APP
declare FRAMEWORK
declare APP_PLIGIN
declare WATCH
declare WATCH_PLUGIN

# function ergodic() { 
# 	local var_dest_path=$1
# 	local var_source_path=$2
# 	local var_temp_path=$3

# 	if [ ! -d $var_dest_path ]
#       then
#       echo "目的文件夹不存在！"
#       exit
#     fi

#     if [ ! -d $var_temp_path ]
#     	then
#     	mkdir $var_temp_path
#     fi

# 	for file in `ls $var_source_path`  
# 	do  
# 		if [ -d $var_source_path"/"$file ]  
# 	    	then  
# 	      	ergodic $var_source_path"/"$file $var_source_path $var_temp_path
# 	    	else  
# 	      	local path=$var_source_path"/"$file 
# 	      	local fullname=$(basename $path)
# 	      	local filename=${fullname%.*}
# 	      	local extension=${fullname##*.}
	      	
# 	      	if [ "$extension" = "json" ]
# 	      		then
# 	      		echo "加密$fullname"
# 	      		cp -f $path $var_temp_path/$fullname
# 	      		python encrypt.py $var_temp_path/$fullname "HSYT_C_K"
# 	      		cp -f $var_temp_path/$fullname $var_dest_path
# 	      		continue
# 	      	fi 

# 	      	if [ "$extension" = "pem" ]
# 	      		then
# 	      		echo "加密$fullname"
# 	      		cp -f $path $var_temp_path/$fullname
# 	      		python encrypt.py $var_temp_path/$fullname "hsyuntai.com"
# 	      		cp -f $var_temp_path/$fullname $var_dest_path
# 	      		continue
# 	      	fi 
# 	      	cp -f $path $var_dest_path
#     	fi  
# 	done 
# }