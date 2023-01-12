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


class vpnUpdate(gustoTk):
    def __init__(self, client, data, data1):
        super().__init__(client)
        self.root = tkinter.Toplevel()
        self.root.geometry('800x300')
        self.frame = tkinter.Frame(self.root)
        self.frame.pack(pady=50, expand=True)
        self.root.title(data + "用户操作")
        self.sourceData = data
        self.sourceData1 = data1
        self.ui()
        return

    def ui(self):
        def delUser():
            apiData = {"modelName": "vpn", "apiName": "delUser", "env": self.sourceData, "user": self.sourceData1,
                       'token': self.client.token}

            def f():
                self.data = Connect(()).sent(apiData).get()
                if self.data['code'] == '200':
                    messagebox.showinfo('info', "删除成功")
                else:
                    messagebox.showinfo('info', "删除失败，请联系管理员！！！")
                self.root.destroy()
                return

            t1 = threading.Thread(target=functools.partial(f))
            t1.start()

            return

        def mailUser():
            apiData = {"modelName": "vpn", "apiName": "addUser", "env": self.sourceData, "user": self.sourceData1,
                       'token': self.client.token}

            def f():
                self.data = Connect(()).sent(apiData).get()
                print(self.data)
                if self.data['code'] == '200':
                    messagebox.showinfo('info', "重置成功，已发送相关人员邮箱")
                else:
                    messagebox.showinfo('info', "重置失败，请联系管理员！！！")
                self.root.destroy()
                return

            t1 = threading.Thread(target=functools.partial(f))
            t1.start()
            return

        ttk.Button(self.frame, text="删除用户" + self.sourceData1, command=functools.partial(delUser)).grid(row=0, column=0)
        ttk.Button(self.frame, text="重置用户" + self.sourceData1, command=functools.partial(mailUser)).grid(row=0,
                                                                                                         column=1,
                                                                                                         padx=20)
