#!/bin/sh


# source $HOME/Desktop/工作/iOS/CI/common.sh

# find_ipa_path_with_extension $1

# find_ipa_path_with_filename $1 $2

# func_read_configfile $1
declare global_var_ipa_path_array

function func_loop_search_ipa_file() {

	local var_search_path=$1
	if [ ! -d $var_search_path ]
		then
		echo "输入的文件夹不存在！"
		exit -1
	fi

	for file in `ls $var_search_path`  
	do  
		if [ -f $var_search_path"/"$file ]
			then
			local path=$var_search_path"/"$file 
      		local fullname=$(basename $path)
      		local filename=${fullname%.*}
      		local extension=${fullname##*.}
	      	if [ "$extension" = "ipa" ]
	      		then
	      		global_var_ipa_path_array+=("$path")
	      	fi 
		elif [ -d $var_search_path"/"$file ]  
    		then  
      		func_loop_search_ipa_file $var_search_path"/"$file  
    	fi  
	done 
}

function func_search_ipa_file() {
	global_var_ipa_path_array=()
	func_loop_search_ipa_file $1

	for i in "${global_var_ipa_path_array[@]}"
	do
	echo $i
	# echo "\n"
	done
}


# func_search_ipa_file $1

# echo ${global_var_ipa_path_array[@]}


# array=("etc" "bin" "var")
# for i in "${array[@]}"
# do
# echo $i
# done


# array=("etc" "bin" "var")
# for i in "${array[@]}"
# do
# array+=("sbin")
# # echo $i
# echo ${array[@]}
# done