# -------------------------------------------------------------------------------
# Name:        模块1
# Purpose:
#
# Author:      Administrator
#
# Created:     08/02/2021
# Copyright:   (c) Administrator 2021
# Licence:     <your licence>
# -------------------------------------------------------------------------------


import json
import socket
import struct


class Connect:
    host = ''
    port = 8000

    def __init__(self, conargs):
        self.call = None
        self.SEND_BUF_SIZE = 4096
        self.RECV_BUF_SIZE = 40960
        self.conargs = conargs
        self.set()
        return

    def set(self):
        call = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        call.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, self.SEND_BUF_SIZE)
        call.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, self.RECV_BUF_SIZE)
        call.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
        call.setsockopt(socket.SOL_TCP, socket.TCP_KEEPINTVL, 6)
        if Connect.host:
            call.connect((Connect.host, Connect.port))
            self.call = call
        else:
            call.connect(self.conargs)
            self.call = call
            Connect.host = self.conargs[0]
            Connect.port = self.conargs[1]
        return

    def close(self):
        self.call.close()

    def sent(self, data):
        Data = json.dumps(data) + '\n'
        try:
            self.call.send(Data.encode('utf-8'))
            return self
        except socket.error:
            print(1111)

    def get(self):
        temp = []
        Data = b''

        try:
            bytenum = struct.unpack('!L', self.call.recv(4))[0]
            num = int(bytenum)
            '''
            解决recv 数据不全问题
            '''
            while 1:
                result = self.call.recv(num)
                temp.append(result)
                if len(result) == num:
                    break
                else:
                    num = num - len(result)

            for i in range(len(temp)):
                Data = Data + temp[i]

            data = Data.decode('utf-8')
            info = json.loads(data)
            return info
        except:
            return {}
