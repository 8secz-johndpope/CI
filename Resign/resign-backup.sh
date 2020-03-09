#!/bin/sh

# python -c 'import ../python/encryptServer; encryptServer.encryptFile(encryptPath,"HSYT_C_K")'  

if ! ([ -f "$1" ]); then
	echo \"${1}\"文件不存在
	exit
fi
ipaName=${1%.ipa}
if [ "$ipaName" = "$1" ]; then
	echo \"${1}\"不是ipa文件
	exit
fi

cd $(pwd)

TEM_DIR="tmp"
PAYLOAD_DIR=$TEM_DIR/Payload
OUTPUT_DIR="Build"
RESOURCE_DIR="Resource"

## 这个必须要，否则会在文件名中有空格时出错 
OIFS="$IFS"
IFS=$'\n'

function delete() {
	echo "移除临时文件夹"
	rm -rf $TEM_DIR
	if [ -d $OUTPUT_DIR/Payload ]
		then
		rm -rf $OUTPUT_DIR/Payload
	fi

	if [ -d $OUTPUT_DIR/Symbols ]
		then
		rm -rf $OUTPUT_DIR/Symbols
	fi
}

function verify() {
	name=$(basename $1)
	name=$1

	#spctl --ignore-cache --no-cache --assess --type execute --verbose=4 Payload/*.app
	CSVINFO=`codesign --verify --deep $1`
	# echo $CSVINFO
	if  [ `echo $CSVINFO|wc -c` -gt 0 ]
	then
		echo "$name: resign successfully"
	else
	   	echo "$name: resign failed"
	    exit -1;
	fi
}

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
      		echo "加密$fullname"
      		cp -f $path $3/$fullname
      		python encrypt.py $3/$fullname "HSYT_C_K"
      		cp -f $3/$fullname $2
      		continue
      	fi 

      	if [ "$extension" = "pem" ]
      		then
      		echo "加密$fullname"
      		cp -f $path $3/$fullname
      		python encrypt.py $3/$fullname "hsyuntai.com"
      		cp -f $3/$fullname $2
      		continue
      	fi 
      	# cp -r -f $path $PAYLOAD_DIR/$APP
      	cp -f $path $2
    	fi  
	done 
}

echo "创建tmp临时文件夹"
if [ ! -d "$TEM_DIR" ]; 
    then
    mkdir $TEM_DIR
fi

if [ -d "$OUTPUT_DIR" ]
	then
		rm -r -f $OUTPUT_DIR/*
	else
		mkdir $OUTPUT_DIR
fi

## step 1, unzip ipa file
echo "解压${ipaName}.ipa"
unzip -q ${ipaName}.ipa -d $TEM_DIR

if [ ! -d $PAYLOAD_DIR ]; 
    then
    echo "unzip ${ipaName}.ipa failed"
    exit
fi

if [ -d $PAYLOAD_DIR ]
	then
	APP=`ls $PAYLOAD_DIR | tail -1`
	if [ -n "$APP" ]
	then
		echo $APP
	else
		delete
		exit
	fi
fi

if [ -d $PAYLOAD_DIR/$APP/Frameworks ]
	then
	FRAMEWORK=`ls $PAYLOAD_DIR/$APP/Frameworks | tail -1`
	if [ -n "$FRAMEWORK" ]
	then
		echo $FRAMEWORK
	fi
fi

if [ -d $PAYLOAD_DIR/$APP/PlugIns ]
	then
	APP_PLIGIN=`ls $PAYLOAD_DIR/$APP/PlugIns | tail -1`
	if [ -n "$APP_PLIGIN" ]
	then
		echo $APP_PLIGIN
	fi
fi

if [ -d $PAYLOAD_DIR/$APP/Watch ]
	then
	WATCH=`ls $PAYLOAD_DIR/$APP/Watch | tail -1`
	if [ -n "$WATCH" ]
	then
		echo $WATCH
	fi
fi

if [ -d $PAYLOAD_DIR/$APP/Watch/$WATCH/PlugIns ]
	then
	WATCH_PLUGIN=`ls $PAYLOAD_DIR/$APP/Watch/$WATCH/PlugIns | tail -1`
	if [ -n "$WATCH_PLUGIN" ]
	then
		echo $WATCH_PLUGIN
	fi
fi

## step 2, remove old codesign
echo "删除旧的签名文件"
if [ -n "$FRAMEWORK" ]
	then
	if [ -d $PAYLOAD_DIR/$APP/Frameworks/$FRAMEWORK/_CodeSignature ]
		then
		rm -rf $PAYLOAD_DIR/$APP/Frameworks/$FRAMEWORK/_CodeSignature/
		echo "remove $PAYLOAD_DIR/$APP/Frameworks/$FRAMEWORK/_CodeSignature/"
	fi
fi

if [ -n "$WATCH" ]
	then
	if [ -d $PAYLOAD_DIR/$APP/Watch/$WATCH/_CodeSignature ]
		then
		rm -rf $PAYLOAD_DIR/$APP/Watch/$WATCH/_CodeSignature/
		echo "remove $PAYLOAD_DIR/$APP/Watch/$WATCH/_CodeSignature/"
	fi
fi


if [ -n "$APP" ]
	then
	if [ -d $PAYLOAD_DIR/$APP/_CodeSignature/ ]
		then
		rm -rf $PAYLOAD_DIR/$APP/_CodeSignature/
		echo "remove $PAYLOAD_DIR/$APP/_CodeSignature/"
	fi
fi

## step 3, copy new provision profile
if [ -f $(pwd)/embedded.mobileprovision ]
	then
	if [ -f $PAYLOAD_DIR/$APP/embedded.mobileprovision ]
		then
		rm -rf $PAYLOAD_DIR/$APP/embedded.mobileprovision
		echo "从$PAYLOAD_DIR/$APP删除embedded.mobileprovision"
	fi 
	cp -f embedded.mobileprovision $PAYLOAD_DIR/$APP/embedded.mobileprovision
	echo "拷贝embedded.mobileprovision"
else
	echo "当前文件夹中未发现embedded.mobileprovision文件"
	delete
	exit
fi

if [ -d $RESOURCE_DIR -a `ls $RESOURCE_DIR|wc -w` -gt 0 ]
	then
	## function
	ergodic $RESOURCE_DIR $PAYLOAD_DIR/$APP $TEM_DIR
fi

## step 4, create Entitlements.plst
echo "生成Entitlements.plist文件"
/usr/libexec/PlistBuddy -x -c "Print Entitlements" /dev/stdin <<< $(security cms -D -i $PAYLOAD_DIR/$APP/embedded.mobileprovision) >$TEM_DIR/Entitlements.plist
echo "打印Entitlements.plist文件"
/usr/libexec/PlistBuddy -x -c "Print Entitlements" /dev/stdin <<< $(security cms -D -i $PAYLOAD_DIR/$APP/embedded.mobileprovision)
if [ -f $TEM_DIR/Entitlements.plist ]
	then
	cp -f $TEM_DIR/entitlements.plist "$PAYLOAD_DIR/$APP/archived-expanded-entitlements.xcent"
fi

## step 5, set CFBundleIdentifier Info.plist
echo "设置Info.plist"
APPID=`/usr/libexec/PlistBuddy -c "Print application-identifier" $TEM_DIR/Entitlements.plist`
APPID=`echo ${APPID#*.}`
# /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $APPID" $PAYLOAD_DIR/$APP/Info.plist

## step 6, codesign with new certificate and provision
echo "开始签名"
# signIdentity="8223E6322305B0BFBF9C86C8CA56F6D93D67C281"
signIdentity="4C544AAF070005CED34D9070084ADE7A609F2D1F"

# Resigning dylibs
if [ -e $PAYLOAD_DIR/$APP/Frameworks ]
then
  	list=`find $PAYLOAD_DIR/$APP/Frameworks -maxdepth 1 -name "*.framework"`
	for i in $list
    do
    	codesign -f -s ${signIdentity} $i
    done
fi

if [ -e $PAYLOAD_DIR/$APP/Watch/$WATCH/PlugIns ]
then
	list=`find $PAYLOAD_DIR/$APP/Watch/$WATCH/PlugIns -maxdepth 1 -name "*.appex"`
	for i in $list
	do
		codesign -f -s ${signIdentity} $i
	done
fi

if [ -e $PAYLOAD_DIR/$APP/Watch/ ]
then
  	list=`find $PAYLOAD_DIR/$APP/Watch -maxdepth 1 -name "*.app"`
	for i in $list
	do
		codesign -f -s ${signIdentity} $i
	done
fi

if [ -e $PAYLOAD_DIR/$APP/PlugIns ]
then
    list=`find $PAYLOAD_DIR/$APP/PlugIns -maxdepth 1 -name "*.appex"`
	for i in $list
	do
		codesign -f -s ${signIdentity} $i
	done
fi

if [ -e $PAYLOAD_DIR/$APP ]
then
    list=`find $PAYLOAD_DIR/$APP -maxdepth 1 -name "*.app"`
	for i in $list
	do
		codesign -f -s ${signIdentity} --entitlements $TEM_DIR/Entitlements.plist $i
	done
fi
# codesign -f -s "${signIdentity}" --entitlements Entitlements.plist $PAYLOAD_DIR/$APP

echo "开始验签"
if [ -e $PAYLOAD_DIR/$APP/Frameworks ]
then
  	list=`find $PAYLOAD_DIR/$APP/Frameworks -maxdepth 1 -name "*.framework"`
	for i in $list
    do
    	verify $i
    done
fi

if [ -e $PAYLOAD_DIR/$APP/Watch/$WATCH/PlugIns ]
then
	## 解决读取文件名含有空格时无法正确识别问题
	# OIFS="$IFS"
	# IFS=$'\n'
    list=`find $PAYLOAD_DIR/$APP/Watch/$WATCH/PlugIns -name '*.appex'`
	for i in $list
    do
    	verify $i
    done
fi

if [ -e $PAYLOAD_DIR/$APP/Watch ]
then
    list=`find $PAYLOAD_DIR/$APP/Watch -maxdepth 1 -name "*.app"`
	for i in $list
    do
    	verify $i
    done
fi

if [ -e $PAYLOAD_DIR/$APP/PlugIns ]
then
    list=`find $PAYLOAD_DIR/$APP/PlugIns -maxdepth 1 -name "*.appex"`
	for i in $list
    do
    	verify $i
    done
fi

if [ -e $PAYLOAD_DIR/$APP ]
then
    list=`find $PAYLOAD_DIR/$APP -maxdepth 1 -name "*.app"`
	for i in $list
    do
    	verify $i
    done
fi

## step 7, zip it
echo "重新签名后的IPA文件路径：$OUTPUT_DIR/${ipaName}abc.ipa"
if [ -d $TEM_DIR/Payload ]
	then
	cp -r -f $TEM_DIR/Payload $OUTPUT_DIR
fi

if [ -d $TEM_DIR/Symbols ]
	then
	cp -r -f $TEM_DIR/Symbols $OUTPUT_DIR
fi

cd $OUTPUT_DIR
zip -qry ${ipaName}abc.ipa Payload Symbols
cd ..

## step 8, delete tmp
delete
