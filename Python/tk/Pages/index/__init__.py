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


import tkinter;
import operator

class Index():
    def __init__ (self,tk):
        self.tk=tk
        self.int=tkinter.IntVar();
        self.username=tkinter.StringVar();
        self.passwd=tkinter.StringVar();
        self.Frame=tkinter.Frame(self.tk);
        self.FrameU=tkinter.Frame(self.Frame);
        self.FrameP=tkinter.Frame(self.Frame);
        self.FrameL=tkinter.Frame(self.Frame);
        self.Frame.pack(expand=True);
        self.FrameU.pack(expand=True,fill=tkinter.X,pady=10);
        self.FrameP.pack(expand=True,fill=tkinter.X,pady=10);
        self.FrameL.pack(expand=True,pady=10);

        tkinter.Label(self.FrameU, text='用户名', width=10).pack(side=tkinter.LEFT);
        tkinter.Entry(self.FrameU,textvariable=self.username).pack(side=tkinter.LEFT,padx=5);
        tkinter.Label(self.FrameP,text='密码', width=10).pack(side=tkinter.LEFT);
        self.en=tkinter.Entry(self.FrameP,textvariable=self.passwd, show='*')
        self.en.pack(side=tkinter.LEFT,padx=5);
        tkinter.Checkbutton(self.FrameP,text='显示密码',variable=self.int,command=lambda:self.show()).pack()

        tkinter.Button(self.FrameL,text='登录',command=lambda:self.commit('load')).pack(side=tkinter.LEFT);
        tkinter.Button(self.FrameL,text='注册',command=lambda:self.commit('reg')).pack(padx=20);

        return;

    def show (self):
        if self.int.get() == 1:
            self.en.config(show='')
        elif self.int.get() == 0:
            self.en.config(show='*')
        return;

    def commit (self,args):
        apiname=args
        Data={'modelName':'user','apiName':apiname,'username':self.username.get(),'passwd':self.passwd.get()};
        info=self.tk.con.sent(Data).get();

        if info['code'] == 200 and operator.eq(args , 'load'):
            self.tk.con.postSent(Data).postGet()
            self.Frame.forget();
            self.tk.workPage()
            return
        elif info['code'] == 200 and operator.eq(args ,'reg'):
            self.tk.con.postSent({'modelName':'user','apiName':'load','username':self.username.get(),'passwd':self.passwd.get()}).postGet()
            self.Frame.forget();
            self.tk.workPage();
            return
        else:
            print(info);
