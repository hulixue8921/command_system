#-------------------------------------------------------------------------------
# Name:        模块1
# Purpose:
#
# Author:      Administrator
#
# Created:     08/02/2021
# Copyright:   (c) Administrator 2021
# Licence:     <your licence>
#-------------------------------------------------------------------------------


import socket
import struct
import json

class createCons ():
    def __init__ (self,conargs):
        self.SEND_BUF_SIZE=4096
        self.RECV_BUF_SIZE=40960
        self.post=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
        self.call=socket.socket(socket.AF_INET,socket.SOCK_STREAM)

        self.call.setsockopt(socket.SOL_TCP, socket.TCP_NODELAY, 1)
        self.call.setsockopt(socket.SOL_SOCKET,socket.SO_SNDBUF,self.SEND_BUF_SIZE)
        self.call.setsockopt(socket.SOL_SOCKET,socket.SO_RCVBUF,self.RECV_BUF_SIZE)
        self.post.setsockopt(socket.SOL_TCP, socket.TCP_NODELAY, 1)
        self.post.setsockopt(socket.SOL_SOCKET,socket.SO_SNDBUF,self.SEND_BUF_SIZE)
        self.post.setsockopt(socket.SOL_SOCKET,socket.SO_RCVBUF,self.RECV_BUF_SIZE)


        self.post.connect(conargs)
        self.call.connect(conargs)
        return;

    def sent (self,data):
        Data=json.dumps(data)+'\n'
        self.call.send(Data.encode('utf-8'))
        return self;

    def postSent(self,data):
        Data=json.dumps(data)+'\n'
        self.post.send(Data.encode('utf-8'))
        return self;

    def get (self):
        temp=[]
        Data=b''
        while 1:
            bytenum=struct.unpack('!L', self.call.recv(4))[0]
            num=int(bytenum);
            '''
            解决recv 数据不全问题
            '''
            while 1:
                result=self.call.recv(num)
                temp.append(result)
                if len(result) == num:
                    break
                else:
                    num=num-len(result)

            for i in range(len(temp)):
                Data=Data+temp[i]

            data=Data.decode('utf-8')
            info=json.loads(data)
            return info

    def postGet(self):
        temp=[]
        Data=b''
        while 1:
            bytenum=struct.unpack('!L', self.post.recv(4))[0]
            num=int(bytenum);

            '''
            解决recv 数据不全问题
            '''
            while 1:
                result=self.post.recv(num)
                temp.append(result)

                if len(result) == num:
                    break
                else:
                    num=num-len(result)

            for i in range(len(temp)):
                Data=Data+temp[i]

            data=Data.decode('utf-8')
            info=json.loads(data)
            return info





