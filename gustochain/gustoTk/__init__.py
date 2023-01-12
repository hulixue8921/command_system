import tkinter.ttk as ttk
import tkinter
import sys
import operator
from tkinter import messagebox


class gustoTk:
    def __init__(self, client):
        self.client = client
        self.con = self.client.getCon()
        return

    def ui(self):
        return

    def reloadAgain(self):
        messagebox.showinfo('info', "需要重新登录！！！")
        from Client import Client
        client = Client()
        client.run()

    def gc(self, array):
        """
        className = self.__class__.__name__
        if operator.eq(className, 'Index'):
            for i in self.index:
                i.forget()
                i.update()
                i.destroy()
                i.pack_forget()
        elif operator.eq(className, 'Work'):
            for i in self.work:
                i.forget()
                i.update()
                i.destroy()
                i.pack_forget()
        """
        x = list(range(0, len(array)))
        x.reverse()
        for i in x:
            array[i].forget()
            array[i].update()
            array[i].destroy()
            array[i].pack_forget()
            del array[i]
        return
