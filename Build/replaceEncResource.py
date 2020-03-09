#coding=utf-8

#--------------------------------------------
# 功能：python拷贝并加密资源文件
# 使用说明：	encrypt <input fileName> <output fileName path>
# 作者：luohs
# E-mail:luohuasheng0225@gmail.com
#--------------------------------------------

import shutil
import os
import sys
sys.path.append("..")
import python.fileServer
import python.encryptServer
import python.setting

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print "replaceEncResource脚本不执行，所传参数数目不正确";
        sys.exit(0)

    sourceFile = sys.argv[1]
    targetFile = sys.argv[2]
    sourceFilePath = ""
    targetFilePath = os.path.join(targetFile,python.setting.main_source_fileName)
    for parent,dirnames,filenames in os.walk(sourceFile):
        if sourceFilePath != "":
            break
        for fileName in filenames:
            if python.setting.main_source_fileNameSpec == fileName:
                sourceFilePath = parent
                break
    if sourceFilePath == "":
        print "未找到对应目录" + python.setting.main_source_fileNameSpec
        sys.exit(0)

    #拷贝文件
    if python.fileServer.copyfile(sourceFilePath,targetFilePath) == False:
        print "拷贝文件失败"
        sys.exit(0)
    #加密文件
    for keyAndFile in python.setting.MainKeyAndFile:
        for key in keyAndFile.keys():
            fileType = keyAndFile[key]
            for parent,dirnames,filenames in os.walk(targetFilePath):
                #文件名中包含 fileType
                for fileName in filenames:
                    if fileType in fileName:
                        encryptPath = os.path.join(parent,fileName)
                        if python.encryptServer.encryptFile(encryptPath,key):
                            print "加密" + encryptPath + "完成"
