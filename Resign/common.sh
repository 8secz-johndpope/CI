#!/bin/sh

## 这个必须要，否则会在文件名中有空格时出错 
IFS=$'\n'

source define.sh

function ergodic() { 
  if [ ! -d $2 ]
      then
      exit
    fi

    if [ ! -d $3 ]
      then
      mkdir $3
    fi

  for file in `ls $1`  
  do  
    if [ -d $1"/"$file ]  
      then  
        ergodic $1"/"$file $2 $3
      else  
        local path=$1"/"$file 
        local fullname=$(basename $path)
        local filename=${fullname%.*}
        local extension=${fullname##*.}
        
        if [ "$extension" = "json" ]
          then
          cp -f $path $3/$fullname
          python encrypt.py $3/$fullname "HSYT_C_K"
          echo "拷贝文件 $fullname 到 $2"
          cp -f $3/$fullname $2
          continue
        fi 

        if [ "$extension" = "pem" ]
          then
          cp -f $path $3/$fullname
          python encrypt.py $3/$fullname "hsyuntai.com"
          echo "拷贝文件 $fullname 到 $2"
          cp -f $3/$fullname $2
          continue
        fi 
        # cp -r -f $path $PAYLOAD_DIR/$APP
        echo "拷贝文件 $fullname 到 $2"
        cp -f $path $2
      fi  
  done 
}

function func_mkdir_build() {

  echo "创建tmp等临时文件夹......"
  local var_input_path=$1

  local var_temp_path=$var_input_path/$global_var_temp
  global_var_temp_output_path=$var_temp_path
  if [ ! -d $var_temp_path ]; 
      then
      mkdir $var_temp_path
  else
      rm -rf $var_temp_path/*
  fi

  local var_out_path=$var_input_path/$global_var_output
  global_var_output_path=$var_out_path
  if [ -d $var_out_path ]
    then
      rm -rf $var_out_path/*
  else
      mkdir $var_out_path
  fi

  local var_provision_output_path=$var_input_path/$global_var_output/$global_var_provision
  global_var_provision_output_path=$var_provision_output_path
  if [ -d $var_provision_output_path ]
    then
      rm -r -f $var_provision_output_path/*
    else
      mkdir $var_provision_output_path
  fi
}

function func_unzip_ipa() {

  echo "开始解压ipa......"
  local var_ipa_path=$1
  local var_output_path=$2

  if [ ! -f $var_ipa_path ]
    then
    echo "$var_ipa_path 文件不存在"
    exit -1
  fi

  local fullname=$(basename $var_ipa_path)
  local filename=${fullname%.*}
  local extension=${fullname##*.}
  if [ "$extension" != "ipa" ]
    then
    echo "$var_ipa_path 不是ipa格式文件"
    exit -1
  fi 
  
  if [ ! -d $var_output_path ] 
    then
    mkdir $var_output_path
  else
    rm -rf $var_output_path/*
  fi

  echo "正在解压$fullname......"
  unzip -q $var_ipa_path -d $var_output_path

  if [ ! -d $var_output_path/$global_var_payload ]; 
    then
    echo "$fullname解压失败！"
    exit -1
  fi
}


function func_zip_ipa() {

  echo "重新打包....."
  local var_temp_path=$1
  local var_output_path=$2
  local var_output_file_name=$3

  if [ ! -d $var_output_path ]
    then
    mkdir $var_output_path
  fi

  if [ ! -d $var_temp_path/Payload ]
    then
    echo "$var_temp_path/Payload 不存在！"
    exit -1
  else
    echo "正在拷贝Payload ......"
    cp -r -f $var_temp_path/Payload $var_output_path
  fi

  if [ -d $var_temp_path/Symbols ]
    then
    echo "正在拷贝Symbols ......"
    cp -r -f $var_temp_path/Symbols $var_output_path
  fi

  echo "重新打包 ....."
  cd $var_output_path
  zip -qry resign_${var_output_file_name}.ipa Payload Symbols
  if [ ! -f $var_output_path/$resign_${var_output_file_name}.ipa ]
    then
    echo "$resign_${var_output_file_name}.ipa 打包完成！"
  else
    echo "$resign_${var_output_file_name}.ipa 打包失败！"
  fi
}

function func_find_exec_file() {

  echo "查找需要签名的文件......"
  local var_input_payload_path=$1

  if [ ! -d $var_input_payload_path ]
    then
    echo "$var_input_payload_path 不存在！"
    exit -1
  fi

  if [ -d $var_input_payload_path ]
    then
    APP=`ls $var_input_payload_path | tail -1`
    if [ -n "$APP" ]
    then
      echo $APP
    else
      echo "$var_input_payload_path 中未发现'.app'文件！"
      exit -1
    fi
  fi

  local var_framework_path=$var_input_payload_path/$APP/Frameworks
  if [ -d $var_framework_path ]
    then
    FRAMEWORK=`ls $var_framework_path | tail -1`
    if [ -n "$FRAMEWORK" ]
    then
      echo $FRAMEWORK
    fi
  fi

  local var_app_plugin_path=$var_input_payload_path/$APP/PlugIns
  if [ -d $var_app_plugin_path ]
    then
    APP_PLIGIN=`ls $var_app_plugin_path | tail -1`
    if [ -n "$APP_PLIGIN" ]
    then
      echo $APP_PLIGIN
    fi
  fi

  local var_watch_app_path=$var_input_payload_path/$APP/Watch
  if [ -d $var_watch_app_path ]
    then
    WATCH=`ls $var_watch_app_path | tail -1`
    if [ -n "$WATCH" ]
    then
      echo $WATCH
    fi
  fi

  local var_watch_app_plugin_path=$var_input_payload_path/$APP/Watch/$WATCH/PlugIns
  if [ -d $var_watch_app_plugin_path ]
    then
    WATCH_PLUGIN=`ls $var_watch_app_plugin_path | tail -1`
    if [ -n "$WATCH_PLUGIN" ]
    then
      echo $WATCH_PLUGIN
    fi
  fi
}

function func_delete_codeSignature_file() {

  echo "删除签名的文件......"
  local var_input_payload_path=$1

  if [ ! -d $var_input_payload_path ]
    then
    echo "$var_input_payload_path 不存在！"
    exit -1
  fi

  if [ -n "$FRAMEWORK" ]
    then
    if [ -d $var_input_payload_path/$APP/Frameworks/$FRAMEWORK/_CodeSignature ]
      then
      rm -rf $var_input_payload_path/$APP/Frameworks/$FRAMEWORK/_CodeSignature/
    fi
  fi

  if [ -n "$WATCH" ]
    then
    if [ -d $var_input_payload_path/$APP/Watch/$WATCH/_CodeSignature ]
      then
      rm -rf $var_input_payload_path/$APP/Watch/$WATCH/_CodeSignature/
    fi
  fi

  if [ -n "$APP" ]
    then
    if [ -d $var_input_payload_path/$APP/_CodeSignature/ ]
      then
      rm -rf $var_input_payload_path/$APP/_CodeSignature/
    fi
  fi

  if [ -f $var_input_payload_path/$APP/embedded.mobileprovision ]
    then
    rm -rf $PAYLOAD_DIR/$APP/embedded.mobileprovision
  fi
}

function func_create_entitiesElements_file() {
  echo "生成 Entitlements.plist文件"
  local var_dest_path=$1
  local var_mobileprovision_path=$2

  echo "目标路径: $var_dest_path"
  echo "mobileprovision路径: $var_mobileprovision_path"

  if [ ! -f $var_mobileprovision_path ]
    then
    echo "mobileprovision 不存在！"
    return
  fi

  local fullname=$(basename $var_mobileprovision_path)
  local filename=${fullname%.*}
  local extension=${fullname##*.}
  if [ "$extension" != "mobileprovision" ]
    then
    echo "$var_mobileprovision_path 不是'.mobileprovision'格式文件！"
    return
  fi

  if [ ! -d $global_var_temp_output_path ]
    then
      mkdir $global_var_temp_output_path
  fi

  echo "创建 Entitlements.plist 到 $global_var_temp_output_path"
  /usr/libexec/PlistBuddy -x -c "Print Entitlements" /dev/stdin <<< $(security cms -D -i $var_mobileprovision_path) >$global_var_temp_output_path/Entitlements.plist
  /usr/libexec/PlistBuddy -x -c "Print Entitlements" /dev/stdin <<< $(security cms -D -i $var_mobileprovision_path)
  if [ -f $global_var_temp_output_path/Entitlements.plist ]
    then
    if [ -d $var_dest_path ]
      then
      echo "拷贝 entitlements.plist 到 $var_dest_path"
      cp -f $global_var_temp_output_path/entitlements.plist "$var_dest_path/archived-expanded-entitlements.xcent"
    fi
  else
    echo "$global_var_temp_output_path 中未发现entitlements.plist"
  fi
}

function func_copy_resources_file() {

  echo "拷贝资源文件......"
  local var_path_app=$1
  local var_path_resources=$2
  echo "目标文件夹：$var_path_app"
  echo "源文件夹：$var_path_resources"

  local var_profile_dir=$global_var_provision_output_path
  declare local var_profile_path

  for file in `ls $var_profile_dir`  
  do  
    if [ -f $var_profile_dir"/"$file ]
      then
        local path=$var_profile_dir"/"$file 
        local fullname=$(basename $path)
        local filename=${fullname%.*}
        local extension=${fullname##*.}
        if [ "$extension" = "mobileprovision" ]
          then
          var_profile_path=$path
        fi 
    fi 
  done 

  if [ -d $var_path_resources ]
    then
    if [ `ls $var_path_resources|wc -w` -gt 0 ]
      then
      ## function
      ergodic $var_path_resources $var_path_app $global_var_temp_output_path
      else
        echo "$var_path_resources 文件夹为空！"
    fi
    else
      echo "$var_path_resources 文件夹不存在！"
  fi

  echo $var_profile_path
  if [ -f $var_profile_path ]
    then
    cp -f $var_profile_path $var_path_app/embedded.mobileprovision
    func_create_entitiesElements_file $var_path_app $var_profile_path
  else
    echo "$var_profile_path 文件不存在！"
  fi
}

