#coding=utf-8

#--------------------------------------------
# 功能：python拷贝资源文件
# 使用说明：	encrypt <input fileName> <output fileName path>
# 作者：luohs
# E-mail:luohuasheng0225@gmail.com
#--------------------------------------------

import shutil
import os
import sys
sys.path.append("..")
import python.fileServer
import python.setting

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print "recoverResource脚本不执行，所传参数数目不正确";
        sys.exit(0)
    targetFile = sys.argv[1]
    targetFilePath = os.path.join(targetFile,python.setting.main_source_fileName)
    #还原
    python.fileServer.recoverFile(targetFilePath)
