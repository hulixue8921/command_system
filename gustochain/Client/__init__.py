import functools
import struct
import threading
from ConsPool import Connect
from gustoTk.index import Index
import json


class Client:
    host = None
    port = None
    root = None
    index = []
    work = []
    workSon = []

    def __init__(self, **args):
        if args:
            publicData: dict[str, Any] = {'host': args['host'], 'port': args['port'], 'cons': {}, 'index': Client.index,
                                          'work': Client.work, 'workSon': Client.workSon}
            Client.host = args['host']
            Client.port = args['port']
            Client.root = args['root']

        else:
            publicData = {'host': Client.host, 'port': Client.port, 'cons': {}, 'index': Client.index,
                          'work': Client.work, 'workSon': Client.workSon}
        self.mem = publicData
        self.token = None
        self.root = Client.root
        self.gc(self.mem['index'])
        self.gc(self.mem['work'])
        self.gc(self.mem['workSon'])

    def run(self):
        self.newCon()
        Index(self)
        return

    def getCon(self):
        return self.mem['cons']['call']

    def newCon(self):
        self.mem['cons']['call'] = Connect((self.mem['host'], self.mem['port']))
        return

    def gc(self, array):
        x = list(range(0, len(array)))
        x.reverse()
        for i in x:
            array[i].forget()
            array[i].update()
            array[i].destroy()
            array[i].pack_forget()
            del array[i]

    def __del__(self):
        self.mem['cons']['call'].close()
