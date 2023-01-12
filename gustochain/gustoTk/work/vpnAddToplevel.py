import tkinter.ttk as ttk
import tkinter
import sys
import operator

from gustoTk import gustoTk
from ConsPool import Connect
import threading
import functools
from tkinter import messagebox
import re
from ConsPool import Connect


class vpnAdd(gustoTk):
    def __init__(self, client, data):
        super().__init__(client)
        self.root = tkinter.Toplevel()
        self.root.geometry('800x300')
        self.frame = tkinter.Frame(self.root)
        self.frame.pack(pady=50, expand=True)
        self.root.title(data + "添加用户")
        self.value = tkinter.StringVar()
        self.sourceData = data
        self.ui()
        return

    def ui(self):
        def postData():
            print(self.value.get())
            apiData = {"modelName": "vpn", "apiName": "addUser", "env": self.sourceData, "user": self.value.get(),
                       "token": self.client.token}

            def f():
                if self.value.get():
                    self.data = Connect(()).sent(apiData).get()
                    if self.data['code'] == '200':
                        messagebox.showinfo('info', "添加成功")
                    else:
                        messagebox.showinfo('info', "添加失败，请联系管理员！！！")
                    self.root.destroy()
                else:
                    messagebox.showinfo('info', "请在输入框里输入")

            t1 = threading.Thread(target=functools.partial(f))
            t1.start()

            return

        ttk.Label(self.frame, text="用户名").grid(row=0, column=0)
        ttk.Entry(self.frame, textvariable=self.value).grid(row=0, column=1, padx=5)
        ttk.Button(self.frame, text="提交", command=functools.partial(postData)).grid(row=1, columnspan=4, pady=15)
