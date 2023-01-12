import tkinter.ttk as ttk
import tkinter
from functools import partial
from typing import Dict

from gustoTk import gustoTk
from gustoTk.work.k8sTable import k8sTable
from gustoTk.work.vpnPage import vpnPage
import operator
import functools
import threading
from ConsPool import Connect


class Work(gustoTk):
    def __init__(self, client):
        super().__init__(client)
        self.gc(self.client.mem['work'])
        self.tree = None
        self.frame = tkinter.Frame()
        self.frame.pack(expand=False, side=tkinter.LEFT, fill=tkinter.Y, ipadx=10)
        self.client.mem['work'].append(self.frame)
        self.ui()
        return

    def ui(self):
        tree = ttk.Treeview(self.frame)
        tree.pack(side=tkinter.LEFT, ipady=50, fill=tkinter.Y, expand=True)
        tree.bind('<<TreeviewSelect>>', self.fun)
        tree.tag_configure('title', font='Arial 16')
        tree.tag_configure('title1', font='Arial 13')
        root = tree.insert("", 0, 'project', text="项目", tags=())
        self.tree = tree

        def insert(data, node):
            if operator.eq(data.__class__.__name__, 'dict'):
                for k, v in data.items():
                    if operator.eq(v.__class__.__name__, 'list'):
                        n = tree.insert(node, '1', k, text=k, tags=())
                        for i in v:
                            insert(i, n)
                    else:
                        tree.insert(node, '1', k, text=k, tags=k)
            else:
                return

        for i in Connect(()).sent({'modelName': 'tree', 'token': self.client.token}).get()['data']:
            insert(i, root)

        return

    def fun(self, event):
        def table():
            """
            生成工作区页面内容
            """
            k8sTable(self.client, event.widget.selection()[0])

            return

        def vpn():
            vpnPage(self.client, event.widget.selection()[0])
            return

        funs: dict[str, partial] = {'lyrra-k8s-dev': functools.partial(table),
                                    'lyrra-k8s-test': functools.partial(table),
                                    'lyrra-k8s-pre': functools.partial(table),
                                    'lyrra-k8s-prod': functools.partial(table),
                                    'fu-k8s-dev': functools.partial(table),
                                    'fu-k8s-test': functools.partial(table),
                                    'fu-k8s-pre': functools.partial(table),
                                    'fu-k8s-prod': functools.partial(table),
                                    'show-k8s-dev': functools.partial(table),
                                    'show-k8s-test': functools.partial(table),
                                    'show-k8s-pre': functools.partial(table),
                                    'show-k8s-prod': functools.partial(table),
                                    'officeVpn': functools.partial(vpn),
                                    'overseaVpn': functools.partial(vpn)
                                    }

        if event.widget.selection()[0] in funs:
            funs[event.widget.selection()[0]]()
        print(event.widget.selection()[0])
        return
