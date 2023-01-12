import functools
import tkinter
from tkinter import messagebox
from gustoTk import gustoTk
from gustoTk.work import Work
import tkinter.ttk as ttk
import threading


class Index(gustoTk):
    username = None
    passwd = None
    version = '1.0.0'

    def __init__(self, client):
        super().__init__(client)
        self.gc(self.client.mem['index'])
        self.gc(self.client.mem['work'])
        self.gc(self.client.mem['workSon'])
        self.en = None
        self.username = tkinter.StringVar(value=Index.username)
        self.passwd = tkinter.StringVar(value=Index.passwd)
        self.int = tkinter.IntVar()
        self.frame = tkinter.Frame()
        self.frame.pack(pady=100)
        self.client.mem['index'].append(self.frame)
        self.ui()
        return

    def ui(self):

        ttk.Label(self.frame, text='用户名', width=10).grid(row=0, column=0)
        tkinter.ttk.Entry(self.frame, textvariable=self.username).grid(row=0, column=1, pady=10)
        ttk.Label(self.frame, text='密码', width=10).grid(row=1, column=0)
        self.en = tkinter.ttk.Entry(self.frame, textvariable=self.passwd, show='*')
        self.en.grid(row=1, column=1, padx=10)
        tkinter.ttk.Checkbutton(self.frame, text='显示密码', variable=self.int, command=lambda: self.show()).grid(row=1,
                                                                                                              column=2,
                                                                                                              pady=10)
        tkinter.ttk.Button(self.frame, text='登录', command=lambda: self.commit('load')).grid(row=2, column=0,
                                                                                            columnspan=3)
        tkinter.ttk.Button(self.frame, text='注册', command=lambda: self.commit('reg')).grid(row=3, column=0,
                                                                                           columnspan=3)
        return

    def show(self):
        if self.int.get() == 1:
            self.en.config(show='')
        elif self.int.get() == 0:
            self.en.config(show='*')
        return

    def commit(self, args):
        apiname = args
        Data = {'modelName': 'user', 'apiName': apiname, 'username': self.username.get(), 'passwd': self.passwd.get(),
                'version': Index.version}
        info = self.con.sent(Data).get()
        if info:
            if info['code'] == '200':
                self.gc(self.client.mem['index'])
                Index.set(self.username.get(), self.passwd.get())
                self.client.token = info['data']['token']
                Work(self.client)
                return
            else:
                messagebox.showinfo('error', info['data']['message'])
        else:
            from Client import Client
            client = Client()
            client.run()

    @classmethod
    def set(cls, username, passwd):
        cls.username = username
        cls.passwd = passwd
        return
