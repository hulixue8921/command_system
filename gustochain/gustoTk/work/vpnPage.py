import tkinter.ttk as ttk
import tkinter
import sys
import operator

from gustoTk import gustoTk
from ConsPool import Connect
import threading
import functools
from tkinter import messagebox
from .vpnAddToplevel import vpnAdd
from .vpnUpdateToplevel import vpnUpdate


class vpnPage(gustoTk):
    def __init__(self, client, data):
        super().__init__(client)
        self.frame = None
        self.selectValue = tkinter.StringVar()
        self.gc(self.client.mem['workSon'])
        self.sourceData = data
        apiData = {'modelName': 'vpn', 'apiName': 'listUsers', 'env': data, 'token': self.client.token}
        """
        开启一个线程 获取数据
        """

        def get():
            self.data = Connect(()).sent(apiData).get()
            if self.data['code'] == '200':
                self.ui()
            else:
                messagebox.showinfo('error', self.data['data']['message'])

        t1 = threading.Thread(target=functools.partial(get))
        t1.start()
        return

    def ui(self):
        print(self.data)
        self.frame = tkinter.Frame()
        self.frame.pack(expand=True)
        self.client.mem['workSon'].append(self.frame)

        def addUser():
            vpnAdd(self.client, self.sourceData)
            return

        def updateUser(*args):
            vpnUpdate(self.client, self.sourceData, self.selectValue.get())
            return

        tempdata = []
        for i in self.data['data']['data']:
            tempdata.append(i)
        tempdata.sort()

        ttk.Label(self.frame, text="vpn用户名:").grid(row=0, column=0)
        combox = ttk.Combobox(self.frame, state="readonly", textvariable=self.selectValue,
                              values=tuple(tempdata), width=50)
        combox.grid(row=0, column=1, padx=5)
        combox.bind("<<ComboboxSelected>>", functools.partial(updateUser))
        ttk.Button(self.frame, text="增加用户", command=functools.partial(addUser)).grid(row=0, column=2, padx=5)
