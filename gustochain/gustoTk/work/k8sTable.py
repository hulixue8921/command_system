import tkinter.ttk as ttk
import tkinter
import sys
import operator

from gustoTk import gustoTk
from ConsPool import Connect
import threading
import functools
from tkinter import messagebox
from .k8sToplevel import k8sToplevel


class k8sTable(gustoTk):
    tableColomn = ['serviceName', 'podName', 'tag', 'hostIp', 'podIp', 'status', 'startTime', 'restartCount']

    def __init__(self, client, data):
        super().__init__(client)
        self.gc(self.client.mem['workSon'])
        self.frame = None
        apiData = {'modelName': 'k8s', 'apiName': 'listPods', 'env': data, 'token': self.client.token}
        self.data = None
        self.searchKey = tkinter.StringVar()
        self.searchValue = tkinter.StringVar()
        self.valueBox = None
        self.searchFrame = None
        self.tableFrame = None
        self.tree = None
        self.sourceData = data
        """
        开启一个线程 获取数据
        """

        def get():
            self.data = Connect(()).sent(apiData).get()
            if self.data['code'] == '200':
                self.ui()
            elif self.data['code'] == '204':
                self.reloadAgain()
            else:
                messagebox.showinfo('error', self.data['data']['message'])
            return

        t1 = threading.Thread(target=functools.partial(get))
        t1.start()
        return

    def ui(self):
        def searchFun(*args):
            data = self.searchKey.get()
            tempData = []
            self.valueBox.destroy()
            self.frame.update()
            self.searchValue.set("")
            for i in self.data['data']['data']:
                tempData.append(i[data])
            #tempData.sort()
            t = list(set(tempData))
            t.sort()
            self.valueBox = ttk.Combobox(self.searchFrame, state="readonly", textvariable=self.searchValue,
                                         values=tuple(t), width=50)
            self.valueBox.grid(row=0, column=3)
            self.valueBox.bind("<<ComboboxSelected>>", functools.partial(valueFun))
            return

        def valueFun(*args):
            self.tableFrame.destroy()
            self.tableFrame.update()
            k = self.searchKey.get()
            v = self.searchValue.get()
            tempdata = []
            for i in self.data['data']['data']:
                if operator.eq(i[k], v):
                    tempdata.append(i)

            tableUI()
            tableInsert(tempdata)
            return

        def treesortFun(col, reverse):
            temp = [(self.tree.set(key, col), key) for key in self.tree.get_children('')]
            temp.sort(reverse=reverse)

            for index, (value, key) in enumerate(temp):
                self.tree.move(key, '', index)

            self.tree.heading(col, command=lambda: treesortFun(col, not reverse))
            return

        def rowClick(*args):
            for item in self.tree.selection():
                print(self.tree.item(item, 'values'))
                k8sToplevel(self.client, self.tree.item(item, 'values')[0])

        def tableUI():
            self.tableFrame = tkinter.Frame(self.frame)
            self.tableFrame.pack(expand=0, fill=tkinter.BOTH)
            self.client.mem['workSon'].append(self.tableFrame)
            y = ttk.Scrollbar(self.tableFrame, orient=tkinter.VERTICAL)
            x = ttk.Scrollbar(self.tableFrame, orient=tkinter.HORIZONTAL)
            x.pack(side=tkinter.BOTTOM, fill=tkinter.X)
            y.pack(side=tkinter.RIGHT, fill=tkinter.Y)
            self.tree = ttk.Treeview(self.tableFrame, columns=k8sTable.tableColomn, yscrollcommand=y.set,
                                     xscrollcommand=x.set,
                                     show='headings')
            self.tree.pack(fill=tkinter.BOTH, expand=0, pady=10)
            self.tree.bind('<Double-Button-1>', rowClick)
            y.config(command=self.tree.yview)
            x.config(command=self.tree.xview)
            for i in k8sTable.tableColomn:
                self.tree.column(i, width=150, anchor='center')
                self.tree.heading(i, text=i, command=functools.partial(treesortFun, i, 1))
            return

        def cleanFun():
            self.searchFrame.destroy()
            self.searchFrame.update()
            self.tableFrame.destroy()
            self.tableFrame.update()
            self.searchKey = tkinter.StringVar()
            self.searchValue = tkinter.StringVar()
            searchUI()
            tableUI()
            tableInsert(self.data['data']['data'])
            return

        def tableInsert(data):
            for i in data:
                tempdata = []
                for colomnName in k8sTable.tableColomn:
                    tempdata.append(i[colomnName])
                self.tree.insert('', 'end', values=tempdata)
            return

        def refresh():
            k8sTable(self.client, self.sourceData)
            return

        def searchUI():
            self.searchFrame = tkinter.Frame(self.frame)
            self.searchFrame.pack(expand=0, fill=tkinter.BOTH)
            self.client.mem['workSon'].append(self.searchFrame)
            ttk.Label(self.searchFrame, text="搜索key:").grid(row=0, column=0, padx=10)
            key = ttk.Combobox(self.searchFrame, state="readonly", textvariable=self.searchKey,
                               values=tuple(['serviceName', 'hostIp', 'podIp']), style="TCombobox")
            key.grid(row=0, column=1)
            key.bind("<<ComboboxSelected>>", functools.partial(searchFun))
            ttk.Label(self.searchFrame, text="搜索value:").grid(row=0, column=2, padx=10)
            self.valueBox = ttk.Combobox(self.searchFrame, state="readonly", textvariable=self.searchValue, values=(),
                                         width=50)
            self.valueBox.grid(row=0, column=3)
            self.valueBox.bind("<<ComboboxSelected>>", functools.partial(valueFun))
            tkinter.ttk.Button(self.searchFrame, text="清空", command=functools.partial(cleanFun)).grid(row=0,
                                                                                                      column=4,padx=5)
            tkinter.ttk.Button(self.searchFrame, text="刷新",command=functools.partial(refresh)).grid(row=0,column=5,padx=5)

        self.frame = tkinter.Frame()
        self.frame.pack(side=tkinter.LEFT, fill=tkinter.Y)
        self.client.mem['workSon'].append(self.frame)
        searchUI()
        tableUI()
        tableInsert(self.data['data']['data'])
        return
