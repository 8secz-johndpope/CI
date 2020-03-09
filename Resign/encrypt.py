#coding=utf-8

import os
import sys
sys.path.append("..")
import python.encryptServer

if __name__ == '__main__':
    #加密文件
    filename=sys.argv[1]
    encryptkey=sys.argv[2]
    print "加密: "+filename
    print "密钥: "+encryptkey
    if os.path.exists(filename) == False:
        print  filename + "不存在！"
    else:
        python.encryptServer.encryptFile(filename, encryptkey)
    print "加密完成! "