import json
import Th
import socket
import struct
import tkinter.messagebox
import operator
import tk

class  client ():
    def __init__(self,**args):
        self.args=args
        self.con=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
        self.con.connect((self.args['host'],self.args['port']))
        self.setpage();
        return
    def Receve(self):
        lock.acquire()
        while 1:
                bytenum=struct.unpack('!L', self.con.recv(4))[0]
                data=self.con.recv(int(bytenum)).decode('utf-8')
                info=json.loads(data)
                #print(info)
                if 'project' in info.keys():
                    self.tk.secondPage(info);
                elif 'order' in info.keys():
                    self.tk.thirdPage(info)
                elif 'css' in info.keys():
                    self.tk.toplevel(info);
                elif 'info' in info.keys():
                    self.message('提示',info['info']);
                elif 'x' in info.keys():
                    return;

    def setpage(self):
        Th.th(self.Receve).start()
        self.tk=tk.tk(self)
        self.tk.firstPage();
        self.tk.mainloop()
        return

    def  sent(self, arg):
        data=json.dumps(arg)+'\n';
        self.con.send(data.encode('utf-8'))
        return

    def  message(self, arg1,arg2):
        tkinter.messagebox.showinfo(arg1, arg2);
        return

lock=Th.lock();
c=client(host='172.23.3.247' , port=8000 );










